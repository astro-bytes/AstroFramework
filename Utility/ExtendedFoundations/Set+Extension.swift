//
//  Set+Extension.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation

/// An extension on Set providing a computed property to convert the set to an array.
extension Set {
    /// Converts the set to an array.
    /// - Returns: An array containing the elements of the set.
    public var asArray: [Element] {
        map { $0 }
    }
}
