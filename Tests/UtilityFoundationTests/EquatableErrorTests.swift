//
//  EquatableErrorTests.swift
//  UtilityTests
//
//  Created by Porter McGary on 1/20/24.
//

@testable import Utility
import XCTest

final class EquatableErrorTests: XCTestCase {
    
    // Dummy errors for testing
    struct DummyError: Error, Equatable {
        let message: String
    }
    
    func testEquatableErrorWithEquatableBase() {
        let baseError1 = DummyError(message: "Error 1")
        let baseError2 = DummyError(message: "Error 2")
        
        let equatableError1 = EquatableError(baseError1)
        let equatableError2 = EquatableError(baseError2)
        
        XCTAssertEqual(equatableError1, equatableError1)
        XCTAssertNotEqual(equatableError1, equatableError2)
    }
    
    func testEquatableErrorWithNonEquatableBase() {
        let baseError1 = NSError(domain: "TestDomain", code: 42, userInfo: nil)
        let baseError2 = NSError(domain: "TestDomain2", code: 42, userInfo: nil)
        
        let equatableError1 = EquatableError(baseError1)
        let equatableError2 = EquatableError(baseError2)
        
        XCTAssertEqual(equatableError1, equatableError1)
        XCTAssertNotEqual(equatableError1, equatableError2)
    }
    
    func testAsErrorCasting() {
        let baseError = DummyError(message: "Error")
        
        let equatableError = EquatableError(baseError)
        
        let castedError = equatableError.asError(type: DummyError.self)
        
        XCTAssertEqual(castedError, baseError)
    }
    
    func testLocalizedDescription() {
        let baseError = DummyError(message: "Error")
        
        let equatableError = EquatableError(baseError)
        
        XCTAssertEqual(equatableError.localizedDescription, baseError.localizedDescription)
    }
    
    func testToEquatableErrorExtensionWithEquatable() {
        let baseError = DummyError(message: "Error")
        
        let equatableError = baseError.toEquatableError()
        
        XCTAssertEqual(equatableError.base as? DummyError, baseError)
    }
    
    func testToEquatableErrorExtensionWithNonEquatable() {
        let baseError = NSError(domain: "TestDomain", code: 42, userInfo: nil)
        
        let equatableError = baseError.toEquatableError()
        
        XCTAssertEqual(equatableError.base as NSError, baseError)
    }
}
