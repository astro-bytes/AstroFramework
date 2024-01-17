//
//  MutableDataSource.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation

// TODO: It would be nice if this was able to be a data source as well... or extend it
/// A protocol for mutable data sources with Payload management capabilities.
public protocol MutableDataSource<Payload> {
    /// Generic type representing the Type of underlying data at the source
    associatedtype Payload: Identifiable
    
    /// Instantiates ``DataSource`` instance. If the instance exists nothing is done.
    func initialize()
    
    /// Deletes ``DataSource`` instance.
    func delete()
    
    /// Inserts a new``Payload`` instance.
    /// - Parameter payload: the object being created in the source
    func insert(_ payload: Payload)
    
    /// Updates a specific ``Payload`` instance. If the specific instance does not exist a new instance is inserted.
    /// - Parameter payload: the object being updated in the source
    func update(_ payload: Payload)
    
    /// - Returns a specific ``Payload`` instance from source.
    /// - Parameter id: identifier tied to the payload value fetched from source
    func fetch(id: Payload.ID) -> Result<Payload, Error>
    
    /// - Returns Fetches all ``Payload`` instances from source.
    func fetch() -> Result<[Payload.ID: Payload], Error>
    
    /// Removes a specific ``Payload`` from the source.
    /// - Parameter id: identifier tied to the payload value removed from source
    func remove(id: Payload.ID)
    
    /// Removes all ``Payload`` objects from the source, but does not delete the source instance.
    func clear()
}
