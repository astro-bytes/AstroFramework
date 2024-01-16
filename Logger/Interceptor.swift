//
//  Interceptor.swift
//  Logger
//
//  Created by Porter McGary on 1/18/24.
//

import Foundation

/// Blueprint for intercepting logs from the ``Logger``
///
/// To apply an intercepter, define a simple interceptor conforming to the Interceptor protocol
/// In this example, MyCustomInterceptor is a struct that conforms to the Interceptor protocol,
/// providing its own implementation for the intercept method.
/// The interceptor simply prints the log level and message to the console,
/// but you can customize it to perform any actions you need.
/// ```swift
/// struct MyCustomInterceptor: Interceptor {
///     func intercept(level: Logger.Level, message: String, date: Date, file: String, line: Int, method: String) {
///         // Customize the interceptor behavior
///         print("Interceptor: \(level) - \(message)")
///         // You can perform additional actions based on the log information
///         // For example, you might want to log to a specific file or send logs to a server.
///     }
/// }
/// ```
/// After defining your custom interceptor, you add it to the Logger using the apply function.
/// Once added, every time you call Logger.log, your custom interceptor's intercept method will be invoked along with any other interceptors that might be added.
/// ```swift
/// // Add the custom interceptor to the Logger
/// Logger.apply(interceptor: MyCustomInterceptor())
///
/// // Now, when you log using the Logger, your interceptor will be invoked
/// Logger.log(.info, msg: "This log will be intercepted by MyCustomInterceptor.")
/// ```
public protocol Interceptor {
    /// Intercepts a log as it happens and provides a set of data to interact with to provide a well rounded message or other sort of information
    /// - Parameters:
    ///   - level: the seriousness or context of the log
    ///   - message: the contextual string of information
    ///   - domain: the specific context from where the log came from
    ///   - date: the date/time the log occurred
    ///   - file: the file in which the log was called from
    ///   - line: the line from where the log was called from
    ///   - method: the method where the log was called from
    func intercept(level: Logger.Level, message: String, domain: String, date: Date, file: String, line: Int, method: String)
}
