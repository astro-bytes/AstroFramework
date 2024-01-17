//
//  Cache.swift
//  GatewayBasics
//
//  Created by Joshua Bee on 1/17/24.
//

import Foundation
//TODO Figure out how to handle errors with all functions
protocol Cache {
    /// Generic defining the data type used by the repository
    associatedtype Payload: Identifiable where Payload.ID:Hashable
    
    /// Create an instance of a ``Cache``
    func create()
    
    /// Deletes cache instance
    func delete()
    
    /// Insert a new instance of a ``Payload``
    func insert(_: Payload)
    
    /// Edit some existing ``Payload``
    func update(_: Payload)
    
    /// Retrieves ``Payload`` from cache
    func read(id: Payload.ID) -> Payload
    
    /// Retrieves all ``Payload`` instances from cache
    func readAll() -> [Payload.ID: Payload]
    
    /// Remove some ``Payload`` from the cache
    func remove(id: Payload.ID)
    
    /// Remove all objects in cache, but does not delete the cache instance
    func clear()
}
