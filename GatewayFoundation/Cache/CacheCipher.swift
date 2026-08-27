//
//  CacheCipher.swift
//  GatewayFoundation
//
//  Created by Porter McGary on 8/27/26.
//

import Foundation

/// Transforms a cache payload on its way to and from disk.
///
/// ``OnDiskCache`` writes JSON to the caches directory. Handed a cipher, it writes whatever the
/// cipher returns instead, and runs the bytes back through ``decrypt(_:)`` on the way in.
///
/// This is a protocol rather than a flag because encryption is the app's decision, not the
/// framework's: which algorithm, where the key lives, how it rotates, whether the key is available
/// before first unlock. A `Bool` can only ever mean "do the thing the framework picked", and the
/// framework is the wrong place to pick.
///
/// ``AESGCMCipher`` covers the common case. Conform your own type for anything else — a key from a
/// secure enclave, an HSM, a server-issued key, or a compression pass alongside the encryption.
///
/// ```swift
/// let cache = OnDiskCache<Session>(lifetime: .to(hours: 1), cipher: AESGCMCipher(key: key))
/// ```
///
/// - Important: A payload cached without a cipher is plaintext JSON readable by anything that can
///   read the container. A cache holding credentials, tokens, or personal data wants one.
public protocol CacheCipher: Sendable {
    /// Transforms the payload for storage.
    /// - Parameter data: The encoded payload.
    /// - Returns: What to write to disk.
    /// - Throws: If the payload cannot be transformed; the write then fails rather than silently
    ///   storing plaintext.
    func encrypt(_ data: Data) throws -> Data

    /// Reverses ``encrypt(_:)``.
    /// - Parameter data: The bytes read from disk.
    /// - Returns: The encoded payload.
    /// - Throws: If the bytes cannot be recovered — a wrong key, a truncated file, a changed
    ///   format. The cache treats that the same as corruption: it discards the file and reports
    ///   itself uninitialized rather than surfacing an error the caller cannot act on.
    func decrypt(_ data: Data) throws -> Data
}
