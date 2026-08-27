//
//  DataSourceTests.swift
//  GatewayFoundationTests
//
//  Created by Porter McGary on 8/27/26.
//

import XCTest
import Mocks
import UtilityFoundation
@testable import GatewayFoundation

/// The data source protocols have no default implementations, so what is worth pinning is that one
/// convention holds across all of them: asynchronous, and failing by throwing.
///
/// They used to disagree — `DataSource` returned a `Result` synchronously, `DynamicDataSource`
/// threw, and `MutableDataSource` returned a `Result` asynchronously while its writes threw.
final class DataSourceTests: XCTestCase {

    func testADataSourceReturnsItsPayload() async throws {
        let source = StubDataSource(result: .success(.johnDoe))

        let payload = try await source.fetch()

        XCTAssertEqual(payload, .johnDoe)
    }

    func testADataSourceThrowsItsFailure() async {
        let source = StubDataSource(result: .failure(CoreError.notFound))

        do {
            _ = try await source.fetch()
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual(error as? CoreError, .notFound)
        }
    }

    func testADynamicDataSourceFetchesForItsArguments() async throws {
        let source = StubDynamicDataSource()

        let fetched = try await source.fetch(User.johnDoe.id)
        XCTAssertEqual(fetched, .johnDoe)
    }

    func testADynamicDataSourceThrowsWhenTheArgumentsMatchNothing() async {
        let source = StubDynamicDataSource()

        do {
            _ = try await source.fetch(UUID())
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual(error as? CoreError, .notFound)
        }
    }

    func testAMutableDataSourceRoundTripsAnElement() async throws {
        let source = StubMutableDataSource()

        try await source.insert(.johnDoe)

        let fetched = try await source.fetch(id: User.johnDoe.id)
        let all = try await source.fetch()
        XCTAssertEqual(fetched, .johnDoe)
        XCTAssertEqual(all.count, 1)
    }

    func testAMutableDataSourceThrowsForAMissingElement() async {
        let source = StubMutableDataSource()

        do {
            _ = try await source.fetch(id: UUID())
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual(error as? CoreError, .notFound)
        }
    }

    func testAMutableDataSourceRemovesAndClears() async throws {
        let source = StubMutableDataSource()
        try await source.insert(.johnDoe)
        try await source.insert(.janeDoe)

        try await source.remove(id: User.johnDoe.id)
        let afterRemoval = try await source.fetch()
        XCTAssertEqual(afterRemoval.count, 1)

        try await source.clear()
        let afterClear = try await source.fetch()
        XCTAssertTrue(afterClear.isEmpty)
    }

    func testAMutableDataSourceUpdateInsertsWhenAbsent() async throws {
        let source = StubMutableDataSource()

        try await source.update(.johnDoe)

        let fetched = try await source.fetch(id: User.johnDoe.id)
        XCTAssertEqual(fetched, .johnDoe)
    }
}

// MARK: - Stubs

private struct StubDataSource: DataSource {
    let result: Result<User, any Error>

    func fetch() async throws -> User {
        try result.get()
    }
}

private struct StubDynamicDataSource: DynamicDataSource {
    func fetch(_ arguments: UUID) async throws -> User {
        guard arguments == User.johnDoe.id else { throw CoreError.notFound }
        return .johnDoe
    }
}

private actor StubMutableDataSource: MutableDataSource {
    private var storage: [UUID: User] = [:]

    func initialize() async throws {}
    func delete() async throws { storage = [:] }
    func insert(_ payload: User) async throws { storage[payload.id] = payload }
    func update(_ payload: User) async throws { storage[payload.id] = payload }

    func fetch(id: UUID) async throws -> User {
        guard let user = storage[id] else { throw CoreError.notFound }
        return user
    }

    func fetch() async throws -> [UUID: User] { storage }
    func remove(id: UUID) async throws { storage.removeValue(forKey: id) }
    func clear() async throws { storage = [:] }
}
