//
//  AsyncActionableError.swift
//  UIFoundation
//
//  Created by Porter McGary on 8/29/24.
//

import Foundation

/// A ``DisplayableError`` whose recovery action is asynchronous.
///
/// The asynchronous counterpart to ``ActionableError`` — a retry that has to go back to the
/// network, for instance.
public protocol AsyncActionableError: DisplayableError {
    /// The title of the button offering the action.
    var label: String { get }
    
    /// Attempts to recover. A thrown error is presented in place of this one.
    func perform() async throws
}
