//
//  IdentifiablePublishableDataSource.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/23/24.
//

import Combine
import Foundation

/// A protocol representing a data source that provides publishers for identifiable payloads.
/// This protocol is designed for types that can publish data identified by unique identifiers.
public protocol IdentifiablePublishableDataSource<IdentifiableOutput> {
    
    /// The associated type representing the payload that is identifiable.
    associatedtype IdentifiableOutput: Identifiable
    
    /// Returns a publisher for the specified identifier.
    /// - Parameter id: The identifier of the payload.
    /// - Returns: A publisher emitting the payload for the given identifier or an error.
    func publisherForValue(with id: IdentifiableOutput.ID) -> AnyPublisher<IdentifiableOutput, Error>
}

