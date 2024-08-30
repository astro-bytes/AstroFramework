//
//  ActionableError.swift
//  
//
//  Created by Porter McGary on 7/29/24.
//

import Foundation

// TODO: Add Comments
public protocol ActionableError: DisplayableError {
    var label: String { get }
    
    func perform() throws -> Void
}
