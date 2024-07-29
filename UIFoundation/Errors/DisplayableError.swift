//
//  File.swift
//  
//
//  Created by Porter McGary on 7/29/24.
//

import Foundation

// TODO: Add Comments
public protocol DisplayableError: LocalizedError {
    var title: String { get }
    var message: String { get }
    var underlyingError: Error { get }
}

// TODO: Add Comments
public extension DisplayableError {
    var recoverySuggestion: String? { message }
    var failureReason: String? { underlyingError.localizedDescription }
}
