//
//  MockSpyTests.swift
//  UseCaseFoundationTests
//
//  Created by Porter McGary on 8/27/26.
//

import XCTest
import Mocks
import UseCaseFoundation

/// The mocks carried twenty `calledX` flags that were internal, so nothing outside the module
/// could read one — and not one test in the package did. They are the reason a mock exists;
/// these are the first assertions on them.
final class MockSpyTests: XCTestCase {

    func testRepositoryRecordsWhatWasCalled() async {
        let repository = MockRepository<User>(.uninitialized)

        XCTAssertFalse(repository.calledRefresh)
        XCTAssertFalse(repository.calledAsyncRefresh)
        XCTAssertFalse(repository.calledSet)
        XCTAssertFalse(repository.calledClear)

        // `refresh()` and `refresh() async` are an overload pair, and inside an async context
        // Swift picks the async one — so reaching the synchronous overload means naming its type.
        let synchronousRefresh: () -> Void = repository.refresh
        synchronousRefresh()
        _ = await repository.refresh()
        repository.set(.johnDoe)
        repository.clear()

        XCTAssertTrue(repository.calledRefresh)
        XCTAssertTrue(repository.calledAsyncRefresh)
        XCTAssertTrue(repository.calledSet)
        XCTAssertTrue(repository.calledClear)
    }

    func testKeyedRepositoryRecordsWhatWasCalled() async {
        let repository = MockKeyedRepository<User>(.success(data: [User.johnDoe.id: .johnDoe]))

        repository.set(User.janeDoe)
        repository.clear(by: User.johnDoe.id)
        _ = await repository.refresh()

        XCTAssertTrue(repository.calledSetElement)
        XCTAssertTrue(repository.calledClearByID)
        XCTAssertTrue(repository.calledAsyncRefresh)
    }

    func testKeyedRepositoryMutatesItsPublishedValue() {
        let repository = MockKeyedRepository<User>(.success(data: [:]))

        repository.set(User.johnDoe)
        XCTAssertEqual(repository.subject.value.payload?[User.johnDoe.id], .johnDoe)

        repository.clear(by: User.johnDoe.id)
        XCTAssertNil(repository.subject.value.payload?[User.johnDoe.id])
    }

    func testSynchronousKeyedRepositoryReadsAnElementByID() {
        let store = MockSynchronousKeyedRepository<User>(.success(data: [User.johnDoe.id: .johnDoe]))

        XCTAssertEqual(store.get(by: User.johnDoe.id).payload, .johnDoe)
        XCTAssertTrue(store.calledGetID)

        XCTAssertNil(store.get(by: UUID()).payload)
    }

    /// `MockRepository.nextRefreshResult` is what lets a test drive the uninitialized-then-refresh
    /// path; without it a refresh reports the value the repository already holds.
    func testRepositoryRefreshReportsTheStagedResult() async {
        let repository = MockRepository<User>(.uninitialized)
        repository.nextRefreshResult = .success(data: .janeDoe)

        let result = await repository.refresh()

        XCTAssertEqual(result.payload, .janeDoe)
        XCTAssertEqual(repository.publisher.value.payload, .janeDoe)
    }
}
