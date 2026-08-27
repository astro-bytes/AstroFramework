//
//  AsyncButton.swift
//  UIFoundation
//
//  Created by Porter McGary on 8/21/24.
//

import SwiftUI

/// A button whose action is asynchronous, and which cannot be pressed again while it is running.
///
/// ```swift
/// AsyncButton("Save") {
///     try await store.save(draft)
/// }
/// ```
///
/// While the action runs the button is disabled and its label is replaced by a progress indicator,
/// laid over the label rather than in place of it so the button does not change size. A thrown
/// error is presented with ``SwiftUI/View/errorAlert(error:)``.
public struct AsyncButton<Label: View>: View {
    @State private var error: (any Error)?

    /// Guards against the action being started a second time before the first finishes — the one
    /// thing an async button exists to prevent, and which nothing here used to do.
    @State private var isRunning = false

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
            run()
        } label: {
            label
                // Keeps the button's footprint while the indicator is up, so a row of buttons does
                // not reflow when one of them starts working.
                .opacity(isRunning ? 0 : 1)
                .overlay {
                    if isRunning {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
        }
        .disabled(isRunning)
        .animation(.default, value: isRunning)
        .errorAlert(error: $error)
    }

    private func run() {
        guard !isRunning else { return }
        isRunning = true

        Task {
            defer { isRunning = false }

            do {
                try await action()
            } catch {
                self.error = error
            }
        }
    }
}
