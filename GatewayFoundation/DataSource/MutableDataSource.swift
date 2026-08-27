//
//  MutableDataSource.swift
//  GatewayFoundation
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation

/// A ``DataSource`` that can also be written to.
///
/// Not a refinement of ``DataSource``: that protocol fetches one payload, while this one fetches
/// elements by identifier and all of them at once. The two `fetch` requirements would collide.
public protocol MutableDataSource<MutablePayload> {
    /// Generic type representing the Type of underlying data at the source
    associatedtype MutablePayload: Identifiable & Sendable where MutablePayload.ID: Sendable
    
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
    
    /// Fetches a specific ``MutablePayload`` instance from the source.
    /// - Parameter id: identifier tied to the payload value fetched from source
    /// - Returns: The fetched element.
    /// - Throws: Whatever the underlying source failed with.
    func fetch(id: MutablePayload.ID) async throws -> MutablePayload

    /// Fetches all ``MutablePayload`` instances from the source.
    /// - Returns: Every element, keyed by identifier.
    /// - Throws: Whatever the underlying source failed with.
    func fetch() async throws -> [MutablePayload.ID: MutablePayload]
    
    /// Removes a specific ``MutablePayload`` from the source.
    /// - Parameter id: identifier tied to the payload value removed from source
    func remove(id: MutablePayload.ID) async throws
    
    /// Removes all ``MutablePayload`` objects from the source, but does not delete the source instance.
    func clear() async throws
}
