//
//  OSLogInterceptorTests.swift
//  LoggerFoundationTests
//
//  Created by Porter McGary on 8/27/26.
//

import XCTest
import os
@testable import LoggerFoundation

/// The default interceptor is the one every DEBUG build actually uses, and the one the other
/// logger tests unregister in order to assert on their own. Nothing exercised it.
///
/// What can be asserted from outside the unified logging system is that every shape of log reaches
/// it without trapping, and that its logger cache hands back the same instance for the same
/// subsystem and category rather than rebuilding one per line.
final class OSLogInterceptorTests: XCTestCase {

    private let interceptor = OSLogInterceptor()

    private func intercept(
        level: LoggerFoundation.Logger.Level = .info,
        message: String = "message",
        error: (any Error)? = nil,
        data: [String: String]? = nil,
        domain: String = "AstroFrameworkTests"
    ) {
        interceptor.intercept(
            level: level, message: message, error: error, data: data, domain: domain,
            date: .now, file: #fileID, line: #line, method: #function
        )
    }

    // MARK: Every shape of log

    func testAPlainMessage() {
        XCTAssertNoThrow(intercept())
    }

    func testAnEmptyMessage() {
        XCTAssertNoThrow(intercept(message: ""))
    }

    func testAMessageWithAnError() {
        XCTAssertNoThrow(intercept(error: CoreFailure()))
    }

    func testAMessageWithData() {
        XCTAssertNoThrow(intercept(data: ["key": "value"]))
    }

    func testAMessageWithBothAnErrorAndData() {
        XCTAssertNoThrow(intercept(error: CoreFailure(), data: ["key": "value"]))
    }

    func testEmptyData() {
        XCTAssertNoThrow(intercept(data: [:]))
    }

    /// A log's interpolation includes the message verbatim; a message that looks like a format
    /// specifier must not be treated as one.
    func testAMessageContainingFormatSpecifiers() {
        XCTAssertNoThrow(intercept(message: "100%% done %@ %d %s"))
    }

    func testEveryBuiltInLevel() {
        for level in [LoggerFoundation.Logger.Level.debug, .info, .warning, .critical] {
            XCTAssertNoThrow(intercept(level: level, message: level.name))
        }
    }

    func testACustomLevel() {
        let notice = LoggerFoundation.Logger.Level(name: "notice", priority: 2, osType: .default)

        XCTAssertNoThrow(intercept(level: notice))
    }

    // MARK: The logger cache

    func testTheCacheReusesALoggerForTheSameSubsystemAndCategory() {
        let cache = LoggerCache()

        for _ in 0 ..< 10 {
            _ = cache.logger(subsystem: "sub", category: "cat")
        }

        XCTAssertEqual(cache.count, 1, "a logger was rebuilt per call")
    }

    func testTheCacheKeepsOneLoggerPerSubsystemAndCategoryPair() {
        let cache = LoggerCache()

        _ = cache.logger(subsystem: "sub", category: "one")
        _ = cache.logger(subsystem: "sub", category: "two")
        _ = cache.logger(subsystem: "other", category: "one")

        XCTAssertEqual(cache.count, 3)
    }

    /// The key joins the two halves with a separator, so a pair that would collide once
    /// concatenated still gets its own logger.
    func testTheCacheKeysOnBothSubsystemAndCategory() {
        let cache = LoggerCache()

        _ = cache.logger(subsystem: "a", category: "bc")
        _ = cache.logger(subsystem: "ab", category: "c")

        XCTAssertEqual(cache.count, 2)
    }

    func testTheCacheIsSafeUnderConcurrentAccess() {
        let cache = LoggerCache()

        DispatchQueue.concurrentPerform(iterations: 500) { iteration in
            _ = cache.logger(subsystem: "sub", category: "cat-\(iteration % 5)")
        }

        XCTAssertEqual(cache.count, 5, "concurrent lookups built duplicate loggers")
    }

    // MARK: Registered by default

    /// A DEBUG build seeds this interceptor, which is what makes logs show up in Console without
    /// an app configuring anything.
    func testItIsRegisteredByDefaultInDebugBuilds() {
        LoggerFoundation.Logger.reset()
        defer { LoggerFoundation.Logger.reset() }

        #if DEBUG
        XCTAssertEqual(LoggerFoundation.Logger.interceptorCount, 1)
        #else
        XCTAssertEqual(LoggerFoundation.Logger.interceptorCount, 0)
        #endif
    }

    /// The whole path, through the real logger rather than by calling `intercept` directly.
    func testLoggingThroughTheDefaultInterceptorDoesNotTrap() {
        LoggerFoundation.Logger.reset()
        defer { LoggerFoundation.Logger.reset() }

        LoggerFoundation.Logger.log(.warning, msg: "through the front door", error: CoreFailure(), data: ["a": "b"])

        XCTAssertNoThrow(LoggerFoundation.Logger.drain())
    }
}

private struct CoreFailure: Error {}
