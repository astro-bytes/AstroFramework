//
//  AnyPublisherExtensionTests.swift
//  UtilityFoundationTests
//
//  Created by Porter McGary on 2/9/24.
//

import XCTest
import Combine
@testable import UtilityFoundation

class AnyPublisherExtensionTests: XCTestCase {

    /// Short on purpose. Every test here that succeeds should finish well inside it; a test that
    /// takes the whole interval is reporting a regression, not being careful.
    private let timeout: TimeInterval = 1

    // MARK: Returning promptly

    func testFirst_ReturnsAValueAlreadyHeld() async throws {
        let subject = CurrentValueSubject<Int, Never>(5)

        let value = try await subject.eraseToAnyPublisher().first(timeoutAfter: timeout) { $0 == 5 }

        XCTAssertEqual(value, 5)
    }

    /// The point of the method: a matching value ends the wait, it does not merely get remembered
    /// until the timeout does.
    ///
    /// Implemented with Combine's `last(where:)`, this passed while taking the full timeout, because
    /// `last` only emits once the upstream finishes — and none of the publishers this is used on
    /// ever finish.
    func testFirst_DoesNotWaitOutTheTimeoutForAnAvailableValue() async throws {
        let subject = CurrentValueSubject<Int, Never>(5)

        let start = Date()
        _ = try await subject.eraseToAnyPublisher().first(timeoutAfter: timeout) { $0 == 5 }
        let elapsed = Date().timeIntervalSince(start)

        XCTAssertLessThan(elapsed, timeout / 2, "first() waited on a value that was already there")
    }

    func testFirst_ReturnsTheFirstMatchNotTheLast() async {
        let subject = CurrentValueSubject<Int, Never>(0)
        let publisher = subject.eraseToAnyPublisher()
        let expectation = expectation(description: "Returns the earlier match")

        Task {
            let value = try? await publisher.first(timeoutAfter: timeout) { $0 > 0 }
            XCTAssertEqual(value, 1)
            expectation.fulfill()
        }

        // The subscription has to be live before the sends, or the awaiting task subscribes to a
        // `CurrentValueSubject` that already holds 2 and matches on that instead. Combine then
        // delivers both sends synchronously, so the ordering under test is deterministic.
        try? await Task.sleep(for: .milliseconds(100))
        subject.send(1)
        subject.send(2)

        await fulfillment(of: [expectation], timeout: timeout + 1)
    }

    func testFirst_SkipsValuesFailingThePredicate() async {
        let subject = CurrentValueSubject<Int, Never>(1)
        let publisher = subject.eraseToAnyPublisher()
        let expectation = expectation(description: "Skips to the match")

        Task {
            let value = try? await publisher.first(timeoutAfter: timeout) { $0 == 3 }
            XCTAssertEqual(value, 3)
            expectation.fulfill()
        }

        try? await Task.sleep(for: .milliseconds(100))
        subject.send(2)
        subject.send(3)

        await fulfillment(of: [expectation], timeout: timeout + 1)
    }

    func testFirst_DefaultPredicateTakesAnyValue() async throws {
        let subject = CurrentValueSubject<Int, Never>(42)

        let value = try await subject.eraseToAnyPublisher().first(timeoutAfter: timeout)

        XCTAssertEqual(value, 42)
    }

    // MARK: Failing

    func testFirst_TimesOutWhenNothingMatches() async {
        let subject = PassthroughSubject<Int, Never>()

        do {
            _ = try await subject.eraseToAnyPublisher()
                .first(timeoutAfter: 0.2, scheduler: .global()) { _ in false }
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual(error as? CoreError, .timeout)
        }
    }

    /// A `PassthroughSubject` does not replay, so a value sent before the await is simply gone.
    func testFirst_TimesOutWhenTheValueWasSentBeforeSubscribing() async {
        let subject = PassthroughSubject<Int, Never>()
        subject.send(5)

        do {
            _ = try await subject.eraseToAnyPublisher()
                .first(timeoutAfter: 0.2, scheduler: .global()) { $0 == 5 }
            XCTFail("Should throw")
        } catch {
            XCTAssertEqual(error as? CoreError, .timeout)
        }
    }

    func testFirst_PropagatesUpstreamFailure() async {
        let subject = PassthroughSubject<Int, TestError>()
        let publisher = subject.eraseToAnyPublisher()
        let expectation = expectation(description: "Propagates the failure")

        Task {
            do {
                _ = try await publisher.first(timeoutAfter: timeout, scheduler: .global())
                XCTFail("Should throw")
            } catch {
                XCTAssertEqual(error as? TestError, .genericError)
            }
            expectation.fulfill()
        }

        try? await Task.sleep(for: .milliseconds(100))
        subject.send(completion: .failure(.genericError))

        await fulfillment(of: [expectation], timeout: timeout + 1)
    }

    /// A publisher that finishes without ever matching is out of chances, so it reports the same
    /// thing as running out of time.
    func testFirst_TimesOutWhenTheStreamFinishesWithoutAMatch() async {
        let subject = PassthroughSubject<Int, Never>()
        let publisher = subject.eraseToAnyPublisher()
        let expectation = expectation(description: "Reports timeout")

        Task {
            do {
                _ = try await publisher.first(timeoutAfter: timeout, scheduler: .global()) { $0 == 9 }
                XCTFail("Should throw")
            } catch {
                XCTAssertEqual(error as? CoreError, .timeout)
            }
            expectation.fulfill()
        }

        try? await Task.sleep(for: .milliseconds(100))
        subject.send(completion: .finished)

        await fulfillment(of: [expectation], timeout: timeout + 1)
    }

    func testFirst_ThrowsCancellationWhenTheAwaitingTaskIsCancelled() async {
        let subject = PassthroughSubject<Int, Never>()
        let publisher = subject.eraseToAnyPublisher()
        let expectation = expectation(description: "Reports cancellation")

        let task = Task {
            do {
                _ = try await publisher.first(timeoutAfter: 30, scheduler: .global())
                XCTFail("Should throw")
            } catch {
                XCTAssertTrue(error is CancellationError, "got \(error)")
            }
            expectation.fulfill()
        }

        try? await Task.sleep(for: .milliseconds(100))
        task.cancel()

        await fulfillment(of: [expectation], timeout: timeout + 1)
    }
}
