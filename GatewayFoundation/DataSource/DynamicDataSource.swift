//
//  DynamicDataSource.swift
//  GatewayFoundation
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation

/// A ``DataSource`` whose fetch is parameterised.
public protocol DynamicDataSource<Payload> {
    /// Generic representing the return value of a successful fetch.
    associatedtype Payload: Sendable

    /// Generic representing the argument values that make a fetch specific.
    associatedtype Arguments

    /// Fetches the payload for a set of arguments.
    /// - Parameter arguments: What makes this fetch specific.
    /// - Returns: The fetched payload.
    /// - Throws: Whatever the underlying source failed with.
    func fetch(_ arguments: Arguments) async throws -> Payload
}
