//
//  KeyedRepositoryTests.swift
//  UseCaseFoundationTests
//
//  Created by Porter McGary on 2/9/24.
//

import XCTest
import Combine
import Mocks
@testable import UseCaseFoundation
import UtilityFoundation

class KeyedRepositoryTests: XCTestCase {
    
    var mockRepository: MockKeyedRepository<User>!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockKeyedRepository<User>(.uninitialized)
    }
    
    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }
    
    // Test the success case where data is successfully retrieved by ID
    func testGetByID_Success() async throws {
        // Given
        let expectedID = User.johnDoe.id
        let expectedData = User.johnDoe
        mockRepository = MockKeyedRepository<User>(.success(data: [expectedID: expectedData]))
        
        // When
        let result = try await mockRepository.get(by: expectedID)
        
        // Then
        XCTAssertEqual(result, expectedData)
    }
    
    // Test the case where the data is uninitialized when retrieving by ID
    func testGetByID_Uninitialized() async throws {
        // When, Then
        do {
             _ = try await mockRepository.get(by: UUID())
            XCTFail("Should Throw")
        } catch {
            XCTAssertEqual(error as? CoreError, .notFound)
        }
    }
    
    // Test the case where the data is still loading when retrieving by ID
    func testGetByID_Loading() async throws {
        // Given
        mockRepository = MockKeyedRepository<User>(.loading(cachedData: nil))
        
        // When, Then
        do {
            _ = try await mockRepository.get(by: UUID())
            XCTFail("Should Throw")
        } catch {
            XCTAssertEqual(error as? CoreError, .timeout)
        }
    }
    
    // Test the case where data retrieval fails when retrieving by ID
    func testGetByID_Failure() async throws {
        // Given
        let expectedError = CoreError.notFound
        mockRepository = MockKeyedRepository<User>(.failure(cachedData: nil, error: expectedError))
        
        // When, Then
        do {
            _ = try await mockRepository.get(by: UUID())
            XCTFail("Should Throw")
        } catch {
            XCTAssertEqual(error as? CoreError, expectedError)
        }
    }
}
