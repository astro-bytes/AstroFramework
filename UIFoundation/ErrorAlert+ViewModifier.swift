//
//  ErrorAlert+ViewModifier.swift
//  UniversalUI
//
//  Created by Porter McGary on 1/19/24.
//

import SwiftUI
import LoggerFoundation
import UtilityFoundation

private struct ErrorAlertViewModifier: ViewModifier {
    
    @Environment(\.reportError) var report
    
    @Binding var error: Error?
    let retry: (() -> Void)?
    
    init(error: Binding<Error?>, retry: (() -> Void)? = nil) {
        self._error = error
        self.retry = retry
    }
    
    init(error: Binding<Error?>, asyncRetry: @escaping () async -> Void) {
        self.init(error: error) { Task { await asyncRetry() } }
    }
    
    var isPresented: Binding<Bool> {
        Binding<Bool> {
            error.isNotNil
        } set: { newValue in
            guard !newValue else { return }
            error = nil
        }
    }
    
    func body(content: Content) -> some View {
        // if the error is localized then display the localized error's recovery suggestion
        if let localizedError = error as? LocalizedError {
            content.alert("Error", isPresented: isPresented) {
                if let retry {
                    Button("Retry", action: retry)
                }
                
                if localizedError.recoverySuggestion.isNil, let report {
                    Button("Report", role: .destructive, action: { report(localizedError) })
                }
                
                Button("OK", role: .cancel, action: {})
            } message: {
                Text(localizedError.recoverySuggestion ??
                     "Recovery Suggestion Required - Inform Development Team - \(String(describing: localizedError))")
            }
        } else if let error {
            content
                .alert("Error", isPresented: isPresented) {
                    if let retry {
                        Button("Retry", action: retry)
                    }
                    
                    if let report {
                        Button("Report", role: .destructive, action: { report(error) })
                    }
                    
                    Button("OK", role: .cancel, action: {})
                } message: {
                    Text("Something went wrong and we don't know what happened.")
                }
                .onAppear {
                    Logger.log(
                        .critical,
                        // swiftlint:disable:next line_length
                        msg: "Failed to present \(String(describing: error)) because error is not of type LocalizedError",
                        domain: "UniversalUI")
                }
        } else {
            content
        }
    }
}

private struct ReportErrorEnvironmentKey: EnvironmentKey {
    static var defaultValue: ((Error) -> Void)?
}

extension EnvironmentValues {
    /// A key for setting and retrieving the closure to report errors.
    public var reportError: ((Error) -> Void)? {
        get { self[ReportErrorEnvironmentKey.self] }
        set { self[ReportErrorEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Presents an alert dialog when an error occurs.
    /// - Parameters:
    ///   - error: Binded value when not nil presents the error and provides the error itself and is return to nil on dismiss
    ///   - retry: A function that is defaulted to nil but when provided with a definition will call when the user presses the retry button. When nil the retry button is not displayed
    ///
    ///  ## Report button
    /// Additionally use the `.reportError(_:)` function to perform an action when the user presses the report button on the dialog.
    /// If this environment value is not provided no reporting is done ad no report button is shown
    // TODO: Add Example
    public func errorAlert(error: Binding<Error?>, retry: (() -> Void)? = nil) -> some View {
        modifier(ErrorAlertViewModifier(error: error, retry: retry))
    }
    
    /// Presents an alert dialog when an error occurs. with an asynchronous retry
    /// - Parameters:
    ///   - error: Binded value when not nil presents the error and provides the error itself and is return to nil on dismiss
    ///   - retry: A function that is defaulted to nil but when provided with a definition will call when the user presses the retry button. When nil the retry button is not displayed
    ///
    ///  ## Report button
    /// Additionally use the `.reportError(_:)` function to perform an action when the user presses the report button on the dialog.
    /// If this environment value is not provided no reporting is done ad no report button is shown
    // TODO: Add Example
    public func errorAlert(error: Binding<Error?>, asyncRetry: @escaping () async -> Void) -> some View {
        modifier(ErrorAlertViewModifier(error: error, asyncRetry: asyncRetry))
    }
    
    /// Adds an environment variable that is called when needing to report an error
    /// - Parameter action: the functionality provided when reporting an error
    // TODO: Add Example
    public func reportError(_ action: @escaping (Error) -> Void) -> some View {
        environment(\.reportError, action)
    }
}
