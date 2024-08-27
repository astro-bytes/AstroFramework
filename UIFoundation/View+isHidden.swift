//
//  File.swift
//  
//
//  Created by Porter McGary on 8/19/24.
//

import SwiftUI

extension View {
    @ViewBuilder public func isHidden(_ condition: Bool) -> some View {
        if condition {
            self.hidden()
        } else {
            self
        }
    }
}
