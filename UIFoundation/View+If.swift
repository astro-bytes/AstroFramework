//
//  View+If.swift
//  PickEm
//
//  Created by Porter McGary on 9/17/23.
//

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
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
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The conditional value.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder public func `if`<Content: View, Arg>(_ value: Arg?, transform: (Self, Arg) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
    
    // TODO: Add Comments
    // TODO: Test that this works appropriately
    // TODO: Make Public if this works right
    @ViewBuilder func `if`<Argument>(_ args: Argument?..., @ViewBuilder transform: (Self, [Argument]) -> some View) -> some View {
        if args.allSatisfy({ $0.isNotNil }) {
            transform(self, args.compactMap { $0 })
        } else {
            self
        }
    }
}
