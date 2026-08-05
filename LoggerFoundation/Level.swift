//
//  Level.swift
//  Logger
//
//  Created by Porter McGary on 1/18/24.
//

import Foundation
import OSLog

/// Blueprint for defining log levels and their associated metadata.
///
/// Types conforming to `LogLevel` can be passed directly to `Logger.log(_:...)`.
/// You can extend `Logger.Level` with static properties or create custom conforming types to define domain-specific log levels.
public protocol LogLevel {
    /// The string representation of the log level (e.g., "info", "debug", "custom").
    var name: String { get }
    
    /// The priority level used to determine log severity or filter threshold.
    /// Higher values indicate greater severity.
    var priority: Int { get }
    
    /// The corresponding system `OSLogType` used when sending logs to `OSLogInterceptor`.
    var osType: OSLogType { get }
}

extension Logger {
    /// Identifies the different levels and importance of logs
    public enum Level: Int, LogLevel {
        /// Used to indicate the log is general debugging purposes
        case debug = 0
        /// Used to inform of a specific state or functionality occurring
        case info
        /// Used to indicate there is a potential problem that can take casual action to be avoided
        case warning
        /// Used to indicate there is a problem that needs immediate or quick action to correct
        case critical
        
        public var name: String {
            String(describing: self)
        }
        
        public var priority: Int {
            self.rawValue
        }
        
        public var osType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .error
            case .critical:
                return .fault
            }
        }
    }
}
