//
//  Repository.swift
//  UseCaseFoundation
//
//  Created by Porter McGary on 1/16/24.
//

import Foundation
import Combine
import EntityFoundation
import UtilityFoundation

/// A source of one value that can be observed, refreshed, replaced and cleared.
///
/// The Repository Pattern as a port: the use-case layer declares this, and the gateway layer
/// implements it — see ``GatewayFoundation/DataStore`` for the implementation side, which adds a
/// synchronous accessor.
///
/// Conform to this when a use case needs a value and should not know where it comes from.
public protocol Repository<Payload> {
    /// The data with the ability to subscribe to and observe the data's current state.
    ///
    /// `Sendable` because ``get(within:)`` hands it across a concurrency domain.
    associatedtype Payload: Sendable
    
    /// The publisher emitting `DataResult` objects.
    var data: AnyPublisher<DataResult<Payload>, Never> { get }
    
    /// Forces the data to be pulled and updated from the source instead of from the cache.
    func refresh()
    
    /// Asynchronously forces the data to be pulled and updated from the source instead of from the cache.
    /// - Returns: The current value of the data after a refresh.
    func refresh() async -> DataResult<Payload>
    
    /// Asynchronously returns the current value of the data
    /// - Returns: The current state value of the data.
    func get(within: TimeInterval) async throws -> Payload
    
    /// Sets the new value that is being updated.
    ///
    /// - Parameter payload: The new value that is being updated.
    func set(_ payload: Payload)
    
    /// Clears any cached data locally. A refresh should be called again to repopulate the `data`.
    func clear()
}

/// Extension providing an asynchronous method to retrieve the current value of the repository's data.
extension Repository {
    /// Retrieves the current value of the repository's data asynchronously.
    ///
    /// Subscribes to the repository's data stream and waits for the first result that is not
    /// loading. If that result is uninitialized — the repository has never fetched — it refreshes
    /// once and reports whatever that produces.
    ///
    /// A failed result throws rather than returning its cached payload, even when one is present.
    /// Callers that want the stale value on failure should read ``data`` instead, where the cached
    /// payload travels alongside the error.
    ///
    /// - Parameter timeout: How long to wait for a non-loading result. Defaults to 5 seconds.
    /// - Returns: The current value of the repository's data.
    /// - Throws: ``CoreError/timeout`` if no result arrives in time, ``CoreError/notFound`` if a
    ///   refresh leaves the repository uninitialized, or the underlying failure.
    public func get(within timeout: TimeInterval = .to(seconds: 5)) async throws -> Payload {
        let result: DataResult<Payload> = try await data.first(timeoutAfter: timeout) { !$0.isLoading }

        switch result {
        case .success(let payload):
            return payload
        case .failure(_, let error):
            throw error
        case .uninitialized:
            return try await refreshedPayload()
        case .loading:
            // The predicate above only admits non-loading results, so this is unreachable.
            throw CoreError.timeout
        }
    }

    /// Refreshes once and unwraps the outcome, mapping every non-success state onto an error.
    private func refreshedPayload() async throws -> Payload {
        switch await refresh() {
        case .success(let payload):
            return payload
        case .failure(_, let error):
            throw error
        case .uninitialized:
            throw CoreError.notFound
        case .loading:
            throw CoreError.timeout
        }
    }
}
