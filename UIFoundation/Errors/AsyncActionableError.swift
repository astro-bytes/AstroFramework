//
//  File.swift
//  
//
//  Created by Porter McGary on 8/29/24.
//

import Foundation

// TODO: Comment
public protocol AsyncActionableError: DisplayableError {
    var label: String { get }
    
    func perform() async throws -> Void
}
