//
//  TestSettingsViewModifier.swift
//  DailyDoublet
//
//  Created by Porter McGary on 11/6/24.
//

import SwiftUI

@available(macOS, unavailable)
public struct TestSettingsViewModifier: ViewModifier {
    @State private var isTestSettingsPresented = false
    
    private let sections: TestSettingSections
    private let buttonStyle: Color
    
    public init(_ sections: TestSettingSections, buttonStyle: Color = .accentColor) {
        self.sections = sections
        self.buttonStyle = buttonStyle
    }
    
    public func body(content: Content) -> some View {
        content.fullScreenCover(isPresented: $isTestSettingsPresented) {
            NavigationStack {
                TestSettingsView(sections).toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { isTestSettingsPresented = false } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isTestSettingsPresented = true
                } label: {
                    Image(systemName: "testtube.2")
                }
                .foregroundStyle(buttonStyle)
            }
        }
    }
}

@available(macOS, unavailable)
#Preview {
    Text("Hello, world!")
        .modifier(TestSettingsViewModifier([:]))
}
