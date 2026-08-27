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

    /// Long enough that a correct implementation never reaches it, short enough that a regression
    /// shows up as a slow test rather than a slow suite.
    private let timeout: TimeInterval = 1

    // MARK: Reading what the repository already holds

    func testGet_Success() async throws {
        let repository = MockRepository<User>(.success(data: .johnDoe))

        let result = try await repository.get(within: timeout)

        XCTAssertEqual(result, .johnDoe)
    }

    /// A value that is already available has to come back immediately.
    ///
    /// The regression this guards against is `first(timeoutAfter:where:)` being implemented with
    /// Combine's `last(where:)`, which holds the value until the upstream finishes. Because the
    /// repository publisher never finishes, every read took the full timeout — and the tests that
    /// existed passed anyway, because they only checked the value and not how long it took.
    func testGet_SuccessReturnsWithoutWaitingOutTheTimeout() async throws {
        let repository = MockRepository<User>(.success(data: .johnDoe))

        let start = Date()
        _ = try await repository.get(within: timeout)
        let elapsed = Date().timeIntervalSince(start)

        XCTAssertLessThan(elapsed, timeout / 2, "get() waited on a value it already had")
    }

    func testGet_Failure() async throws {
        let expectedError = CoreError.notFound
        let repository = MockRepository<User>(.failure(cachedData: nil, error: expectedError))

        do {
            _ = try await repository.get(within: timeout)
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual(error as? CoreError, expectedError)
        }
    }

    /// A failure throws even when it carries a usable cached payload. Callers wanting the stale
    /// value read `data`, where it travels alongside the error.
    func testGet_FailureWithCachedDataStillThrows() async throws {
        let repository = MockRepository<User>(.failure(cachedData: .janeDoe, error: CoreError.timeout))

        do {
            _ = try await repository.get(within: timeout)
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual(error as? CoreError, .timeout)
        }
    }

    func testGet_LoadingTimesOut() async throws {
        let repository = MockRepository<User>(.loading(cachedData: nil))

        do {
            _ = try await repository.get(within: timeout)
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual(error as? CoreError, .timeout)
        }
    }

    func testGet_LoadingResolvesWhenTheValueArrives() async throws {
        let repository = MockRepository<User>(.loading(cachedData: nil))
        let expectation = expectation(description: "Should have value")

        Task {
            do {
                let value = try await repository.get(within: timeout)
                XCTAssertEqual(value, .janeDoe)
            } catch {
                XCTFail("Unexpected failure: \(error)")
            }
            expectation.fulfill()
        }

        repository.set(.janeDoe)

        await fulfillment(of: [expectation], timeout: timeout + 1)
    }

    // MARK: Refreshing an uninitialized repository

    /// The uninitialized branch refreshes once and reports what that produced.
    ///
    /// The regression this guards against is that branch's guard reading `error.isNotNil` where it
    /// meant `isNil` — so a successful refresh failed the guard and fell through to `notFound`. No
    /// test caught it because the mock's `refresh()` returned the value it already held, which
    /// meant it could never transition out of `.uninitialized` at all.
    func testGet_UninitializedRefreshesToSuccess() async throws {
        let repository = MockRepository<User>(.uninitialized)
        repository.nextRefreshResult = .success(data: .johnDoe)

        let result = try await repository.get(within: timeout)

        XCTAssertEqual(result, .johnDoe)
    }

    func testGet_UninitializedRefreshesToFailure() async throws {
        let repository = MockRepository<User>(.uninitialized)
        repository.nextRefreshResult = .failure(cachedData: nil, error: CoreError.timeout)

        do {
            _ = try await repository.get(within: timeout)
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual(error as? CoreError, .timeout)
        }
    }

    /// A refresh that leaves the repository uninitialized means there is nothing to be had.
    func testGet_UninitializedStaysUninitialized() async throws {
        let repository = MockRepository<User>(.uninitialized)

        do {
            _ = try await repository.get(within: timeout)
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual(error as? CoreError, .notFound)
        }
    }
}
