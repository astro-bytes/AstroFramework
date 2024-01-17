//
//  KeyedDataStore.swift
//  GatewatBasics
//
//  Created by Porter McGary on 1/20/24.
//

import Foundation
import UseCaseBasics

// TODO: Comment
public protocol KeyedDataStore<Element>: DataStore where Payload == [Element.ID: Element] {
    // TODO: Comment
    associatedtype Element: Identifiable
    
    // TODO: Comment
    func get(by id: Element.ID) -> DataResult<Payload.Element>
    
    // TODO: Comment
    func set(_ element: Element)
    
    // TODO: Comment
    func clear(by id: Element.ID)
    
    // TODO: Comment
    func clear(by element: Element)
}
