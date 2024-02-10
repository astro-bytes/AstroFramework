//
//  CoreError.swift
//  Utility
//
//  Created by Porter McGary on 1/20/24.
//

import Foundation

/// An enumeration representing common errors in the core module.
public enum CoreError: Error {
    /// Indicates that the requested item was not found.
    case notFound
    
    /// Indicates a timeout error.
    case timeout
}
