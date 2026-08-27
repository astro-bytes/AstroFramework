//
//  AESGCMCipher.swift
//  GatewayFoundation
//
//  Created by Porter McGary on 8/27/26.
//

import CryptoKit
import Foundation

/// A ``CacheCipher`` using AES-GCM, which encrypts and authenticates in one pass — a file altered
/// on disk fails to open rather than decrypting to something plausible.
///
/// The key is yours to supply and to manage. That split is deliberate: the encryption itself is a
/// primitive worth getting right once, while where a key lives and when it is available are policy
/// an app has to decide. Storing a key in the keychain under
/// `kSecAttrAccessibleAfterFirstUnlock` versus `...WhenUnlockedThisDeviceOnly` changes whether a
/// background refresh can read the cache at all, and this framework has no business choosing that
/// for you.
///
/// ```swift
/// // Generate once, store in the keychain, read back on launch.
/// let key = SymmetricKey(size: .bits256)
/// let cache = OnDiskCache<Profile>(lifetime: .to(hours: 6), cipher: AESGCMCipher(key: key))
/// ```
///
/// - Important: A key that changes between launches makes every cached file unreadable. The cache
///   treats that as corruption and starts over, so nothing breaks — but nothing is cached either.
public struct AESGCMCipher: CacheCipher {
    private let key: SymmetricKey

    /// - Parameter key: The symmetric key to seal with. 256 bits is the usual choice.
    public init(key: SymmetricKey) {
        self.key = key
    }

    public func encrypt(_ data: Data) throws -> Data {
        let sealed = try AES.GCM.seal(data, using: key)

        // `combined` is nil only for a nonce that is not 12 bytes, which `seal` does not produce.
        guard let combined = sealed.combined else {
            throw CipherError.sealingProducedNoOutput
        }
        return combined
    }

    public func decrypt(_ data: Data) throws -> Data {
        try AES.GCM.open(AES.GCM.SealedBox(combined: data), using: key)
    }

    /// Failures that are this cipher's own rather than CryptoKit's.
    public enum CipherError: Error {
        /// AES-GCM sealed the payload but produced no combined representation.
        case sealingProducedNoOutput
    }
}
