//
//  ResultTests.swift
//  UtilityTests
//
//  Created by Porter McGary on 1/22/24.
//

import XCTest

final class ResultTests: XCTestCase {
    func testValueProperty() {
        let successResult: Result<Int, TestError> = .success(42)
        XCTAssertEqual(successResult.value, 42)
        
        let failureResult: Result<Int, TestError> = .failure(TestError.genericError)
        XCTAssertNil(failureResult.value)
    }
    
    func testErrorProperty() {
        let successResult: Result<Int, TestError> = .success(42)
        XCTAssertNil(successResult.error)
        
        let failureResult: Result<Int, TestError> = .failure(TestError.genericError)
        XCTAssertEqual(failureResult.error, TestError.genericError)
    }
}

enum TestError: Error, Equatable {
    case genericError
}
