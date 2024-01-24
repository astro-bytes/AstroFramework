//
//  MutableDataSource.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation

// TODO: It would be nice if this was able to be a data source as well... or extend it
/// A protocol for mutable data sources with Payload management capabilities.
public protocol MutableDataSource<MutablePayload> {
    /// Generic type representing the Type of underlying data at the source
    associatedtype MutablePayload: Identifiable
    
    /// Instantiates ``DataSource`` instance. If the instance exists nothing is done.
    func initialize() async throws
    
    /// Deletes ``DataSource`` instance.
    func delete() async throws
    
    /// Inserts a new``MutablePayload`` instance.
    /// - Parameter payload: the object being created in the source
    func insert(_ payload: MutablePayload) async throws
    
    /// Updates a specific ``MutablePayload`` instance. If the specific instance does not exist a new instance is inserted.
    /// - Parameter payload: the object being updated in the source
    func update(_ payload: MutablePayload) async throws
    
    /// - Returns a specific ``MutablePayload`` instance from source.
    /// - Parameter id: identifier tied to the payload value fetched from source
    func fetch(id: MutablePayload.ID) async -> Result<MutablePayload, Error>
    
    /// - Returns Fetches all ``MutablePayload`` instances from source.
    func fetch() async -> Result<[MutablePayload.ID: MutablePayload], Error>
    
    /// Removes a specific ``MutablePayload`` from the source.
    /// - Parameter id: identifier tied to the payload value removed from source
    func remove(id: MutablePayload.ID) async throws
    
    /// Removes all ``MutablePayload`` objects from the source, but does not delete the source instance.
    func clear() async throws
}
