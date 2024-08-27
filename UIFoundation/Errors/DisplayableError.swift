//
//  DisplayableError.swift
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
    var reportable: Bool { get }
}

extension DisplayableError {
    public var dismissible: Bool { true }
    public var reportable: Bool { false }
}
