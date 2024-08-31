//
//  AsyncButton.swift
//  PickEm
//
//  Created by Porter McGary on 8/21/24.
//

import SwiftUI

public struct AsyncButton<Label: View>: View {
    @State private var error: Error?
    
    private let label: Label
    private let role: ButtonRole?
    private let action: () async throws -> Void
    
    public init(role: ButtonRole? = nil, action: @escaping () async throws -> Void, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.action = action
    }
    
    public init(_ label: String, role: ButtonRole? = nil, action: @escaping () async throws -> Void) where Label == Text {
        self.label = Text(label)
        self.role = role
        self.action = action
    }
    
    public var body: some View {
        Button(role: role) {
            Task { @MainActor in
                do {
                    try await action()
                } catch {
                    self.error = error
                }
            }
        } label: {
            label
        }
        .errorAlert(error: $error)
    }
}
