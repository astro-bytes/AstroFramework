//
//  CacheCipherTests.swift
//  GatewayFoundationTests
//
//  Created by Porter McGary on 8/27/26.
//

import CryptoKit
import XCTest
import Mocks
import UseCaseFoundation
import UtilityFoundation
@testable import GatewayFoundation

final class CacheCipherTests: XCTestCase {

    private func name(_ label: String) -> String { "\(label)-\(UUID().uuidString)" }

    // MARK: AESGCMCipher

    func testAESGCMRoundTripsData() throws {
        let cipher = AESGCMCipher(key: SymmetricKey(size: .bits256))
        let plaintext = Data("the quick brown fox".utf8)

        let sealed = try cipher.encrypt(plaintext)
        XCTAssertEqual(try cipher.decrypt(sealed), plaintext)
    }

    func testAESGCMCiphertextDoesNotContainThePlaintext() throws {
        let cipher = AESGCMCipher(key: SymmetricKey(size: .bits256))
        let plaintext = Data("sk_live_topsecret".utf8)

        let sealed = try cipher.encrypt(plaintext)

        XCTAssertNil(sealed.range(of: plaintext))
        XCTAssertNotEqual(sealed, plaintext)
    }

    func testAESGCMFailsWithTheWrongKey() throws {
        let sealed = try AESGCMCipher(key: SymmetricKey(size: .bits256)).encrypt(Data("hello".utf8))

        XCTAssertThrowsError(try AESGCMCipher(key: SymmetricKey(size: .bits256)).decrypt(sealed))
    }

    /// GCM authenticates as well as encrypts, so a tampered file fails to open rather than
    /// decrypting to something plausible.
    func testAESGCMRejectsTamperedCiphertext() throws {
        let cipher = AESGCMCipher(key: SymmetricKey(size: .bits256))
        var sealed = try cipher.encrypt(Data("hello".utf8))

        sealed[sealed.count - 1] ^= 0xFF

        XCTAssertThrowsError(try cipher.decrypt(sealed))
    }

    func testAESGCMEncryptsTheSamePlaintextDifferentlyEachTime() throws {
        let cipher = AESGCMCipher(key: SymmetricKey(size: .bits256))
        let plaintext = Data("repeated".utf8)

        XCTAssertNotEqual(try cipher.encrypt(plaintext), try cipher.encrypt(plaintext))
    }

    // MARK: OnDiskCache with a cipher

    func testAnEncryptedCacheRoundTripsAcrossInstances() throws {
        let key = SymmetricKey(size: .bits256)
        let cacheName = name("encrypted")

        let writer = OnDiskCache<User>(name: cacheName, lifetime: 30, cipher: AESGCMCipher(key: key))
        try writer.set(.success(data: .johnDoe))

        let reader = OnDiskCache<User>(name: cacheName, lifetime: 30, cipher: AESGCMCipher(key: key))

        XCTAssertEqual(reader.value, .success(data: .johnDoe))
        XCTAssertEqual(reader.cachedDate, writer.cachedDate, "the write date survives the envelope")
        try reader.clear()
    }

    /// The point of the whole exercise: what lands on disk is not readable.
    func testTheFileOnDiskDoesNotContainThePayload() throws {
        let cacheName = name("opaque")
        let cache = OnDiskCache<User>(name: cacheName, lifetime: 30, cipher: AESGCMCipher(key: SymmetricKey(size: .bits256)))

        try cache.set(.success(data: .johnDoe))

        let bytes = try Data(contentsOf: cache.cacheFileURL())
        XCTAssertNil(bytes.range(of: Data("John Doe".utf8)), "the payload is on disk in the clear")
        XCTAssertNil(bytes.range(of: Data("name".utf8)), "the JSON keys are on disk in the clear")
        try cache.clear()
    }

    /// Without a cipher the file is plaintext JSON. Asserted so the default is a documented
    /// property rather than an accident.
    func testWithoutACipherTheFileIsPlaintextJSON() throws {
        let cache = OnDiskCache<User>(name: name("plaintext"), lifetime: 30)

        try cache.set(.success(data: .johnDoe))

        let bytes = try Data(contentsOf: cache.cacheFileURL())
        XCTAssertNotNil(bytes.range(of: Data("John Doe".utf8)))
        try cache.clear()
    }

    /// A rotated or lost key costs a refetch, not a crash.
    func testAWrongKeyDiscardsTheCacheRatherThanFailing() throws {
        let cacheName = name("rotated")

        let writer = OnDiskCache<User>(name: cacheName, lifetime: 30, cipher: AESGCMCipher(key: SymmetricKey(size: .bits256)))
        try writer.set(.success(data: .johnDoe))

        let reader = OnDiskCache<User>(name: cacheName, lifetime: 30, cipher: AESGCMCipher(key: SymmetricKey(size: .bits256)))

        XCTAssertEqual(reader.value, .uninitialized)
        XCTAssertNil(reader.value.error, "an unreadable cache is not an error the caller can act on")
        XCTAssertFalse(try reader.cacheFileURL().isFile, "the unusable file is cleared")
    }

    /// Reading an encrypted cache without the cipher is the same situation as the wrong key.
    func testReadingAnEncryptedCacheWithoutACipherDiscardsIt() throws {
        let cacheName = name("mismatched")

        let writer = OnDiskCache<User>(name: cacheName, lifetime: 30, cipher: AESGCMCipher(key: SymmetricKey(size: .bits256)))
        try writer.set(.success(data: .johnDoe))

        let reader = OnDiskCache<User>(name: cacheName, lifetime: 30)

        XCTAssertEqual(reader.value, .uninitialized)
    }

    /// A cipher that throws fails the write, rather than quietly storing plaintext.
    func testAFailingCipherFailsTheWrite() throws {
        let cache = OnDiskCache<User>(name: name("failing"), lifetime: 30, cipher: FailingCipher())

        XCTAssertThrowsError(try cache.set(.success(data: .johnDoe))) { error in
            XCTAssertEqual(error as? CoreError, .notFound)
        }
        XCTAssertFalse(try cache.cacheFileURL().isFile, "nothing was written")
    }

    /// A cipher is free to be anything — the framework only asks for two functions.
    func testACustomCipherIsUsedForBothDirections() throws {
        let cacheName = name("custom")
        let cache = OnDiskCache<User>(name: cacheName, lifetime: 30, cipher: ReversingCipher())

        try cache.set(.success(data: .johnDoe))
        let bytes = try Data(contentsOf: cache.cacheFileURL())
        XCTAssertNil(bytes.range(of: Data("John Doe".utf8)))

        let reader = OnDiskCache<User>(name: cacheName, lifetime: 30, cipher: ReversingCipher())
        XCTAssertEqual(reader.value, .success(data: .johnDoe))
        try reader.clear()
    }

    func testAnEncryptedCacheStillExpires() throws {
        let key = SymmetricKey(size: .bits256)
        let cacheName = name("expiring")

        let writer = OnDiskCache<User>(name: cacheName, lifetime: 0, cipher: AESGCMCipher(key: key))
        try writer.set(.success(data: .johnDoe))

        let reader = OnDiskCache<User>(name: cacheName, lifetime: 0, cipher: AESGCMCipher(key: key))

        XCTAssertTrue(reader.isExpired)
        XCTAssertEqual(reader.value, .loading(cachedData: .johnDoe))
        try reader.clear()
    }
}

// MARK: - Stub ciphers

private struct FailingCipher: CacheCipher {
    func encrypt(_ data: Data) throws -> Data { throw CoreError.notFound }
    func decrypt(_ data: Data) throws -> Data { throw CoreError.notFound }
}

/// Not encryption — just a transform, to show the protocol does not assume one.
private struct ReversingCipher: CacheCipher {
    func encrypt(_ data: Data) throws -> Data { Data(data.reversed()) }
    func decrypt(_ data: Data) throws -> Data { Data(data.reversed()) }
}
