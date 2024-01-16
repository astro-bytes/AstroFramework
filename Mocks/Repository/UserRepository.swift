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
public class UserRepository: Repository {
    public typealias Payload = User
    
    public let publisher: PassthroughSubject<DataResult<User>, Never>
    public let store: any CollectionDataStore<[User]>
    public let defaults: UserDefaults
    
    public var userID: User.ID? {
        get { defaults.object(forKey: "user_id") as? User.ID }
        set { defaults.set(newValue, forKey: "user_id") }
    }
    
    public var data: AnyPublisher<DataResult<User>, Never> {
        publisher.eraseToAnyPublisher()
    }
    
    public init(store: any CollectionDataStore<[User]>) {
        guard let defaults = UserDefaults(suiteName: "test") else {
            fatalError("Failed to initialize UserDefaults")
        }
        
        self.store = store
        self.publisher = .init()
        self.defaults = defaults
    }
    
    public func refresh() {
        store.refresh()
    }
    
    public func refresh() async -> DataResult<User> {
        guard let userID else { return .uninitialized }
        let result = await store.refresh()
        switch result {
        case .uninitialized:
            return .uninitialized
        case .loading:
            return .loading(cachedData: nil)
        case .success(let data):
            guard let user = data.first(by: userID) else { return .uninitialized }
            return .success(data: user)
        case .failure(_, let error):
            return .failure(cachedData: nil, error: error)
        }
    }
    
    public func get() -> DataResult<User> {
        guard let userID else { return .uninitialized }
        return store.get(by: userID)
    }
    
    public func set(_ user: User) {
        userID = user.id
        store.set(user)
    }
    
    public func clear() {
        guard let userID else { return }
        store.clear(by: userID)
    }
}

public enum RepositoryError: Error {
    case notFound
}
