//
//  Collection+Extension.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation

extension Collection {
    // TODO: Comment & Test
    public func asyncCompactMap<Value>(_ transformation: (Element) async -> Value?) async -> [Value] {
        var transformedArray = [Value]()
        for element in self {
            if let value = await transformation(element) {
                transformedArray.append(value)
            }
        }
        return transformedArray
    }
    
    // TODO: Comment & Test
    public func asyncCompactMap<Value>(_ transformation: (Element) async throws -> Value?) async throws -> [Value] {
        var transformedArray = [Value]()
        for element in self {
            if let value = try await transformation(element) {
                transformedArray.append(value)
            }
        }
        return transformedArray
    }
    
    // TODO: Comment & Test
    public func asyncMap<Value>(_ transformation: (Element) async -> Value) async -> [Value] {
        var transformedArray = [Value]()
        for element in self {
            transformedArray.append(await transformation(element))
        }
        return transformedArray
    }
    
    // TODO: Comment & Test
    public func asyncMap<Value>(_ transformation: (Element) async throws -> Value) async throws -> [Value] {
        var transformedArray = [Value]()
        for element in self {
            transformedArray.append(try await transformation(element))
        }
        return transformedArray
    }
    
    // TODO: Comment & Test
    public func asyncReduce<Result>(into initialResult: Result, _ nextPartialResult: ((inout Result, Element) async throws -> Void)) async rethrows -> Result {
        var result = initialResult
        for element in self {
            try await nextPartialResult(&result, element)
        }
        return result
    }
    
    // TODO: Comment & Test
    public func asyncReduce<Result>(into initialResult: Result, _ nextPartialResult: ((inout Result, Element) async -> Void)) async -> Result {
        var result = initialResult
        for element in self {
            await nextPartialResult(&result, element)
        }
        return result
    }
}

// MARK: Collection Whose Element is Identifiable
extension Collection where Element: Identifiable {
    /// - Parameter id: the id of the element searched for
    /// - Returns: The first element of the sequence who has the same `id`,
    ///   or `nil` if there is no element with that `id`.
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    public func first<ID>(by id: ID) -> Element? where Element.ID == ID {
        first { element in
            element.id == id
        }
    }
    
    /// - Parameter id: the id of the element searched for
    /// - Returns: The index of the first element who has the same `id`.
    ///     If no elements in the collection with the same `id`, returns `nil`.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public func firstIndex<ID>(by id: ID) -> Index? where Element.ID == ID {
        firstIndex { element in
            element.id == id
        }
    }
    
    /// - Parameter id: the id of the element searched for
    /// - Returns: An array of the elements that do not include the same `id` as the parameter
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    public func filterOut<ID>(_ id: ID) -> [Element] where Element.ID == ID {
        filter { element in
            element.id != id
        }
    }
}
