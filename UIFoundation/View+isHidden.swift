//
//  View+isHidden.swift
//  UIFoundation
//
//  Created by Porter McGary on 8/19/24.
//

import SwiftUI

extension View {
    /// Hides the view while `condition` is `true`, keeping the space it occupies.
    ///
    /// Unlike a conditional branch, a hidden view keeps its identity and its state — it is still
    /// there, just not drawn.
    /// - Parameter condition: Whether to hide the view.
    @ViewBuilder public func isHidden(_ condition: Bool) -> some View {
        if condition {
            self.hidden()
        } else {
            self
        }
    }
}
