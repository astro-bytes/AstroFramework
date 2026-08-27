//
//  OSLogInterceptor.swift
//  LoggerFoundation
//
//  Created by Porter McGary on 1/18/24.
//

import Foundation
import os

/// Writes logs to the unified logging system, where Console and `log stream` can see them.
///
/// Fields are interpolated individually rather than being flattened into one string first. The old
/// `os_log("%s", …)` form made the entire line one dynamic argument, which cost the structure
/// Console groups by and, more importantly, the ability to say which parts are safe to record.
struct OSLogInterceptor: Interceptor {

    /// `os.Logger` values are cheap but not free, and one log line asks for the same one every
    /// time. Reachable only from the logger's serial queue, but locked anyway so that stays an
    /// implementation detail rather than a requirement.
    private let cache = LoggerCache()

    func intercept(
        level: Logger.Level,
        message: String,
        error: (any Error)?,
        data: [String: String]?,
        domain: String,
        date: Date,
        file: String,
        line: Int,
        method: String
    ) {
        let logger = cache.logger(subsystem: domain, category: level.name)

        // Source location and the developer-authored message are safe to record. The error and the
        // data dictionary carry runtime values — a URL with a token in it, an identifier, whatever
        // the caller had to hand — so they are redacted in a release build and readable while
        // debugging.
        let errorDescription = error.map { String(describing: $0) } ?? ""
        let dataDescription = data.map { String(describing: $0) } ?? ""

        logger.log(level: level.osType, """
            [\(file, privacy: .public):\(line, privacy: .public) \(method, privacy: .public)] \
            \(message, privacy: .public)\
            \(errorDescription.isEmpty ? "" : " - ", privacy: .public)\(errorDescription, privacy: .private)\
            \(dataDescription.isEmpty ? "" : " ", privacy: .public)\(dataDescription, privacy: .private)
            """)
    }
}

/// A locked cache of `os.Logger` values, keyed by the subsystem and category they were built for.
final class LoggerCache: @unchecked Sendable {
    private let lock = NSLock()
    private var loggers: [String: os.Logger] = [:]

    /// How many distinct loggers are held. `os.Logger` is not identity-comparable, so this is how
    /// reuse is observable at all.
    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return loggers.count
    }

    func logger(subsystem: String, category: String) -> os.Logger {
        let key = "\(subsystem)|\(category)"

        lock.lock()
        defer { lock.unlock() }

        if let existing = loggers[key] { return existing }
        let created = os.Logger(subsystem: subsystem, category: category)
        loggers[key] = created
        return created
    }
}
