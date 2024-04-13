//
//  KeyedDataStore.swift
//  GatewatBasics
//
//  Created by Porter McGary on 1/20/24.
//

import Foundation
import UseCaseFoundation

/// A protocol for a keyed data store, where elements are uniquely identified by their ID.
public protocol KeyedDataStore<Element>: DataStore where Payload == [Element.ID: Element] {
    /// The type of elements stored in the data store, conforming to Identifiable.
    associatedtype Element: Identifiable
    
    /// Retrieves an element from the data store by its ID.
    /// - Parameter id: The ID of the element to retrieve.
    /// - Returns: A result containing the element on success, or an error on failure.
    func get(by id: Element.ID) -> DataResult<Element>
    
    /// Sets or updates an element in the data store.
    /// - Parameter element: The element to be set or updated.
    func set(_ element: Element)
    
    /// Clears an element from the data store by its ID.
    /// - Parameter id: The ID of the element to clear.
    func clear(by id: Element.ID)
    
    /// Clears an element from the data store.
    /// - Parameter id: The ID of the element to refresh.
    func refresh(by id: Element.ID) async -> DataResult<Element>
    
    /// Clears an element from the data store.
    /// - Parameter id: The ID of the element to refresh.
    func refresh(by id: Element.ID)
}
