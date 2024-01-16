//
//  File.swift
//  
//
//  Created by Porter McGary on 1/30/24.
//

import Foundation

public protocol KeyedRepository<Element>: Repository {
    associatedtype Element: Identifiable
    
    func get(by id: Element.ID) -> DataResult<Element>
    
    func set(_ element: Element)
    
    func clear(by id: Element.ID)
}
