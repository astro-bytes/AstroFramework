//
//  MockKeyedRepository.swift
//  Mocks
//
//  Created by Porter McGary on 2/9/24.
//

import Combine
import Foundation
import UseCaseFoundation

public class MockKeyedRepository<Element: Identifiable>: KeyedRepository {
    public typealias Payload = [Element.ID: Element]
    
    var calledRefresh = false
    var calledAsyncRefresh = false
    var calledSet = false
    var calledSetElement = false
    var calledClear = false
    var calledClearByID = false
    
    let subject: CurrentValueSubject<DataResult<Payload>, Never>
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
    
    public func set(_ payload: [Element.ID : Element]) {
        calledSet = true
        subject.send(.success(data: payload))
    }
    
    public func clear() {
        calledClear = true
        subject.send(.uninitialized)
    }
}
