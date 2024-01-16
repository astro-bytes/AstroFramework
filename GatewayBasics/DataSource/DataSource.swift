//
//  DataSource.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation

/// A protocol for data sources that can fetch Payloads.
public protocol DataSource<Payload> {
    /// Generic representing the return value of a successful fetch
    associatedtype Payload
    
    /// Fetches the payload
    /// - Returns a result as a ``Payload`` or as an ``Error``
    func fetch() -> Result<Payload, Error>
}
