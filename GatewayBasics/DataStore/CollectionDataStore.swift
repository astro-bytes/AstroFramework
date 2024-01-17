//
//  CollectionDataStore.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/20/24.
//

import Foundation
import UseCaseBasics

public protocol CollectionDataStore<Payload>: DataStore where Payload: Collection, Payload.Element : Identifiable {
    // TODO: Comment
    func get(by id: Payload.Element.ID) -> DataResult<Payload.Element>
    
    // TODO: Comment
    func set(_ element: Payload.Element)
    
    // TODO: Comment
    func clear(by id: Payload.Element.ID)
}
