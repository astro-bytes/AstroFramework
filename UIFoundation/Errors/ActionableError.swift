//
//  ActionableError.swift
//  UIFoundation
//
//  Created by Porter McGary on 7/29/24.
//

import Foundation

/// A ``DisplayableError`` that offers the user something to do about it.
///
/// The alert gains a button labelled ``label`` which calls ``perform()``. If that throws, the new
/// error replaces the presented one.
public protocol ActionableError: DisplayableError {
    /// The title of the button offering the action.
    var label: String { get }
    
    /// Attempts to recover. A thrown error is presented in place of this one.
    func perform() throws
}
