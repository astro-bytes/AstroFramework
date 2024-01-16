//
//  CollectionDataStore.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/20/24.
//

import Foundation
import UseCaseBasics

/// A protocol for a data store with a collection payload, where elements are uniquely identified by their ID.
public protocol CollectionDataStore<Payload>: DataStore where Payload: Collection, Payload.Element: Identifiable {
    /// Retrieves an element from the data store by its ID.
    /// - Parameter id: The ID of the element to retrieve.
    /// - Returns: A result containing the element on success, or an error on failure.
    func get(by id: Payload.Element.ID) -> DataResult<Payload.Element>
    
    /// Sets or updates an element in the data store.
    /// - Parameter element: The element to be set or updated.
    func set(_ element: Payload.Element)
    
    /// Clears an element from the data store by its ID.
    /// - Parameter id: The ID of the element to clear.
    func clear(by id: Payload.Element.ID)
}
