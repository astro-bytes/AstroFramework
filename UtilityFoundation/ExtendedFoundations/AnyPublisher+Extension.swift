//
//  AnyPublisher+Extension.swift
//  UtilityFoundation
//
//  Created by Porter McGary on 2/9/24.
//

import Foundation
import Combine

extension AnyPublisher {
    /// Awaits the first emitted value that satisfies `predicate`.
    ///
    /// - Parameters:
    ///   - time: How long to wait before giving up. Defaults to 5 seconds.
    ///   - scheduler: The scheduler the timeout is measured on.
    ///   - predicate: The test a value has to pass to be the one returned. Defaults to accepting
    ///     the first value of any kind.
    /// - Returns: The first matching value.
    /// - Throws: ``CoreError/timeout`` if `time` elapses, or the publisher finishes, without a
    ///   match; `CancellationError` if the awaiting task is cancelled; otherwise the publisher's
    ///   own failure.
    public func first(timeoutAfter time: TimeInterval = .to(seconds: 5),
                      scheduler: DispatchQueue = DispatchQueue.main,
                      where predicate: @escaping (Output) -> Bool = { _ in true }) async throws -> Output {
        let box = FirstValueBox<Output>()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                box.attach(continuation)

                // `first(where:)` completes the stream as soon as a value matches. `last(where:)`
                // would instead hold every match until the upstream finishes — and the publishers
                // this is used on, `CurrentValueSubject` among them, never finish. That made the
                // timeout the only thing that ever ended the wait, so a value that was already
                // available still took the full `time` to arrive.
                let cancellable = timeout(.seconds(time), scheduler: scheduler)
                    .first(where: predicate)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            // Reached only when the stream ended without a match, which for a
                            // timed-out publisher means the timeout elapsed.
                            box.settle(.failure(CoreError.timeout))
                        case .failure(let error):
                            box.settle(.failure(error))
                        }
                    } receiveValue: { value in
                        box.settle(.success(value))
                    }

                box.store(cancellable)
            }
        } onCancel: {
            box.settle(.failure(CancellationError()))
        }
    }
}

/// Bridges a Combine subscription to a single continuation, resuming it exactly once.
///
/// Three orderings have to hold, and each of them happens in practice: a synchronous publisher
/// settles before ``store(_:)`` hands over the subscription; `first(where:)` sends its value and
/// then immediately finishes, offering an outcome twice; and cancellation can arrive before the
/// continuation is attached at all. The lock and the one-shot `isSettled` flag make all three safe.
private final class FirstValueBox<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Value, any Error>?
    private var cancellable: AnyCancellable?
    private var pendingOutcome: Result<Value, any Error>?
    private var isSettled = false

    /// Adopts the continuation, resuming it straight away if the outcome already arrived.
    func attach(_ continuation: CheckedContinuation<Value, any Error>) {
        lock.lock()
        if let pendingOutcome {
            self.pendingOutcome = nil
            lock.unlock()
            continuation.resume(with: pendingOutcome)
            return
        }
        self.continuation = continuation
        lock.unlock()
    }

    /// Retains the subscription, cancelling it immediately if the wait is already over.
    func store(_ cancellable: AnyCancellable) {
        lock.lock()
        guard !isSettled else {
            lock.unlock()
            cancellable.cancel()
            return
        }
        self.cancellable = cancellable
        lock.unlock()
    }

    /// Resumes the continuation. Every call after the first is ignored.
    func settle(_ outcome: Result<Value, any Error>) {
        lock.lock()
        guard !isSettled else {
            lock.unlock()
            return
        }
        isSettled = true

        let continuation = self.continuation
        let cancellable = self.cancellable
        self.continuation = nil
        self.cancellable = nil
        if continuation == nil { pendingOutcome = outcome }
        lock.unlock()

        cancellable?.cancel()
        continuation?.resume(with: outcome)
    }
}
