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
        if let error {
            content.alert(title, isPresented: isPresented) {
                if let actionError = error as? ActionableError {
                    let role: ButtonRole? = reportable && !dismissible ? .cancel : nil
                    Button(actionError.label, role: role) {
                        do {
                            try actionError.perform()
                        } catch {
                            self.error = error
                        }
                    }
                }
                
                if let actionError = error as? AsyncActionableError {
                    let role: ButtonRole? = reportable && !dismissible ? .cancel : nil
                    Button(actionError.label, role: role) {
                        Task { @MainActor in
                            do {
                                try await actionError.perform()
                            } catch {
                                self.error = error
                            }
                        }
                    }
                }
                
                if reportable, let report {
                    Button("Report", role: .destructive, action: {
                        report(error)
                        if let actionError = error as? ActionableError {
                            do {
                                try actionError.perform()
                            } catch {
                                self.error = error
                            }
                        }
                    })
                }
                
                if dismissible {
                    Button("OK", role: .cancel, action: {})
                }
            } message: {
                if let body {
                    Text(body)
                }
            }
        } else {
            content
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
    /// Presents an alert dialog when an error occurs.
    /// - Parameters:
    ///   - error: Binded value when not nil presents the error and provides the error itself and is return to nil on dismiss
    ///
    ///  ## Report button
    /// Additionally use the `.reportError(_:)` function to perform an action when the user presses the report button on the dialog.
    /// If this environment value is not provided no reporting is done ad no report button is shown
    // TODO: Add Example
    func errorAlert(error: Binding<(any Error)?>) -> some View {
        modifier(ErrorAlertViewModifier(error: error))
    }
    
    @available(*, deprecated)
    func errorAlert(error: Binding<(any Error)?>, retry: (() -> Void)? = nil) -> some View {
        modifier(ErrorAlertViewModifier(error: error))
    }
    
    // TODO: Add Example
    @available(*, deprecated)
    func errorAlert(error: Binding<(any Error)?>, asyncRetry: @escaping () async -> Void) -> some View {
        modifier(ErrorAlertViewModifier(error: error))
    }
    
    /// Adds an environment variable that is called when needing to report an error
    /// - Parameter action: the functionality provided when reporting an error
    // TODO: Add Example
    func reportError(_ action: @escaping @Sendable (any Error) -> Void) -> some View {
        environment(\.reportError, action)
    }
}

