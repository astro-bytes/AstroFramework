//
//  UserRepository.swift
//  Mocks
//
//  Created by Porter McGary on 1/17/24.
//

import Combine
import Foundation
import GatewayBasics
import UseCaseBasics

// Get the Local user info
public class MockRepository<Payload>: Repository {
    var calledRefresh = false
    var calledAsyncRefresh = false
    var calledSet = false
    var calledClear = false
    
    public let publisher: CurrentValueSubject<DataResult<Payload>, Never>
    
    public var data: AnyPublisher<DataResult<Payload>, Never> {
        publisher.eraseToAnyPublisher()
    }
    
    public init(_ value: DataResult<Payload>) {
        self.publisher = .init(value)
    }
    
    public func refresh() {
        calledRefresh = true
    }
    
    public func refresh() async -> UseCaseBasics.DataResult<Payload> {
        calledAsyncRefresh = true
        return publisher.value
    }
    
    public func set(_ payload: Payload) {
        calledSet = true
        publisher.send(.success(data: payload))
    }
    
    public func clear() {
        calledClear = true
    }
}
