//
//  ErrorAlert+ViewModifier.swift
//  UIFoundation
//
//  Created by Porter McGary on 1/19/24.
//

import SwiftUI
import LoggerFoundation
import UtilityFoundation

struct ErrorAlertViewModifier: ViewModifier {
    
    @Environment(\.reportError) var report
    @Binding var error: (any Error)?
    
    init(error: Binding<(any Error)?>) {
        self._error = error
    }
    
    var isPresented: Binding<Bool> {
        Binding<Bool> {
            error.isNotNil
        } set: { newValue in
            guard !newValue else { return }
            error = nil
        }
    }
    
    var title: String {
        switch error {
        case let displayError as DisplayableError:
            displayError.title
        default:
            "Error"
        }
    }
    
    var body: String? {
        switch error {
        case let displayError as DisplayableError:
            displayError.message
        case let localError as LocalizedError:
            localError.recoverySuggestion
        default:
            "Sorry, something went wrong. Please try again later."
        }
    }
    
    var dismissible: Bool {
        switch error {
        case let displayableError as DisplayableError:
            displayableError.dismissible
        default:
            true
        }
    }
    
    var reportable: Bool {
        switch error {
        case let displayableError as DisplayableError:
            displayableError.reportable
        default:
            report.isNotNil
        }
    }
    
    func body(content: Content) -> some View {
        // The alert goes on unconditionally. Branching the body on `if let error` gave the two
        // states structurally different views, so presenting and dismissing changed the view's
        // identity underneath SwiftUI — which is what makes alerts drop, double-fire, or skip
        // their transition. `isPresented` is false while the error is nil, which is all the
        // condition this ever needed.
        content.alert(title, isPresented: isPresented) {
            actions
        } message: {
            if let body {
                Text(body)
            }
        }
    }

    @ViewBuilder
    private var actions: some View {
        if let error {
            // Without a dismiss button of its own, the alert needs the action button to carry the
            // cancel role so there is still an obvious way out.
            let actionRole: ButtonRole? = reportable && !dismissible ? .cancel : nil

            if let actionError = error as? ActionableError {
                Button(actionError.label, role: actionRole) {
                    perform(actionError)
                }
            }

            if let actionError = error as? AsyncActionableError {
                Button(actionError.label, role: actionRole) {
                    Task { await perform(actionError) }
                }
            }

            if reportable, let report {
                Button("Report") {
                    report(error)
                    if let actionError = error as? ActionableError {
                        perform(actionError)
                    }
                }
            }

            if dismissible {
                Button("OK", role: .cancel, action: {})
            }
        }
    }

    /// Runs the error's own recovery action, replacing the presented error if it fails.
    private func perform(_ actionError: any ActionableError) {
        do {
            try actionError.perform()
        } catch {
            self.error = error
        }
    }

    private func perform(_ actionError: any AsyncActionableError) async {
        do {
            try await actionError.perform()
        } catch {
            self.error = error
        }
    }
}

public extension EnvironmentValues {
    /// The closure called when the user asks for an error to be reported, or `nil` if the app has
    /// not offered one — in which case no Report button is shown.
    ///
    /// Set it with ``SwiftUI/View/reportError(_:)``. The `@Entry` macro replaces a hand-written
    /// `EnvironmentKey` whose `static var defaultValue` was global mutable state.
    @Entry var reportError: (@Sendable (any Error) -> Void)?
}

public extension View {
    /// Presents an alert when `error` becomes non-`nil`, clearing it again on dismissal.
    ///
    /// The alert titles and describes itself from the error. Conform it to ``DisplayableError`` to
    /// choose the wording, ``ActionableError`` to offer a recovery button, and
    /// ``AsyncActionableError`` when that recovery is asynchronous. Anything else gets a generic
    /// title and message.
    ///
    /// ```swift
    /// struct ProfileView: View {
    ///     @State private var error: (any Error)?
    ///
    ///     var body: some View {
    ///         List { /* ... */ }
    ///             .errorAlert(error: $error)
    ///             .task {
    ///                 do { try await load() } catch { self.error = error }
    ///             }
    ///     }
    /// }
    /// ```
    ///
    /// ## Report button
    ///
    /// Supply a handler with ``reportError(_:)`` and errors marked reportable gain a Report
    /// button. Without a handler no button is shown, whatever the error asks for.
    ///
    /// - Parameter error: The error to present. Set back to `nil` when the alert is dismissed.
    func errorAlert(error: Binding<(any Error)?>) -> some View {
        modifier(ErrorAlertViewModifier(error: error))
    }

    /// Supplies the action taken when the user presses Report on an error alert.
    ///
    /// Read from the environment, so one call near the root covers every alert beneath it.
    ///
    /// ```swift
    /// ContentView()
    ///     .reportError { crashReporter.record($0) }
    /// ```
    ///
    /// - Parameter action: What to do with a reported error.
    func reportError(_ action: @escaping @Sendable (any Error) -> Void) -> some View {
        environment(\.reportError, action)
    }
}
