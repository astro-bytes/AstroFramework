//
//  File.swift
//  
//
//  Created by Porter McGary on 1/30/24.
//

import Combine
import Foundation
import GatewayBasics
import UseCaseBasics


//public class BasicKeyedRepository<Element: Identifiable>: KeyedRepository {
//    public typealias Payload = [Element.ID: Element]
//    
//    let store: AnyKeyedDataStore<Element>
//    public var data: AnyPublisher<DataResult<Payload>, Never> {
//        store.data
//    }
//    
//    init(store: any KeyedDataStore<Element>) {
//        self.store = store
//    }
//    
//    public func refresh() {
//        store.refresh()
//    }
//    
//    public func refresh() async -> DataResult<Payload> {
//        await store.refresh()
//    }
//    
//    public func get() -> DataResult<[Element.ID : Element]> {
//        store.get()
//    }
//    
//    public func get(by id: Element.ID) -> DataResult<Element> {
//        store.get(by: id)
//    }
//    
//    public func set(_ payload: [Element.ID : Element]) {
//        store.set(payload)
//    }
//    
//    public func set(_ element: Element) {
//        store.set(element)
//    }
//    
//    public func clear() {
//        store.clear()
//    }
//    
//    public func clear(by id: Element.ID) {
//        store.clear(by: id)
//    }
//}
