//
//  RepositoryTests.swift
//  UseCaseFoundationTests
//
//  Created by Porter McGary on 2/9/24.
//

import XCTest
import Mocks
@testable import UseCaseFoundation
import UtilityFoundation

class RepositoryTests: XCTestCase {
    
    // Test the success case where data is successfully retrieved
    func _testGet_Success() async throws {
        // Given
        let expectedData = User.johnDoe // Use provided mock payload
        var mockRepository: MockRepository<User> = MockRepository<User>(.uninitialized)
        mockRepository = MockRepository<User>(.success(data: expectedData))
        
        // When
        let result = try await mockRepository.get()
        
        // Then
        XCTAssertEqual(result, expectedData)
    }
    
    // Test the case where the data is uninitialized
    func _testGet_Uninitialized() async throws {
        // When, Then
        do {
            let mockRepository: MockRepository<User> = MockRepository<User>(.uninitialized)
            _ = try await mockRepository.get()
        } catch {
            XCTAssertEqual(error as? CoreError, .notFound)
        }
    }
    
    // Test the case where the data is still loading
    func _testGet_Loading() async throws {
        // Given
        let mockRepository = MockRepository<User>(.loading(cachedData: nil))
        
        // When, Then
        do {
            _ = try await mockRepository.get()
        } catch {
            XCTAssertEqual(error as? CoreError, .timeout)
        }
    }
    
    // Test the case where the data is still loading
    func _testGet_LoadingToSuccess() async throws {
        // Given
        let mockRepository = MockRepository<User>(.loading(cachedData: nil))
        let expectation = expectation(description: "Should have value")
        
        // When, Then
        Task {
            do {
                let value = try await mockRepository.get()
                XCTAssertEqual(value, .janeDoe)
            } catch {
                XCTFail("Unexpected Failure: \(error)")
            }
            expectation.fulfill()
        }
        
        mockRepository.set(.janeDoe)
        
        await fulfillment(of: [expectation], timeout: 6)
    }
    
    // Test the case where data retrieval fails
    func _testGet_Failure() async throws {
        // Given
        let expectedError = CoreError.notFound
        let mockRepository = MockRepository<User>(.failure(cachedData: nil, error: expectedError))
        
        // When, Then
        do {
            _ = try await mockRepository.get()
        } catch {
            XCTAssertEqual(error as? CoreError, expectedError)
        }
    }
}
