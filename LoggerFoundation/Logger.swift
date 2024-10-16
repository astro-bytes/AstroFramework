//
//  Logger.swift
//  Logger
//
//  Created by Porter McGary on 1/18/24.
//

import Foundation

/// Integrated Logging Component with various logging functions.
/// To use one of the public log functions, you can follow the structure provided in the code.
///
/// Here's an example of how you might use the log function with a message:
/// ```swift
/// Logger.log(.info, msg: "This is an informational log message.")
/// ```
/// In this example, the log level is set to `.info`, and the log message is `"This is an informational log message."`
/// You can replace the log level and message with your specific requirements.
///
/// If you want to log an error, you can use the log function with an Error parameter:
/// ```swift
/// let someError = MyCustomError(description: "An error occurred.")
/// Logger.log(.error, error: someError)
/// ```
/// Replace `MyCustomError` with the actual type of your error, and customize the error description accordingly.
///
/// ## Interceptor
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
public class Logger {
    
    /// Singleton pattern shared instance
    static var shared: Logger = .init()
    
    /// Applies an additional interceptor to the logging component
    /// - Parameter interceptor: the single interceptor who intercepts logs
    public static func apply(interceptor: Interceptor) {
        shared.interceptors.append(interceptor)
    }
    
    /// Applies additional interceptors to the logging component
    /// - Parameter interceptors: the set of interceptors who intercepts logs
    public static func apply(interceptors: [Interceptor]) {
        shared.interceptors.append(contentsOf: interceptors)
    }
    
    /// Base internal logging
    /// - Parameters:
    ///   - level: the status or importance of the log
    ///   - msg: the content of the log or information to be passed
    ///   - error: the error
    ///   - data: additional data to pass along
    ///   - domain: the specific context from where the log came from, defaults to `Core`
    public static func log(_ level: Logger.Level,
                           msg message: String,
                           error: Error? = nil,
                           data: [String: String]? = nil,
                           domain: String = "Core",
                           date: Date = .now,
                           file: String = #file,
                           line: Int = #line,
                           method: String = #function) {
        logBase(level, msg: message, error: error, data: data, domain: domain,
                date: date, file: file, line: line, method: method)
    }
    
    /// Base internal logging
    /// - Parameters:
    ///   - level: the status or importance of the log
    ///   - msg: the content of the log or information to be passed
    ///   - domain: the specific context from where the log came from
    ///   - date: the date/time the log occurred
    ///   - file: the file in which the log was called from
    ///   - line: the line from where the log was called from
    ///   - method: the method where the log was called from
    static func logBase(_ level: Logger.Level,
                        msg message: String,
                        error: Error?,
                        data: [String: String]?,
                        domain: String,
                        date: Date,
                        file: String,
                        line: Int,
                        method: String) {
        // TODO: Decide is it better to use a loop like so on a background thread or better to use a publisher?
        Task.detached(priority: .background) {
            for interceptor in shared.interceptors {
                interceptor.intercept(level: level, message: message, error: error, data: data, domain: domain,
                                      date: date, file: file, line: line, method: method)
            }
        }
    }
    
    /// Interceptors that are allowed to intercept a log and provide some functionality on the intercept
    var interceptors: [Interceptor]
    
    /// Creates a Logger
    /// When the Build Environment is DEBUG the OSLogInterceptor is Automatically added to the list of interceptors
    /// When the Build Environment is anything other than DEBUG the interceptors list starts empty
    init() {
        #if DEBUG
        self.interceptors = [OSLogInterceptor()]
        #else
        self.interceptors = []
        #endif
    }
}
