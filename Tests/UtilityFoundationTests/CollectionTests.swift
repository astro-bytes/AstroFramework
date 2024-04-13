//
//  CollectionTests.swift
//  UtilityTests
//
//  Created by Porter McGary on 1/19/24.
//

import Mocks
import UtilityFoundation
import XCTest

final class CollectionTests: XCTestCase {
    
    func test_FirstByIdOnEmptyList_Nil() {
        let users = [User]()
        XCTAssertNil(users.first(by: User.johnDoe.id))
    }
    
    func test_FirstByIdOnNotEmptyList_Nil() {
        let users = [User.janeDoe]
        XCTAssertNil(users.first(by: User.johnDoe.id))
    }
    
    func test_FirstByIdOnNotEmptyList_Value() {
        let users = [User.janeDoe]
        XCTAssertEqual(users.first(by: User.janeDoe.id), User.janeDoe)
    }
    
    func test_FilterOutByIdOnEmptyList_EmptyList() {
        let users = [User]()
        XCTAssertTrue(users.filterOut(User.janeDoe.id).isEmpty)
    }
    
    func test_FilterOutById_NotEmptyList() {
        let users = [User.janeDoe, User.johnDoe]
        XCTAssertFalse(users.filterOut(User.janeDoe.id).isEmpty)
        XCTAssertEqual(users.filterOut(User.janeDoe.id).count, 1)
        XCTAssertEqual(users.filterOut(User.janeDoe.id).first, User.johnDoe)
    }
    
    func test_FilterOutById_EmptyList() {
        let users = [User.johnDoe]
        XCTAssertTrue(users.filterOut(User.johnDoe.id).isEmpty)
    }
    
    func test_FirstIndexById_Nil() {
        let users = [User.johnDoe]
        XCTAssertNil(users.firstIndex(by: User.janeDoe.id))
    }
    
    func test_FirstIndexById_NotNil() {
        let users = [User.johnDoe, User.janeDoe, User.johnDoe]
        XCTAssertNotNil(users.firstIndex(by: User.johnDoe.id))
        XCTAssertEqual(users.firstIndex(by: User.johnDoe.id), 0)
        XCTAssertEqual(users.firstIndex(by: User.janeDoe.id), 1)
    }
    
    func test_FirstOfType_NotNil() {
        // Arrange
        let numbers: [Any] = [1, "two", 3, "four", 5]
        
        // Act
        let result = numbers.first(of: Int.self)
        
        // Assert
        XCTAssertEqual(result, 1, "The result should be the first element of type Int, which is 1.")
    }
    
    func test_FirstOfType_Nil() {
        // Arrange
        let elements: [Any] = ["one", "two", "three", "four", "five"]
        
        // Act
        let result = elements.first(of: Int.self)
        
        // Assert
        XCTAssertNil(result, "The result should be nil since there is no element of type Int.")
    }
    
    // Dummy types for testing
    struct TestType: Equatable {
        let value: Int
    }
    
    // Dummy async transformations for testing
    func asyncTransformation(element: Int) async -> TestType? {
        return TestType(value: element * 2)
    }
    
    func asyncThrowingTransformation(element: Int) async throws -> TestType? {
        guard element % 2 == 0 else {
            throw AsyncTransformationError.invalidElement
        }
        return TestType(value: element * 2)
    }
    
    // Dummy async reduction function for testing
    func asyncReduceFunction(result: inout Int, element: Int) async {
        result += element
    }
    
    // MARK: - asyncCompactMap tests
    
    func testAsyncCompactMap() async {
        let input = [1, 2, 3, 4, 5]
        
        let result = await input.asyncCompactMap { await asyncTransformation(element: $0) }
        
        XCTAssertEqual(result, [TestType(value: 2), TestType(value: 4), TestType(value: 6), TestType(value: 8), TestType(value: 10)])
    }
    
    func testAsyncCompactMapWithThrowing() async {
        let input = [1, 2, 3, 4, 5]
        
        let result = await input.asyncCompactMap { try? await asyncThrowingTransformation(element: $0) }
        XCTAssertEqual(result, [TestType(value: 4), TestType(value: 8)])
    }
    
    // MARK: - asyncMap tests
    
    func testAsyncMap() async {
        let input = [1, 2, 3, 4, 5]
        
        let result = await input.asyncMap { await asyncTransformation(element: $0)! }
        
        XCTAssertEqual(result, [TestType(value: 2), TestType(value: 4), TestType(value: 6), TestType(value: 8), TestType(value: 10)])
    }
    
    func testAsyncMapWithThrowing() async {
        let input = [1, 2, 3, 4, 5]
        
        let result = await input.asyncMap { try? await asyncThrowingTransformation(element: $0)! }
        XCTAssertEqual(result, [nil, TestType(value: 4), nil, TestType(value: 8), nil])
    }
    
    // MARK: - asyncReduce tests
    
    func testAsyncReduce() async {
        let input = [1, 2, 3, 4, 5]
        
        let result = await input.asyncReduce(into: 0) { await asyncReduceFunction(result: &$0, element: $1) }
        
        XCTAssertEqual(result, 15)
    }
    
    func testAsyncReduceWithThrowing() async {
        let input = [2, 4, 6, 8, 10]
        
        do {
            let result = try await input.asyncReduce(into: 0) { result, element in
                guard element % 2 == 0 else {
                    throw AsyncTransformationError.invalidElement
                }
                await asyncReduceFunction(result: &result, element: element)
            }
            XCTAssertEqual(result, 30)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
}

enum AsyncTransformationError: Error {
    case invalidElement
}
