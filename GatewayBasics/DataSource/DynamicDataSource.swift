//
//  DynamicDataSource.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation

/// A protocol for dynamic data sources that can fetch Payloads based on specific arguments.
public protocol DynamicDataSource<Payload> {
    /// Generic representing the return value of a successful fetch
    associatedtype Payload
    
    /// Generic representing the argument values that can be used to dynamically fetch Different forms of Payload
    associatedtype Arguments
    
    /// Fetches the payload based on a set of arguments
    /// - Parameter arguments: the argument parameters that make the fetch specific or uniquely dynamic
    /// - Returns a result as a ``Payload`` or as an ``Error``
    func fetch(_ arguments: Arguments) -> Result<Payload, Error>
}
