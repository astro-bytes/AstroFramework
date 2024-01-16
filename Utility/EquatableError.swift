//
//  EquatableError.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation

/// A wrapper struct providing equatability to any type conforming to the Error protocol.
/// 
/// Credit [SideEffect.io](https://sideeffect.io/posts/2021-12-10-equatableerror/)
public struct EquatableError: Error, Equatable, CustomStringConvertible {
    /// The base error being wrapped.
    public let base: Error
    
    /// A closure defining the equality check for the base error.
    private let equals: (Error) -> Bool
    
    /// Initializes the EquatableError with a base error.
    /// - Parameter base: The base error to be wrapped.
    public init<Base: Error>(_ base: Base) {
        self.base = base
        self.equals = { String(reflecting: $0) == String(reflecting: base) }
    }
    
    /// Initializes the EquatableError with a base error that conforms to Equatable.
    /// - Parameter base: The base error to be wrapped.
    public init<Base: Error & Equatable>(_ base: Base) {
        self.base = base
        self.equals = { ($0 as? Base) == base }
    }
    
    /// Checks if two EquatableError instances are equal.
    /// - Parameters:
    ///   - lhs: The left-hand side EquatableError.
    ///   - rhs: The right-hand side EquatableError.
    /// - Returns: `true` if the base errors are considered equal; otherwise, `false`.
    public static func ==(lhs: EquatableError, rhs: EquatableError) -> Bool {
        lhs.equals(rhs.base)
    }
    
    /// A textual representation of the EquatableError.
    public var description: String {
        "\(self.base)"
    }
    
    /// Attempts to cast the base error to a specific type.
    /// - Parameter type: The type to cast the base error to.
    /// - Returns: The base error casted to the specified type, or `nil` if the cast is not possible.
    public func asError<Base: Error>(type: Base.Type) -> Base? {
        self.base as? Base
    }
    
    /// A localized description of the EquatableError.
    public var localizedDescription: String {
        self.base.localizedDescription
    }
}

extension Error where Self: Equatable {
    /// Converts an Error conforming to Equatable to an EquatableError.
    public func toEquatableError() -> EquatableError {
        EquatableError(self)
    }
}

extension Error {
    /// Converts any Error to an EquatableError.
    public func toEquatableError() -> EquatableError {
        EquatableError(self)
    }
}
