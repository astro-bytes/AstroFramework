//
//  Car.swift
//  Mocks
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation
import EntityFoundation

public struct Car: Entity, Codable {
    public var id: UUID
    public var brand: String
    public var model: String
    
    public init(id: UUID = UUID(), brand: String, model: String) {
        self.id = id
        self.brand = brand
        self.model = model
    }
}

public extension Car {
    static let civic = Car(brand: "Honda", model: "Civic")
    static let model3 = Car(brand: "Tesla", model: "Model 3")
}
