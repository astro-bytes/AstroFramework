//
//  File.swift
//  
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation
import GatewayBasics
import Combine

// Get the Local user info
class UserRepository: Repository {
    typealias Payload = User
    
    var user: User?
    var data: AnyPublisher<DataResult<User>, Never> = PassthroughSubject<DataResult<User>, Never>().eraseToAnyPublisher()
    
    func refresh() {
        
    }
    
    func refresh() async -> GatewayBasics.DataResult<User> {
        get()
    }
    
    func get() -> GatewayBasics.DataResult<User> {
        guard let user else {
            // if nil
            return .loading
        }
        // if not nil
        return .success(data: user)
    }
    
    func set(_ user: User) {
        self.user = user
    }
    
    func clear() {
        user = nil
    }
}

// Get all the other user
class UsersRepository: Repository {
    typealias Payload = [User]
    
    var users: [User] = []
    var data: AnyPublisher<GatewayBasics.DataResult<[User]>, Never> = PassthroughSubject<DataResult<[User]>, Never>().eraseToAnyPublisher()
    
    func refresh() {
        Task {
            await refresh()
        }
    }
    
    @discardableResult
    func refresh() async -> GatewayBasics.DataResult<[User]> {
        .success(data: users)
    }
    
    func get() -> GatewayBasics.DataResult<[User]> {
        .success(data: users)
    }
    
    func set(_ users: [User]) {
        self.users = users
    }
    
    func clear() {
        users = []
    }
}
