//
//  DisplayableError.swift
//  UIFoundation
//
//  Created by Porter McGary on 7/29/24.
//

import Foundation

/// An error that knows how to present itself.
///
/// ``SwiftUI/View/errorAlert(error:)`` looks for this conformance to title the alert and write its
/// message. An error without it gets a generic title and a generic apology, which is rarely what
/// the person reading it needs.
public protocol DisplayableError: LocalizedError {
    /// The alert's title.
    var title: String { get }

    /// The alert's body. `nil` shows a title-only alert.
    var message: String? { get }

    /// Whether the alert offers a plain dismiss button. Defaults to `true`.
    ///
    /// `false` only makes sense for an error the user has to act on — pair it with
    /// ``ActionableError`` so there is still a way forward.
    var dismissible: Bool { get }

    /// Whether the alert offers a Report button. Defaults to `false`.
    ///
    /// The button only appears if the app also supplied a handler with
    /// ``SwiftUI/View/reportError(_:)``.
    var reportable: Bool { get }
}

extension DisplayableError {
    public var dismissible: Bool { true }
    public var reportable: Bool { false }
}
