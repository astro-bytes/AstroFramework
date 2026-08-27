//
//  DataSource.swift
//  GatewayFoundation
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation

/// Somewhere a ``DataStore`` gets its data from.
///
/// A fetch that has to leave the process is asynchronous and reports failure by throwing, the same
/// as every other fetch in this module. It previously returned a `Result` synchronously, while
/// ``DynamicDataSource`` threw and ``MutableDataSource`` returned a `Result` asynchronously —
/// three conventions across four sibling protocols in one folder.
public protocol DataSource<Payload> {
    /// Generic representing the return value of a successful fetch.
    associatedtype Payload: Sendable

    /// Fetches the payload.
    /// - Returns: The fetched payload.
    /// - Throws: Whatever the underlying source failed with.
    func fetch() async throws -> Payload
}
