//
//  OptionalTests.swift
//  UtilityTests
//
//  Created by Porter McGary on 1/20/24.
//

import XCTest
@testable import UtilityFoundation

final class OptionalTests: XCTestCase {
    
    func testIsNil() {
        let optionalValue: Int? = nil
        XCTAssertTrue(optionalValue.isNil)
        
        let nonNilOptional: String? = "Hello"
        XCTAssertFalse(nonNilOptional.isNil)
    }
    
    func testIsNotNil() {
        let optionalValue: Double? = 42.0
        XCTAssertTrue(optionalValue.isNotNil)
        
        let nilOptional: Bool? = nil
        XCTAssertFalse(nilOptional.isNotNil)
    }
}
