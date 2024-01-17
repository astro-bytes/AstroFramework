//
//  Set+Extension.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation

extension Set {
    // TODO: Comment & Test
    public var asArray: [Element] {
        map { $0 }
    }
}
