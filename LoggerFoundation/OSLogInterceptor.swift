//
//  OSLogInterceptor.swift
//  Logger
//
//  Created by Porter McGary on 1/18/24.
//

import Foundation
import os

/// Logs to the Console in a very OS friendly way
struct OSLogInterceptor: Interceptor {
    func intercept(level: Logger.Level, message: String, error: Error?, data: [String: String]?, domain: String,
                   date: Date, file: String, line: Int, method: String) {
        let log = OSLog(subsystem: domain, category: level.name)
        let errorDescription = error != nil ? " - \(String(describing: error!))" : ""
        let dataDescription = data != nil ? " `\(String(describing: data!))`" : ""
        let msg = "\(date.formatted(date: .numeric, time: .complete)) [\(file):\(method):\(line)] \(message)\(errorDescription)\(dataDescription)"
        os_log("%s", log: log, type: level.osType, msg)
    }
}

fileprivate extension Logger.Level {
    var osType: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .fault
        case .critical:
            return .error
        }
    }
    
    var name: String {
        String(describing: self)
    }
}
