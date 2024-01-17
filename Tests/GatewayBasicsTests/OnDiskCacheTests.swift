//
//  OnDiskCacheTests.swift
//  GatewayBasicsTests
//
//  Created by Porter McGary on 1/17/24.
//

import XCTest
@testable import GatewayBasics
import Logger
import Mocks

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
        let store = OnDiskCache<User>(name: "test", lifetime: 5)
        try store.set(.success(data: .janeDoe))
        
        let secondStore = OnDiskCache<Car>(name: "test", lifetime: 5)
        
        XCTAssertNil(secondStore.value.error, "No error should be passed along when there is a decoding error")
        XCTAssertNil(secondStore.value.payload, "No cache in this instance should also be passed since the cache has been corrupted")
        let url = try store.cacheFileURL()
        XCTAssertFalse(url.isFile, "The files should not exist")
        XCTAssertThrowsError(try Data(contentsOf: url), "File should not contain any data")
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
    
}
