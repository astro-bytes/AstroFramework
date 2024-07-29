//
//  File.swift
//  
//
//  Created by Porter McGary on 7/29/24.
//

import Foundation

// TODO: Add Comments
public struct RetryableError: ActionableError {
    public let title: String
    public let message: String
    public let label: String = "Retry"
    public let underlyingError: Error
    
    private let action: () -> Void
    
    public init(title: String = "Error", message: String, error: Error, retry action: @escaping () -> Void) {
        self.action = action
        self.title = title
        self.message = message
        self.underlyingError = error
    }
    
    public init(title: String = "Error", message: String, error: Error, asyncRetry action: @escaping () async -> Void) {
        self.init(title: title, message: message, error: error) {
            Task {
                await action()
            }
        }
    }
    
    public init(title: String = "Error", error: LocalizedError, retry action: @escaping () -> Void) {
        self.init(title: title, message: error.recoverySuggestion ?? "", error: error, retry: action)
    }
    
    public init(title: String = "Error", error: LocalizedError, asyncRetry action: @escaping () async -> Void) {
        self.init(title: title, message: error.recoverySuggestion ?? "", error: error, asyncRetry: action)
    }
    
    public func perform() {
        action()
    }
}
