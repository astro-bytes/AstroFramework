//
//  DataResultTests.swift
//  UseCaseBasicsTests
//
//  Created by Porter McGary on 1/20/24.
//

@testable import UseCaseBasics
import XCTest

final class DataResultTests: XCTestCase {
    
    func testPayload() {
        let uninitializedResult: DataResult<String> = .uninitialized
        XCTAssertNil(uninitializedResult.payload)
        
        let loadingResult: DataResult<String> = .loading(cachedData: "cached")
        XCTAssertEqual(loadingResult.payload, "cached")
        
        let successResult: DataResult<String> = .success(data: "success")
        XCTAssertEqual(successResult.payload, "success")
        
        let failureResult: DataResult<String> = .failure(cachedData: "cached", error: TestError.someError)
        XCTAssertEqual(failureResult.payload, "cached")
    }
    
    func testError() {
        let uninitializedResult: DataResult<String> = .uninitialized
        XCTAssertNil(uninitializedResult.error)
        
        let loadingResult: DataResult<String> = .loading(cachedData: "cached")
        XCTAssertNil(loadingResult.error)
        
        let successResult: DataResult<String> = .success(data: "success")
        XCTAssertNil(successResult.error)
        
        let failureResult: DataResult<String> = .failure(cachedData: "cached", error: TestError.someError)
        XCTAssertEqual(failureResult.error as? TestError, TestError.someError)
    }
    
    func testIsLoading() {
        let uninitializedResult: DataResult<String> = .uninitialized
        XCTAssertFalse(uninitializedResult.isLoading)
        
        let loadingResult: DataResult<String> = .loading(cachedData: "cached")
        XCTAssertTrue(loadingResult.isLoading)
        
        let successResult: DataResult<String> = .success(data: "success")
        XCTAssertFalse(successResult.isLoading)
        
        let failureResult: DataResult<String> = .failure(cachedData: "cached", error: TestError.someError)
        XCTAssertFalse(failureResult.isLoading)
    }
}

// Placeholder for a custom error used in the tests
enum TestError: Error {
    case someError
}

