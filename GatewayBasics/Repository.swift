//
//  Repository.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/16/24.
//

import Foundation
import Combine

/// Interface that follows the Repository Pattern.
/// This structurally provides a way to access data from an underlying ``DataStore`` in a uniform way.
public protocol Repository {
    /// Generic defining the data type used by the repository
    associatedtype Payload
    
    /// The data with the ability to subscribe to and observe the data's current state
    var data: AnyPublisher<DataResult<Payload>, Never> { get }
    
    /// Forces the data to be pulled and updated from the source instead of from the cache
    func refresh()
    
    /// Forces the data to be pulled and updated from the source instead of from the cache
    /// - Returns: The current value of the data after a refresh
    func refresh() async -> DataResult<Payload>
    
    /// - Returns: the current state value of the data.
    func get() -> DataResult<Payload>
    
    /// - Parameter payload: the new value that is being updated
    func set()
    
    /// Clears any cached data locally. A refresh should be called again to repopulate the ``data``.
    func clear()
}
