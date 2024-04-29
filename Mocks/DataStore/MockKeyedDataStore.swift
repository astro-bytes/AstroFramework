//
//  MockKeyedDataStore.swift
//  Mocks
//
//  Created by Porter McGary on 2/9/24.
//

import Foundation
import Combine
import UseCaseFoundation
import GatewayBasics
import Utility

public class MockKeyedDataStore<Element: Identifiable>: KeyedDataStore {
    public typealias Payload = [Element.ID: Element]
    
    var calledSetElement = false
    var calledClearByID = false
    var calledRefresh = false
    var calledAsyncRefresh = false
    var calledAsyncRefreshByID = false
    var calledRefreshByID = false
    var calledSet = false
    var calledClear = false
    var calledGet = false
    var calledGetID = false
    
    let subject: CurrentValueSubject<DataResult<Payload>, Never>
    
    public var data: AnyPublisher<UseCaseFoundation.DataResult<Payload>, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public init(_ value: DataResult<Payload>) {
        subject = .init(value)
    }
    
    public func set(_ element: Payload.Element) {
        calledSetElement = true
    }
    
    public func clear(by id: Element.ID) {
        calledClearByID = true
    }
    
    public func refresh() {
        calledRefresh = true
    }
    
    public func refresh() async -> UseCaseFoundation.DataResult<Payload> {
        calledAsyncRefresh = true
        return subject.value
    }
    
    public func refresh(by id: Element.ID) async -> UseCaseFoundation.DataResult<Element> {
        calledAsyncRefreshByID = true
        return get(by: id)
    }
    
    public func refresh(by id: Element.ID) {
        calledRefreshByID = true
    }
    
    public func set(_ payload: Payload) {
        calledSet = true
    }
    
    public func set(_ element: Element) {
        calledSetElement = true
    }
    
    public func clear() {
        calledClear = true
    }
    
    public func get() -> DataResult<Payload> {
        calledGet = true
        return subject.value
    }
    
    public func get(by id: Element.ID) -> DataResult<Element> {
        calledGetID = true
        guard let value = subject.value.payload?[id] else {
            return .failure(cachedData: nil, error: CoreError.notFound)
        }
        return .success(data: value)
    }
}
