//
//  Repository.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/16/24.
//

import Foundation

/// The Repository Protocol abstracts the data access layer and provides a set of methods to interact with the underlying data.
public protocol Repository {
    /// The object that the repository is attempting to get or set
    associatedtype Payload: Identifiable
    
    /// Used to get the Payload from a Data Store or Source
    /// - Parameter id: the identifier to the specific payload to be reached
    /// - Returns: the a non nil payload if found, otherwise nil.
    func get(id: Payload.ID) -> Payload?
    
    /// Used to get the Payload from a Data Store or Source
    /// - Parameter id: the identifier to the specific payload to be reached
    /// - Returns: the payload associated to the `id`
    /// - Throws: a ``GatewayError`` if there is a problem finding the payload
    func get(id: Payload.ID) throws -> Payload
    
    /// Used to get the Payload from a Data Store or Source asynchronously
    /// - Parameter id: the identifier to the specific payload to be reached
    /// - Returns: the a non nil payload if found, otherwise nil.
    func get(id: Payload.ID) async -> Payload?
    
    /// Used to get the Payload from a Data Store or Source asynchronously
    /// - Parameter id: the identifier to the specific payload to be reached
    /// - Returns: the payload associated to the `id`
    /// - Throws: a ``GatewayError`` if there is a problem finding the payload
    func get(id: Payload.ID) async throws -> Payload
    
    /// Used to set a particular payload value in the Data Store or Source
    /// - Parameter payload: This is the object that is setting in the data source
    /// - Returns: boolean flag indicating successful set when true, return value is discardable
    @discardableResult
    func set(payload: Payload) -> Bool
    
    /// Used to set a particular payload value in the Data Store or Source
    /// - Parameter payload: This is the object that is setting in the data source
    /// - Throws: a ``GatewayError`` if there is a problem setting the value
    func set(payload: Payload) throws
    
    /// Used to set a particular payload value in the Data Store or Source asynchronously
    /// - Parameter payload: This is the object that is setting in the data source
    /// - Returns: boolean flag indicating successful set when true, return value is discardable
    @discardableResult
    func set(payload: Payload) async -> Bool
    
    /// Used to set a particular payload value in the Data Store or Source asynchronously
    /// - Parameter payload: This is the object that is setting in the data source
    /// - Throws: a ``GatewayError`` if there is a problem setting the value
    func set(payload: Payload) async throws
}
