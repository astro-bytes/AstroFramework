//
//  InMemoryCacheTests.swift
//  GatewayBasicsTests
//
//  Created by Porter McGary on 1/19/24.
//

import XCTest
@testable import GatewayFoundation
import UtilityFoundation
import Mocks

final class InMemoryCacheTests: XCTestCase {
    
    func test_Init_UninitializedResult() throws {
        let store = InMemoryCache<User>(lifetime: 5)
        
        XCTAssertTrue(store.isExpired)
        XCTAssertEqual(store.value, .uninitialized)
        XCTAssertNil(store.cachedDate)
        XCTAssertNil(store.expirationDate)
        XCTAssertEqual(store.lifetime, 5)
    }
    
    func test_IsExpiredWhenExpirationDateIsAfterNow_True() async throws {
        let store = InMemoryCache<User>(lifetime: .to(seconds: 2))
        
        try store.set(.success(data: .johnDoe))
        
        try await Task.sleep(for: .seconds(3))
        
        XCTAssertTrue(store.isExpired)
    }
    
    func test_IsExpiredWhenExpirationDateIsBeforeNow_False() {
        let store = InMemoryCache<User>(lifetime: .to(seconds: 30))
        
        store.cachedDate = .now.addingTimeInterval(.to(seconds: 15))
        
        XCTAssertFalse(store.isExpired)
    }
    
    func test_ExpirationDate_IsCacheTimePlusLifeTime() {
        let lifetime: TimeInterval = 30
        let store = InMemoryCache<User>(lifetime: lifetime)
        let cacheTime = Date.now
        let expirationDate = cacheTime.addingTimeInterval(lifetime)
        
        store.cachedDate = cacheTime
        
        XCTAssertEqual(expirationDate, store.expirationDate)
    }
    
    func test_Set_SuccessfulResult() throws {
        let store = InMemoryCache<User>(lifetime: 30)
        
        try store.set(.success(data: .johnDoe))
        
        XCTAssertNotNil(store.cachedDate)
        XCTAssertNotNil(store.expirationDate)
        XCTAssertFalse(store.isExpired)
        XCTAssertEqual(store.value, .success(data: .johnDoe))
    }
    
    func test_Set_SuccessfulLoading() async throws {
        let store = InMemoryCache<User>(lifetime: 2)
        
        try await Task.sleep(for: .seconds(3))
        
        try store.set(.loading(cachedData: .johnDoe))
        
        XCTAssertNil(store.cachedDate)
        XCTAssertNil(store.expirationDate)
        XCTAssertTrue(store.isExpired, "loading and because its loading the cache is expired.")
        XCTAssertEqual(store.value, .loading(cachedData: .johnDoe))
    }
    
    func test_Set_SuccessfulUninitialized() throws {
        let store = InMemoryCache<User>(lifetime: 30)
        
        try store.set(.uninitialized)
        
        XCTAssertNil(store.cachedDate)
        XCTAssertNil(store.expirationDate)
        XCTAssertTrue(store.isExpired)
        XCTAssertEqual(store.value, .uninitialized)
    }
    
    func test_Set_SuccessfulError() throws {
        let store = InMemoryCache<User>(lifetime: 30)
        let error = NSError(domain: "test", code: 100)
        
        try store.set(.failure(cachedData: .johnDoe, error: error))
        
        XCTAssertNil(store.cachedDate)
        XCTAssertNil(store.expirationDate)
        XCTAssertTrue(store.isExpired, "with an error we should not be fetching this data unless we absolutely need it so mark as expired")
        XCTAssertEqual(store.value, .failure(cachedData: .johnDoe, error: error))
    }
    
    func test_Clear() throws {
        let store = InMemoryCache<User>(lifetime: 30)
        try store.set(.success(data: .johnDoe))
        
        try store.clear()
        
        XCTAssertNil(store.cachedDate)
        XCTAssertNil(store.expirationDate)
        XCTAssertTrue(store.isExpired)
        XCTAssertEqual(store.value, .uninitialized)
    }
    
}
