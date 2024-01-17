//
//  File.swift
//  
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation

struct User: Equatable {
    var name: String
    var age: Int
}

extension User {
    static let johnDoe = User(name: "John Doe", age: 25)
    static let janeDoe = User(name: "Jane Doe", age: 23)
}
