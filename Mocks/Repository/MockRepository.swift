//
//  UserRepository.swift
//  Mocks
//
//  Created by Porter McGary on 1/17/24.
//

import Combine
import Foundation
import GatewayFoundation
import UseCaseFoundation

// Get the Local user info

/// `@unchecked` because the spy flags are plain stored properties. The value it publishes goes
/// through `CurrentValueSubject`, which is thread-safe; tests read the flags after the work under
/// test has finished.
public final class MockRepository<Payload: Sendable>: Repository, @unchecked Sendable {
    var calledRefresh = false
    var calledAsyncRefresh = false
    var calledSet = false
    var calledClear = false
    
    public let publisher: CurrentValueSubject<DataResult<Payload>, Never>
    
    public var data: AnyPublisher<DataResult<Payload>, Never> {
        publisher.eraseToAnyPublisher()
    }
    
    /// What ``refresh()`` should produce, for exercising the uninitialized-then-refresh path.
    ///
    /// Left `nil`, a refresh reports the value the repository already holds — which means it can
    /// never change state, and the branch of `Repository.get` that exists to handle a repository
    /// fetching for the first time is unreachable.
    public var nextRefreshResult: DataResult<Payload>?

    public init(_ value: DataResult<Payload>) {
        self.publisher = .init(value)
    }

    public func refresh() {
        calledRefresh = true
        guard let nextRefreshResult else { return }
        publisher.send(nextRefreshResult)
    }

    public func refresh() async -> UseCaseFoundation.DataResult<Payload> {
        calledAsyncRefresh = true
        guard let nextRefreshResult else { return publisher.value }
        publisher.send(nextRefreshResult)
        return nextRefreshResult
    }
    
    public func set(_ payload: Payload) {
        calledSet = true
        publisher.send(.success(data: payload))
    }
    
    public func clear() {
        calledClear = true
    }
}
