//
//  AnyPublisherExtensionTests.swift
//  UtilityTests
//
//  Created by Porter McGary on 2/9/24.
//

import XCTest
import Combine
@testable import UtilityFoundation

class AnyPublisherExtensionTests: XCTestCase {
    func testFirstExtension_SuccessfulCase() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Value found")
        let subject = PassthroughSubject<Int, Never>()
        let publisher = subject.eraseToAnyPublisher()
        let predicate: (Int) -> Bool = { $0 == 5 }
        let valueToEmit = 5
        
        // When
        Task {
            let value = try await publisher.first(timeoutAfter: .to(seconds: 3), where: predicate)
            XCTAssertEqual(value, valueToEmit)
            expectation.fulfill()
        }
        
        try? await Task.sleep(for: .seconds(1))
        
        // Then
        subject.send(valueToEmit)
        
        await fulfillment(of: [expectation], timeout: 3)
    }
    
    func test_FirstExtensionAfterValueAlreadySent_SuccessfulCase() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Value found")
        // if the subject is a PassThroughSubject this does not work, because the value is not retained.
        let subject = CurrentValueSubject<Int, Never>(5)
        let publisher = subject.eraseToAnyPublisher()
        let predicate: (Int) -> Bool = { $0 == 5 }
        let valueToEmit = 5
        
        // When
        Task {
            let value = try await publisher.first(timeoutAfter: .to(seconds: 3), where: predicate)
            XCTAssertEqual(value, valueToEmit)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 3)
    }
    
    func test_FirstExtensionAfterValueAlreadySent_FailureCase() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Value found")
        // if the subject is a PassThroughSubject this does not work, because the value is not retained.
        let subject = PassthroughSubject<Int, Never>()
        let publisher = subject.eraseToAnyPublisher()
        let predicate: (Int) -> Bool = { $0 == 5 }
        let valueToEmit = 5
        
        subject.send(valueToEmit)
        
        // When
        Task {
            do {
                _ = try await publisher.first(timeoutAfter: .to(seconds: 2), where: predicate)
            } catch {
                XCTAssertTrue(error is CoreError)
                XCTAssertEqual(error as? CoreError, CoreError.timeout)
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 3)
    }
    
    func testFirstExtension_TimeoutCase() async {
        // Given
        let expectation = XCTestExpectation(description: "Timeout")
        let subject = PassthroughSubject<Int, Never>()
        let publisher = subject.eraseToAnyPublisher()
        
        // When
        Task {
            do {
                _ = try await publisher.first(timeoutAfter: 1, scheduler: DispatchQueue.global()) { _ in false }
                XCTFail("Should Throw")
            } catch {
                // Then
                XCTAssertTrue(error is CoreError)
                XCTAssertEqual(error as? CoreError, CoreError.timeout)
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2)
    }
    
    func testFirstExtension_ErrorCase() async {
        // Given
        let expectation1 = XCTestExpectation(description: "Error")
        let expectation2 = XCTestExpectation(description: "Error")
        let subject = PassthroughSubject<Int, TestError>()
        let publisher = subject.eraseToAnyPublisher()
        let errorToEmit = CoreError.timeout
        
        // When
        Task {
            do {
                _ = try await publisher.first(timeoutAfter: 1, scheduler: DispatchQueue.global()) { _ in false }
                XCTFail("Should Throw")
            } catch {
                // Then
                XCTAssertTrue(error is CoreError)
                XCTAssertEqual(error as? CoreError, errorToEmit)
                expectation1.fulfill()
            }
        }
        
        subject.send(2)
        
        Task {
            do {
                _ = try await publisher.first(timeoutAfter: 1, scheduler: DispatchQueue.global()) { _ in false }
                XCTFail("Should Throw")
            } catch {
                // Then
                XCTAssertTrue(error is CoreError)
                XCTAssertEqual(error as? CoreError, errorToEmit)
                expectation2.fulfill()
            }
        }
        
        try? await Task.sleep(for: .seconds(2))
        
        subject.send(1)
        
        await fulfillment(of: [expectation1, expectation2], timeout: 5)
    }
}
