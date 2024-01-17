//
//  CollectionTests.swift
//  UtilityTests
//
//  Created by Porter McGary on 1/19/24.
//

import Mocks
import Utility
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
    
    func test_Mapping() {
        XCTFail("Implement")
    }
    
}


