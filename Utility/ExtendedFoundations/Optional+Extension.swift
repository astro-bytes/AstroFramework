//
//  Optional+Extension.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation

extension Optional {
    /// Flag Indicating the Optional is indeed `nil`
    public var isNil: Bool { self == nil }
    
    /// Flag Indicating the Optional is indeed NOT `nil`
    public var isNotNil: Bool { self != nil }
}
