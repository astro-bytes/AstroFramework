//
//  File.swift
//  
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation

struct CreateUser {
    
    let userRepo: UserRepository
    let usersRepo: UsersRepository
    
    func execute(name: String, age: Int) -> [User] {
        let user = User(name: name, age: age)
        // setting the local user's info
        userRepo.set(user)
        
        let result = usersRepo.get()
        switch result {
        case .success(data: let users):
            return users
        default:
            return []
        }
    }
}
