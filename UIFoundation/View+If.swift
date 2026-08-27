//
//  View+If.swift
//  UIFoundation
//
//  Created by Porter McGary on 9/17/23.
//

import SwiftUI
import UtilityFoundation

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    ///
    /// - Important: The two branches are structurally different views, so flipping `condition`
    ///   changes the subtree's identity — SwiftUI tears down what was there and builds the other
    ///   branch fresh, taking any `@State`, `@FocusState` and in-flight animation with it. That is
    ///   invisible for a leaf like `.foregroundStyle`, and a real bug for anything holding state.
    ///
    ///   Prefer a modifier that takes the condition itself — `.opacity`, `.disabled`, `.hidden` —
    ///   or a modifier applied unconditionally with a conditional value:
    ///
    ///   ```swift
    ///   // Instead of: .if(isEmphasised) { $0.foregroundStyle(.tint) }
    ///   .foregroundStyle(isEmphasised ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
    ///   ```
    ///
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder public func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies the given transform if the given value is non-`nil`, handing it to the transform.
    ///
    /// - Important: Carries the same identity caveat as ``if(_:transform:)-(Bool,_)``: the subtree
    ///   is rebuilt when `value` changes between `nil` and non-`nil`.
    ///
    /// - Parameters:
    ///   - value: The conditional value.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the value is non-`nil`.
    @ViewBuilder public func `if`<Content: View, Arg>(_ value: Arg?, transform: (Self, Arg) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}
