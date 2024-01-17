//
//  AnyRepository.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/16/24.
//

import Foundation

public class AnyRepository<Payload: Identifiable>: Repository {
    public func get(id: Payload.ID) -> Payload? {
        <#code#>
    }
    
    public func get(id: Payload.ID) throws -> Payload {
        <#code#>
    }
    
    public func get(id: Payload.ID) async -> Payload? {
        <#code#>
    }
    
    public func get(id: Payload.ID) async throws -> Payload {
        <#code#>
    }
    
    public func set(payload: Payload) -> Bool {
        <#code#>
    }
    
    public func set(payload: Payload) throws {
        <#code#>
    }
    
    public func set(payload: Payload) async -> Bool {
        <#code#>
    }
    
    public func set(payload: Payload) async throws {
        <#code#>
    }
}
