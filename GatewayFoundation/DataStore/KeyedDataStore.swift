//
//  KeyedDataStore.swift
//  GatewayFoundation
//
//  Created by Porter McGary on 1/20/24.
//

import Foundation
import UseCaseFoundation

/// A ``DataStore`` of elements keyed by their identifier.
///
/// Refines ``UseCaseFoundation/KeyedRepository`` for the same reason ``DataStore`` refines
/// `Repository`: the element accessors are the port, and this is the side that implements them.
public protocol KeyedDataStore<Element>: DataStore, KeyedRepository where Payload == [Element.ID: Element] {
    /// Retrieves an element from the data store by its ID.
    /// - Parameter id: The ID of the element to retrieve.
    /// - Returns: A result containing the element on success, or an error on failure.
    func get(by id: Element.ID) -> DataResult<Element>

    /// Refreshes a single element from the source.
    /// - Parameter id: The ID of the element to refresh.
    /// - Returns: The element's value after the refresh.
    func refresh(by id: Element.ID) async -> DataResult<Element>

    /// Refreshes a single element from the source, reporting the result through ``data``.
    /// - Parameter id: The ID of the element to refresh.
    func refresh(by id: Element.ID)
}
