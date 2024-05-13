//
//  UseCase.swift
//
//
//  Created by Porter McGary on 5/13/24.
//

import Foundation

/// A protocol representing a synchronous use case.
/// Conforming types must implement the `execute` method to perform the use case operation synchronously.
/// - Note: The associated types `Arguments` and `Yield` define the input arguments and the result type respectively.
public protocol UseCase {
    
    /// The type representing the input arguments for the use case.
    associatedtype Arguments
    
    /// The type representing the result of the use case operation.
    associatedtype Yield
    
    /// Executes the use case synchronously.
    /// - Parameter arguments: The input arguments required for the use case.
    /// - Returns: The result of the use case operation of type `Yield`.
    /// - Throws: An error if the use case execution encounters any issues.
    func execute(_ arguments: Arguments) throws -> Yield
}
