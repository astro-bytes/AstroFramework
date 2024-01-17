//
//  RepositoryTests.swift
//  GatewayBasicsTests
//
//  Created by Porter McGary on 1/16/24.
//

import XCTest
import GatewayBasics

final class RepositoryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let repo = UserRepository()
        repo.set(.johnDoe)
        XCTAssertEqual(repo.user, .johnDoe)
    }
    
    func testUsers() {
        let userRepo = UserRepository()
        let usersRepo = UsersRepository()
        let usecase = CreateUser(userRepo: userRepo, usersRepo: usersRepo)
        let expected = User(name: "Johnny Lingo", age: 14)
        let users = usecase.execute(name: expected.name, age: expected.age)
        XCTAssertEqual(userRepo.user?.name, expected.name)
        XCTAssertEqual(userRepo.user?.age, expected.age)
        XCTAssertEqual(users, [expected])
        XCTAssertEqual(usersRepo.users, [expected])
    }

}
