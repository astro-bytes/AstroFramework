//
//  Cache.swift
//  GatewayBasics
//
//  Created by Joshua Bee on 1/17/24.
//

import Combine
import Foundation
import UseCaseFoundation

/// A protocol defining the interface for a data cache.
public protocol Cacheable<Payload> {
    /// Generic representing the type of data the cache will store.
    associatedtype Payload
    
    /// A publisher providing a stream of data results from the cache.
    var data: AnyPublisher<DataResult<Payload>, Never> { get }
    
    /// The current value stored in the cache.
    var value: DataResult<Payload> { get }
    
    /// Indicates whether the cached data is expired.
    var isExpired: Bool { get }
    
    /// The date when the data was last cached.
    var cachedDate: Date? { get }
    
    /// Sets the provided payload in the cache.
    /// - Parameter payload: The data payload to be stored in the cache.
    /// - Throws: An error if setting the payload in the cache fails.
    func set(_ result: DataResult<Payload>) throws
    
    /// Clears the data stored in the cache.
    /// - Throws: An error if clearing the cache fails.
    func clear() throws
}
