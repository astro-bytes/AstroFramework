//
//  User.swift
//  Mocks
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation
import EntityFoundation

public struct User: Entity, Codable {
    public var id: UUID
    public var name: String
    public var age: Int
    
    public init(id: UUID = UUID(), name: String, age: Int) {
        self.id = id
        self.name = name
        self.age = age
    }
}

public extension User {
    static let johnDoe = User(name: "John Doe", age: 25)
    static let janeDoe = User(name: "Jane Doe", age: 23)
}
