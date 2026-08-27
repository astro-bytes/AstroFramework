//
//  OnDiskCacheTests.swift
//  GatewayFoundationTests
//
//  Created by Porter McGary on 1/17/24.
//

import XCTest
@testable import GatewayFoundation
import LoggerFoundation
import Mocks
import UseCaseFoundation
import UtilityFoundation

final class OnDiskCacheTests: XCTestCase {
    
    override func tearDown() {
        let store = OnDiskCache<User>(lifetime: 0)
        do {
            try store.clear()
        } catch {
            Logger.log(.critical, error: error)
        }
    }
    
    func test_SuccessfulInitNotExpired_SuccessResult() throws {
        let user = User.janeDoe
        let store = OnDiskCache<User>(lifetime: .to(seconds: 30))
        try store.set(.success(data: user))
        
        let secondStore = OnDiskCache<User>(lifetime: .to(seconds: 30))
        
        XCTAssertFalse(secondStore.isExpired)
        XCTAssertEqual(secondStore.value, .success(data: user))
    }
    
    func test_SuccessfulInitNotExpired_DecodingErrorResult() throws {
        do {
            let store = OnDiskCache<User>(name: "test", lifetime: 5)
            try store.set(.success(data: .janeDoe))
            
            let secondStore = OnDiskCache<Car>(name: "test", lifetime: 5)
            
            XCTAssertNil(secondStore.value.error, "No error should be passed along when there is a decoding error")
            XCTAssertNil(secondStore.value.payload, "No cache in this instance should also be passed since the cache has been corrupted")
            
            var url: URL? = nil
            url = try store.cacheFileURL()
            if let url {
                XCTAssertFalse(url.isFile, "The file should not exist")
            }
            
            guard let url else { return }
            _ = try Data(contentsOf: url)
            XCTFail("No data should be found in the file")
        } catch CocoaError.fileReadNoSuchFile {
            // Pass
        } catch {
            XCTFail("No error should be thrown here - \(String(describing: error))")
        }
    }
    
    func test_SuccessfulInitExpired_LoadingResult() async throws {
        let user = User.janeDoe
        let store = OnDiskCache<User>(lifetime: 3)
        try store.set(.success(data: user))
        
        try await Task.sleep(for: .seconds(2))
        
        let secondStore = OnDiskCache<User>(lifetime: 1)
        
        XCTAssertEqual(secondStore.lifetime, 1)
        XCTAssertTrue(secondStore.isExpired)
        XCTAssertNotNil(secondStore.cachedDate)
        XCTAssertNotNil(secondStore.expirationDate)
        XCTAssertNotNil(secondStore.value.payload)
        XCTAssertEqual(secondStore.value, .loading(cachedData: user))
    }
    
    func test_SuccessfulInitExpired_UninitializedResult() async throws {
        let user = User.janeDoe
        let store = OnDiskCache<User>(lifetime: 3)
        try store.set(.success(data: user))
        
        try await Task.sleep(for: .seconds(2))
        
        let secondStore = OnDiskCache<User>(lifetime: 1, invalidateImmediately: true)
        
        XCTAssertEqual(secondStore.lifetime, 1)
        XCTAssertTrue(secondStore.isExpired)
        XCTAssertNil(secondStore.cachedDate, "Should be nil because the cache is cleared")
        XCTAssertNil(secondStore.expirationDate, "Should be nil because cache is nil")
        XCTAssertNil(secondStore.value.payload)
        XCTAssertEqual(secondStore.value, .uninitialized)
    }
    
    func test_SetSuccess() throws {
        let user = User.johnDoe
        let store = OnDiskCache<User>(lifetime: 30)
        
        try store.set(.success(data: user))
        
        XCTAssertEqual(store.value, .success(data: user))
        XCTAssertFalse(store.isExpired)
        XCTAssertNotNil(store.cachedDate)
        XCTAssertNotNil(store.expirationDate)
        let url = try store.cacheFileURL()
        XCTAssertTrue(url.isFile)
        XCTAssertNoThrow(try Data(contentsOf: url))
    }
    
    func testClear() throws {
        let user = User.johnDoe
        let store = OnDiskCache<User>(lifetime: 30)
        try store.set(.success(data: user))
        
        try store.clear()
        
        XCTAssertEqual(store.value, .uninitialized)
        XCTAssertTrue(store.isExpired)
        XCTAssertNil(store.cachedDate)
        XCTAssertNil(store.expirationDate)
        let url = try store.cacheFileURL()
        XCTAssertFalse(url.isFile)
        XCTAssertThrowsError(try Data(contentsOf: url))
    }

    // MARK: Expiry

    /// Loading a cache must not restart its expiry clock.
    ///
    /// `init` used to hand the loaded value to `super.set`, which stamps `cachedDate` with the
    /// load time. Every construction pushed the expiry forward by a full lifetime, so a cache
    /// re-created more often than its lifetime never went stale and never refetched.
    func test_ReloadingDoesNotRenewTheExpiryClock() throws {
        let name = "renewal-\(UUID().uuidString)"
        let first = OnDiskCache<User>(name: name, lifetime: 30)
        try first.set(.success(data: .johnDoe))
        let writtenAt = try XCTUnwrap(first.cachedDate)

        let second = OnDiskCache<User>(name: name, lifetime: 30)

        XCTAssertEqual(second.cachedDate, writtenAt, "reloading moved the expiry clock forward")
        try second.clear()
    }

    /// The end the renewal bug was hiding: a value written outside its lifetime reads as expired,
    /// however many times the cache has been constructed in between.
    func test_ValueOlderThanItsLifetimeIsExpiredAfterRepeatedReloads() async throws {
        let name = "expiry-\(UUID().uuidString)"
        let writer = OnDiskCache<User>(name: name, lifetime: 1)
        try writer.set(.success(data: .johnDoe))

        // Reload twice inside the lifetime — each one used to buy another full lifetime.
        try await Task.sleep(for: .milliseconds(400))
        _ = OnDiskCache<User>(name: name, lifetime: 1)
        try await Task.sleep(for: .milliseconds(400))
        _ = OnDiskCache<User>(name: name, lifetime: 1)
        try await Task.sleep(for: .milliseconds(400))

        let final = OnDiskCache<User>(name: name, lifetime: 1)

        XCTAssertTrue(final.isExpired, "cache outlived its lifetime because reloads kept renewing it")
        XCTAssertEqual(final.value, .loading(cachedData: .johnDoe), "expired value stays available as cached data")
        try final.clear()
    }

    // MARK: Writing

    /// A non-success result takes the file with it, so disk and memory cannot disagree.
    func test_SettingANonSuccessResultRemovesTheFile() throws {
        let name = "non-success-\(UUID().uuidString)"
        let store = OnDiskCache<User>(name: name, lifetime: 30)
        try store.set(.success(data: .johnDoe))
        XCTAssertTrue(try store.cacheFileURL().isFile)

        try store.set(.failure(cachedData: nil, error: CoreError.notFound))

        XCTAssertFalse(try store.cacheFileURL().isFile)
        XCTAssertNil(store.cachedDate)
    }

    /// `set` reports a failed write instead of logging it and returning as though it had worked.
    func test_SetPropagatesAnEncodingFailure() throws {
        struct Unencodable: Codable {
            func encode(to encoder: any Encoder) throws { throw CoreError.notFound }
            init() {}
            init(from decoder: any Decoder) throws { self.init() }
        }

        let store = OnDiskCache<Unencodable>(name: "unencodable-\(UUID().uuidString)", lifetime: 30)

        XCTAssertThrowsError(try store.set(.success(data: Unencodable())))
        try? store.clear()
    }

    /// Clearing a cache that was never written is not an error.
    func test_ClearingAnEmptyCacheDoesNotThrow() {
        let store = OnDiskCache<User>(name: "never-written-\(UUID().uuidString)", lifetime: 30)

        XCTAssertNoThrow(try store.clear())
    }

    /// Two caches naming different payloads do not read each other's files.
    func test_CachesAreKeyedByName() throws {
        let users = OnDiskCache<User>(name: "keyed-users-\(UUID().uuidString)", lifetime: 30)
        let cars = OnDiskCache<Car>(name: "keyed-cars-\(UUID().uuidString)", lifetime: 30)

        try users.set(.success(data: .johnDoe))
        try cars.set(.success(data: .civic))

        XCTAssertEqual(users.value, .success(data: .johnDoe))
        XCTAssertEqual(cars.value, .success(data: .civic))

        try users.clear()
        try cars.clear()
    }
}
