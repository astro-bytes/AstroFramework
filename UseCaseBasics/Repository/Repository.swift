//
//  Repository.swift
//  GatewayBasics
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
public protocol Repository {
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
    func get() async throws -> Payload
    
    /// Sets the new value that is being updated.
    ///
    /// - Parameter payload: The new value that is being updated.
    func set(_ payload: Payload)
    
    /// Clears any cached data locally. A refresh should be called again to repopulate the `data`.
    func clear()
}

extension Repository {
    func get() async throws -> Payload {
        // With a subscription
        // Subscribe and take the first value
        let result: DataResult<Payload> = try await data.first()
        
        switch result {
        case .uninitialized:
            // This should not happen
            throw CoreError.notFound
//            let refreshedResult = await refresh()
//            guard refreshedResult.error.isNotNil,
//                  refreshedResult.isLoading == false,
//                  let newPayload = refreshedResult.payload else {
//                guard case .failure(_, let error) = refreshedResult else {
//                    guard  refreshedResult.isLoading else {
//                        // Uninitialized
//                        throw CoreError.notFound
//                    }
//                    // Loading
//                    throw CoreError.timeout
//                }
//                // Failed
//                throw error
//            }
//            // Success
//            return newPayload
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

extension AnyPublisher {
    func first(timeoutAfter time: TimeInterval = .to(seconds: 5), scheduler: DispatchQueue = DispatchQueue.main) async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var found = false
            let cancellable = timeout(.seconds(time), scheduler: scheduler).sink { completion in
                switch completion {
                case .finished:
                    if !found {
                        continuation.resume(throwing: CoreError.timeout)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            } receiveValue: { value in
                found = true
                continuation.resume(returning: value)
            }
        }
    }
}
