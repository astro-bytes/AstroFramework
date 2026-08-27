//
//  MockInterceptor.swift
//  LoggerFoundationTests
//
//  Created by Porter McGary on 1/18/24.
//

import Foundation
import LoggerFoundation

/// Records every log it is handed, in order.
///
/// Locked because interceptors are `Sendable`: the logger delivers on its own serial queue, so
/// the recording and the test's reading of it happen on different threads.
final class MockInterceptor: Interceptor, @unchecked Sendable {

    struct Entry {
        let level: Logger.Level
        let message: String
        let error: (any Error)?
        let data: [String: String]?
        let domain: String
        let date: Date
        let file: String
        let line: Int
        let method: String
    }

    private let lock = NSLock()
    private var _entries: [Entry] = []

    var entries: [Entry] {
        lock.lock()
        defer { lock.unlock() }
        return _entries
    }

    var interceptIsCalled: Bool { !entries.isEmpty }
    var last: Entry? { entries.last }
    var messages: [String] { entries.map(\.message) }

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
        let entry = Entry(
            level: level, message: message, error: error, data: data,
            domain: domain, date: date, file: file, line: line, method: method
        )

        lock.lock()
        _entries.append(entry)
        lock.unlock()
    }
}
