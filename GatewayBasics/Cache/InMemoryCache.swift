//
//  InMemoryCache.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/17/24.
//

import Combine
import Foundation
import UseCaseBasics

public class InMemoryCache<Payload>: Cacheable {
    @Published public internal(set) var value: DataResult<Payload>
    public lazy var data: AnyPublisher<DataResult<Payload>, Never> = $value.eraseToAnyPublisher()
    public var cachedDate: Date?
    
    public var expirationDate: Date? {
        cachedDate?.addingTimeInterval(lifetime)
    }
    
    public var isExpired: Bool {
        guard let expirationDate else {
            // if there is no expiration date then the cache has not been set. So behave as if expired
            return true
        }
        return .now > expirationDate
    }
    
    /// Time interval for the cache to live before it becomes stale/invalid in seconds
    let lifetime: TimeInterval
    
    /// Creates a datastore for the payload with an in memory cache that is expirable
    /// - Parameter lifetime: the time that the cache has to live before becoming expired
    public init(lifetime: TimeInterval) {
        self.lifetime = lifetime
        self.value = .uninitialized
    }
    
    // TODO: Would there ever be a case where I would want to set the cache as a failure or loading state?
    public func set(_ result: DataResult<Payload>) throws {
        switch result {
        case .success:
            cachedDate = .now
        default:
            cachedDate = nil
        }
        
        value = result
    }
    
    public func clear() throws {
        cachedDate = nil
        value = .uninitialized
    }
}
