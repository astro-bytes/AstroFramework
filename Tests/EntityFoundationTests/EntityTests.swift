//
//  EntityTests.swift
//  EntityFoundationTests
//
//  Created by Porter McGary on 1/20/24.
//

import XCTest
import EntityFoundation
import Mocks

/// `Entity` is one line with no body, so what is worth testing is what conforming to it buys you
/// and what it costs. The module's only test used to be an empty `testExample()`.
final class EntityTests: XCTestCase {

    // MARK: What conformance provides

    func testAnEntityIsIdentifiable() {
        let user = User.johnDoe

        XCTAssertEqual(user.id, user.id)
        XCTAssertNotEqual(User.johnDoe.id, User.janeDoe.id)
    }

    func testAnEntityIsEquatableByValue() {
        let id = UUID()

        XCTAssertEqual(User(id: id, name: "A", age: 1), User(id: id, name: "A", age: 1))
        XCTAssertNotEqual(User(id: id, name: "A", age: 1), User(id: id, name: "B", age: 1))
    }

    /// Equality is over every stored property, not identity alone — two entities with the same ID
    /// and different contents are different values.
    func testTwoEntitiesSharingAnIDAreNotAutomaticallyEqual() {
        let id = UUID()

        XCTAssertNotEqual(User(id: id, name: "A", age: 1), User(id: id, name: "A", age: 2))
    }

    func testAnEntityIsHashableAndUsableAsAKey() {
        var counts: [User: Int] = [:]
        counts[.johnDoe, default: 0] += 1
        counts[.johnDoe, default: 0] += 1
        counts[.janeDoe, default: 0] += 1

        XCTAssertEqual(counts[.johnDoe], 2)
        XCTAssertEqual(counts[.janeDoe], 1)
        XCTAssertEqual(Set([User.johnDoe, .johnDoe, .janeDoe]).count, 2)
    }

    func testEqualEntitiesHashEqually() {
        let id = UUID()

        XCTAssertEqual(User(id: id, name: "A", age: 1).hashValue,
                       User(id: id, name: "A", age: 1).hashValue)
    }

    // MARK: What conformance requires

    /// `Entity` requires `Sendable`, and a `Sendable` ID with it — an entity crosses concurrency
    /// domains as a matter of course, out of a repository and into a view. This compiling is the
    /// assertion.
    func testAnEntityCanCrossAConcurrencyDomain() async {
        let user = User.johnDoe

        let received = await Task.detached { user }.value

        XCTAssertEqual(received, user)
    }

    func testAnEntityIsAcceptedWhereSendableIsRequired() {
        func requiresSendable<Value: Sendable>(_ value: Value) -> Value { value }

        XCTAssertEqual(requiresSendable(User.johnDoe), .johnDoe)
    }

    // MARK: Different entity types

    func testDistinctEntityTypesAreIndependent() {
        XCTAssertEqual(Car.civic, Car.civic)
        XCTAssertNotEqual(Car.civic, Car.model3)
        XCTAssertEqual(Set([Car.civic, .model3]).count, 2)
    }
}
