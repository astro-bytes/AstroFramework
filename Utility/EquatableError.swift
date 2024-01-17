//
//  EquatableError.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation

/// Credit to: https://sideeffect.io/posts/2021-12-10-equatableerror/
// TODO: Comment
public struct EquatableError: Error, Equatable, CustomStringConvertible {
    // TODO: Comment
    public let base: Error
    
    // TODO: Comment
    private let equals: (Error) -> Bool
    
    // TODO: Comment
    public init<Base: Error>(_ base: Base) {
        self.base = base
        self.equals = { String(reflecting: $0) == String(reflecting: base) }
    }
    
    // TODO: Comment
    public init<Base: Error & Equatable>(_ base: Base) {
        self.base = base
        self.equals = { ($0 as? Base) == base }
    }
    
    // TODO: Comment
    public static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        lhs.equals(rhs.base)
    }
    
    // TODO: Comment
    public var description: String {
        "\(self.base)"
    }
    
    // TODO: Comment
    public func asError<Base: Error>(type: Base.Type) -> Base? {
        self.base as? Base
    }
    
    // TODO: Comment
    public var localizedDescription: String {
        self.base.localizedDescription
    }
}

extension Error where Self: Equatable {
    // TODO: Comment
    public func toEquatableError() -> EquatableError {
        EquatableError(self)
    }
}

extension Error {
    public func toEquatableError() -> EquatableError {
        EquatableError(self)
    }
}
