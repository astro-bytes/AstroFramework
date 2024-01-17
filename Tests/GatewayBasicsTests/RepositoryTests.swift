//
//  RepositoryTests.swift
//  GatewayBasicsTests
//
//  Created by Porter McGary on 1/16/24.
//

import XCTest
import GatewayBasics
import Mocks

final class RepositoryTests: XCTestCase {
    
    // MARK: Synchronous Tests
    func test_SuccessfulSet_ChangesValueInDataStore() {
//        let userRepo = UserRepository()
//        let usersRepo = UsersRepository()
//        let expected = User(name: "Johnny Lingo", age: 14)
//        
//        userRepo.set(expected)
//        let result = usersRepo.get()
//        
//        switch result {
//        case .uninitialized:
//            XCTFail("Users Repository should not be uninitialized")
//        case .loading:
//            XCTFail("Users Repository should not be loading")
//        case .success(data: let users):
//            XCTAssertEqual(userRepo.user?.name, expected.name)
//            XCTAssertEqual(userRepo.user?.age, expected.age)
//            XCTAssertEqual(usersRepo.users, [expected])
//            XCTAssertEqual(users, [expected])
//        case .failure:
//            XCTFail("Users Repository should not fail to get users")
//        }
    }
    
    func test_SetFailureWithPreexistingData_FailureResultWithCacheValue() {
        XCTFail()
    }
    
    func test_SetFailureWithNoData_FailureResultWithNilCache() {
        XCTFail()
    }
    
    // MARK: Asynchronous Tests
    
}
