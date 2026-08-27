//
//  MockKeyedDataStore.swift
//  Mocks
//
//  Created by Porter McGary on 2/9/24.
//

import Foundation
import Combine
import UseCaseFoundation
import GatewayFoundation
import UtilityFoundation

/// `@unchecked` because the spy flags are plain stored properties. The value it publishes goes
/// through `CurrentValueSubject`, which is thread-safe; tests read the flags after the work under
/// test has finished.
public final class MockKeyedDataStore<Element: Identifiable & Sendable>: KeyedDataStore, @unchecked Sendable where Element.ID: Sendable {
    public typealias Payload = [Element.ID: Element]
    
    public private(set) var calledSetElement = false
    public private(set) var calledClearByID = false
    public private(set) var calledRefresh = false
    public private(set) var calledAsyncRefresh = false
    public private(set) var calledAsyncRefreshByID = false
    public private(set) var calledRefreshByID = false
    public private(set) var calledSet = false
    public private(set) var calledClear = false
    public private(set) var calledGet = false
    public private(set) var calledGetID = false
    
    public let subject: CurrentValueSubject<DataResult<Payload>, Never>
    
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
