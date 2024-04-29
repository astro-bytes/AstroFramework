//
//  InMemoryCache.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/17/24.
//

import Combine
import Foundation
import UseCaseFoundation

/// A class representing an in-memory cache with expirable data.
/// This cache allows you to store and retrieve data with a specified expiration time.
/// You can use it as a simple in-memory storage solution.
public class InMemoryCache<Payload>: Cacheable {
    /// The current cached value, wrapped in a `DataResult`.
    @Published public internal(set) var value: DataResult<Payload>
    
    /// A publisher exposing the cached value.
    public lazy var data: AnyPublisher<DataResult<Payload>, Never> = $value.eraseToAnyPublisher()
    
    /// The date when the cache was last set.
    public var cachedDate: Date?
    
    /// The expiration date of the cache based on the lifetime.
    public var expirationDate: Date? {
        cachedDate?.addingTimeInterval(lifetime)
    }
    
    /// Checks if the cache is expired.
    public var isExpired: Bool {
        guard let expirationDate else {
            // If there is no expiration date, then the cache has not been set. Behave as if expired.
            return true
        }
        return .now > expirationDate
    }
    
    /// Time interval for the cache to live before it becomes stale/invalid in seconds.
    let lifetime: TimeInterval
    
    /// Creates a datastore for the payload with an in-memory cache that is expirable.
    /// - Parameter lifetime: The time that the cache has to live before becoming expired.
    public init(lifetime: TimeInterval) {
        self.lifetime = lifetime
        self.value = .uninitialized
    }
    
    /// Sets the cache value and updates the cached date based on the result.
    /// - Parameter result: The result to set in the cache.
    /// - Throws: An error if setting the cache fails.
    public func set(_ result: DataResult<Payload>) throws {
        switch result {
        case .success:
            cachedDate = .now
        default:
            cachedDate = nil
        }
        
        value = result
    }
    
    /// Clears the cache by resetting the cached date and value.
    /// - Throws: An error if clearing the cache fails.
    public func clear() throws {
        cachedDate = nil
        value = .uninitialized
    }
}
