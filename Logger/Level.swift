//
//  Level.swift
//  Logger
//
//  Created by Porter McGary on 1/18/24.
//

import Foundation

extension Logger {
    /// Identifies the different levels and importance of logs
    public enum Level {
        /// Used to indicate the log is general debugging purposes
        case debug
        /// Used to inform of a specific state or functionality occurring
        case info
        /// Used to indicate there is a potential problem that can take casual action to be avoided
        case warning
        /// Used to indicate there is a problem that needs immediate or quick action to correct
        case critical
    }
}
