//
//  KeyedRepository.swift
//  UseCaseBasics
//
//  Created by Porter McGary on 1/30/24.
//

import Foundation
import Utility

/// Protocol defining a keyed repository, which extends the basic repository pattern and provides methods to interact with data elements using their identifiers.
public protocol KeyedRepository<Element>: Repository {
    /// Associated type representing the elements stored in the repository, which must conform to the `Identifiable` protocol.
    associatedtype Element: Identifiable
    
    /// Retrieves an element from the repository by its identifier.
    ///
    /// - Parameter id: The identifier of the element to retrieve.
    /// - Returns: A `DataResult` containing the element with the specified identifier.
    func get(by id: Element.ID, within timeout: TimeInterval) async throws -> Element
    
    /// Sets the provided element in the repository.
    ///
    /// - Parameter element: The element to set in the repository.
    func set(_ element: Element)
    
    /// Clears the element with the specified identifier from the repository.
    ///
    /// - Parameter id: The identifier of the element to clear.
    func clear(by id: Element.ID)
}

/// Extension providing a method to retrieve an element from the keyed repository by its identifier.
extension KeyedRepository where Payload == [Element.ID: Element] {
    /// Retrieves an element from the keyed repository by its identifier asynchronously.
    ///
    /// - Parameters:
    ///   - id: The identifier of the element to retrieve.
    ///   - timeout: The maximum time to wait for the operation to complete. Default is 5 seconds.
    /// - Returns: The element with the specified identifier.
    /// - Throws: An error if the retrieval fails or the element is not found.
    public func get(by id: Element.ID, within timeout: TimeInterval = .to(seconds: 5)) async throws -> Element {
        let payload = try await get(within: timeout)
        guard let value = payload[id] else {
            throw CoreError.notFound
        }
        return value
    }
}

