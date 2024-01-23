//
//  Collection+Extension.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation

/// An extension on Collection providing asynchronous versions of compactMap, map, and reduce operations.
extension Collection {
    /// Asynchronously applies a transformation to each element and returns an array of non-nil results.
    /// - Parameter transformation: The asynchronous transformation closure.
    /// - Returns: An array of non-nil results.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public func asyncCompactMap<Value>(_ transformation: (Element) async -> Value?) async -> [Value] {
        var transformedArray = [Value]()
        for element in self {
            if let value = await transformation(element) {
                transformedArray.append(value)
            }
        }
        return transformedArray
    }
    
    /// Asynchronously applies a throwing transformation to each element and returns an array of non-nil results.
    /// - Parameter transformation: The asynchronous throwing transformation closure.
    /// - Returns: An array of non-nil results.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public func asyncCompactMap<Value>(_ transformation: (Element) async throws -> Value?) async throws -> [Value] {
        var transformedArray = [Value]()
        for element in self {
            if let value = try await transformation(element) {
                transformedArray.append(value)
            }
        }
        return transformedArray
    }
    
    /// Asynchronously applies a transformation to each element and returns an array of results.
    /// - Parameter transformation: The asynchronous transformation closure.
    /// - Returns: An array of results.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public func asyncMap<Value>(_ transformation: (Element) async -> Value) async -> [Value] {
        var transformedArray = [Value]()
        for element in self {
            transformedArray.append(await transformation(element))
        }
        return transformedArray
    }
    
    /// Asynchronously applies a throwing transformation to each element and returns an array of results.
    /// - Parameter transformation: The asynchronous throwing transformation closure.
    /// - Returns: An array of results.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public func asyncMap<Value>(_ transformation: (Element) async throws -> Value) async throws -> [Value] {
        var transformedArray = [Value]()
        for element in self {
            transformedArray.append(try await transformation(element))
        }
        return transformedArray
    }
    
    /// Asynchronously reduces the collection into a single value.
    /// - Parameters:
    ///   - initialResult: The initial value to start the reduction.
    ///   - nextPartialResult: The asynchronous closure combining the current partial result and the next element.
    /// - Returns: The final result of the asynchronous reduction.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public func asyncReduce<Result>(into initialResult: Result, _ nextPartialResult: ((inout Result, Element) async throws -> Void)) async rethrows -> Result {
        var result = initialResult
        for element in self {
            try await nextPartialResult(&result, element)
        }
        return result
    }
    
    /// Asynchronously reduces the collection into a single value.
    /// - Parameters:
    ///   - initialResult: The initial value to start the reduction.
    ///   - nextPartialResult: The asynchronous closure combining the current partial result and the next element.
    /// - Returns: The final result of the asynchronous reduction.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
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
    /// Finds the first element in the collection with the specified ID.
    /// - Parameter id: The ID to search for.
    /// - Returns: The first element with the specified ID, or `nil` if not found.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public func first<ID>(by id: ID) -> Element? where Element.ID == ID {
        first { element in
            element.id == id
        }
    }
    
    /// Finds the index of the first element in the collection with the specified ID.
    /// - Parameter id: The ID to search for.
    /// - Returns: The index of the first element with the specified ID, or `nil` if not found.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public func firstIndex<ID>(by id: ID) -> Index? where Element.ID == ID {
        firstIndex { element in
            element.id == id
        }
    }
    
    /// Filters out elements with the specified ID.
    /// - Parameter id: The ID to filter out.
    /// - Returns: An array of elements that do not have the specified ID.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public func filterOut<ID>(_ id: ID) -> [Element] where Element.ID == ID {
        filter { element in
            element.id != id
        }
    }
}

