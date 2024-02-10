//
//  Repository.swift
//  UseCaseBasics
//
//  Created by Porter McGary on 1/16/24.
//

import Foundation
import Combine
import EntityBasics
import Utility

/// Interface that follows the Repository Pattern.
///
/// This structurally provides a way to access data from an underlying `DataStore` in a uniform way.
public protocol Repository<Payload> {
    /// The data with the ability to subscribe to and observe the data's current state.
    associatedtype Payload
    
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
    /// This method subscribes to the repository's data stream, waits for the first non-loading value,
    /// and returns it. If the data is uninitialized, it tries to refresh the data and returns the new value.
    ///
    /// - Returns: The current value of the repository's data.
    /// - Throws: An error if the retrieval fails.
    public func get(within timeout: TimeInterval = .to(seconds: 5)) async throws -> Payload {
        // With a subscription
        // Subscribe and take the first value
        let result: DataResult<Payload> = try await data.first(timeoutAfter: timeout) { !$0.isLoading }
        
        switch result {
        case .uninitialized:
            let refreshedResult = await refresh()
            guard refreshedResult.error.isNotNil,
                  refreshedResult.isLoading == false,
                  let newPayload = refreshedResult.payload else {
                guard case .failure(_, let error) = refreshedResult else {
                    guard  refreshedResult.isLoading else {
                        // Uninitialized
                        throw CoreError.notFound
                    }
                    // Loading
                    throw CoreError.timeout
                }
                // Failed
                throw error
            }
            // Success
            return newPayload
        case .loading:
            // This should't happen
            throw CoreError.timeout
        case .success(let data):
            return data
        case .failure(_, let error):
            throw error
        }
    }
}
