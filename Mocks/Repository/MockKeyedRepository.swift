//
//  MockKeyedRepository.swift
//  Mocks
//
//  Created by Porter McGary on 2/9/24.
//

import Combine
import Foundation
import UseCaseFoundation
import UtilityFoundation

/// `@unchecked` because the spy flags are plain stored properties. The value it publishes goes
/// through `CurrentValueSubject`, which is thread-safe; tests read the flags after the work under
/// test has finished.
public final class MockKeyedRepository<Element: Identifiable & Sendable>: KeyedRepository, @unchecked Sendable where Element.ID: Sendable {
    public typealias Payload = [Element.ID: Element]
    
    public private(set) var calledRefresh = false
    public private(set) var calledAsyncRefresh = false
    public private(set) var calledSet = false
    public private(set) var calledSetElement = false
    public private(set) var calledClear = false
    public private(set) var calledClearByID = false
    public private(set) var calledAsyncRefreshByID = false
    public private(set) var calledRefreshByID = false
    
    public let subject: CurrentValueSubject<DataResult<Payload>, Never>
    public var data: AnyPublisher<UseCaseFoundation.DataResult<[Element.ID : Element]>, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public init(_ value: DataResult<Payload>) {
        self.subject = .init(value)
    }
    
    public func set(_ element: Element) {
        calledSetElement = true
        guard var value = subject.value.payload else { return }
        value[element.id] = element
        subject.send(.success(data: value))
    }
    
    public func clear(by id: Element.ID) {
        calledClearByID = true
        guard var value = subject.value.payload else { return }
        value.removeValue(forKey: id)
        subject.send(.success(data: value))
    }
    
    public func refresh() {
        calledRefresh = true
    }
    
    public func refresh() async -> UseCaseFoundation.DataResult<[Element.ID : Element]> {
        calledAsyncRefresh = true
        return subject.value
    }

    public func refresh(by id: Element.ID) async -> DataResult<Element> {
        calledAsyncRefreshByID = true
        guard let value = subject.value.payload?[id] else {
            return .failure(cachedData: nil, error: CoreError.notFound)
        }
        return .success(data: value)
    }

    public func refresh(by id: Element.ID) {
        calledRefreshByID = true
    }
    
    public func set(_ payload: [Element.ID : Element]) {
        calledSet = true
        subject.send(.success(data: payload))
    }
    
    public func clear() {
        calledClear = true
        subject.send(.uninitialized)
    }
}
