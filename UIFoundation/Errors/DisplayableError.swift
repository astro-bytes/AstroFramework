//
//  File.swift
//  
//
//  Created by Porter McGary on 7/29/24.
//

import Foundation

// TODO: Add Comments
public protocol DisplayableError: LocalizedError {
    var title: String { get }
    var message: String? { get }
    var dismissible: Bool { get }
}

public extension DisplayableError {
    var dismissible: Bool { true }
}
