//
//  Level.swift
//  Logger
//
//  Created by Porter McGary on 1/18/24.
//

import Foundation
import OSLog

extension Logger {
    /// Blueprint for defining log levels and their associated metadata.
    ///
    /// Types conforming to `LogLevel` can be passed directly to `Logger.log(_:...)`.
    /// You can extend `Logger.Level` with static properties or create custom conforming types to define domain-specific log levels.
    public struct Level: Equatable, Hashable {
        /// The string representation of the log level (e.g., "info", "debug", "custom").
        public let name: String
        
        /// The priority level used to determine log severity or filter threshold.
        /// Higher values indicate greater severity.
        public let priority: Int
        
        /// The corresponding system `OSLogType` used when sending logs to `OSLogInterceptor`.
        public let osType: OSLogType
        
        /// Creates a new log level definition.
        ///
        /// - Parameters:
        ///   - name: The unique string identifier for the log level (for example, `"debug"` or `"info"`).
        ///   - priority: The severity of the log level. Higher values represent more severe log messages.
        ///   - osType: The corresponding `OSLogType` used when forwarding log entries to Apple's unified logging system.
        public init(name: String, priority: Int, osType: OSLogType) {
            self.name = name
            self.priority = priority
            self.osType = osType
        }
    }
}

public extension Logger.Level {
    /// Used to indicate the log is general debugging purposes
    static let debug = Self(name: "debug", priority: 0, osType: .debug)
    
    /// Used to inform of a specific state or functionality occurring
    static let info = Self(name: "info", priority: 1, osType: .info)
    
    /// Used to indicate there is a potential problem that can take casual action to be avoided
    static let warning = Self(name: "warning", priority: 2, osType: .error)
    
    /// Used to indicate there is a problem that needs immediate or quick action to correct
    static let critical = Self(name: "critical", priority: 3, osType: .fault)
}
