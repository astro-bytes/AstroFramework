//
//  LoggerTests.swift
//  LoggerFoundationTests
//
//  Created by Porter McGary on 1/18/24.
//

import XCTest
@testable import LoggerFoundation

final class LoggerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Logger.reset()
        // Start from a known list rather than from "however many the build configuration seeded."
        // Asserting on a total that includes the DEBUG-only interceptor made these tests fail in a
        // release configuration.
        Logger.removeAllInterceptors()
    }

    override func tearDown() {
        Logger.reset()
        super.tearDown()
    }

    // MARK: Registration

    func testApplyInterceptor() {
        let mock = MockInterceptor()

        Logger.apply(interceptor: mock)

        XCTAssertEqual(Logger.interceptorCount, 1)
    }

    func testApplyMultipleInterceptors() {
        Logger.apply(interceptors: [MockInterceptor(), MockInterceptor()])

        XCTAssertEqual(Logger.interceptorCount, 2)
    }

    func testApplyingTheSameInterceptorTwiceRegistersItTwice() {
        let mock = MockInterceptor()

        Logger.apply(interceptors: [mock, mock])

        XCTAssertEqual(Logger.interceptorCount, 2)
    }

    func testRemoveStopsDelivery() {
        let mock = MockInterceptor()
        let token = Logger.apply(interceptor: mock)

        Logger.remove(token)
        Logger.log(.info, msg: "after removal")
        Logger.drain()

        XCTAssertEqual(Logger.interceptorCount, 0)
        XCTAssertFalse(mock.interceptIsCalled)
    }

    func testRemoveOnlyAffectsItsOwnRegistration() {
        let kept = MockInterceptor()
        let dropped = MockInterceptor()
        Logger.apply(interceptor: kept)
        let token = Logger.apply(interceptor: dropped)

        Logger.remove(token)
        Logger.log(.info, msg: "hello")
        Logger.drain()

        XCTAssertEqual(kept.messages, ["hello"])
        XCTAssertFalse(dropped.interceptIsCalled)
    }

    func testRemovingAnUnknownTokenIsIgnored() {
        Logger.apply(interceptor: MockInterceptor())

        Logger.remove(InterceptorToken())

        XCTAssertEqual(Logger.interceptorCount, 1)
    }

    func testResetRestoresTheDefaultInterceptors() {
        Logger.apply(interceptor: MockInterceptor())

        Logger.reset()

        #if DEBUG
        XCTAssertEqual(Logger.interceptorCount, 1, "DEBUG seeds the OSLog interceptor")
        #else
        XCTAssertEqual(Logger.interceptorCount, 0)
        #endif
    }

    // MARK: Delivery

    func testEveryFieldReachesTheInterceptor() throws {
        let mock = MockInterceptor()
        Logger.apply(interceptor: mock)

        let error = NSError(domain: "example", code: 1)
        let date = Date.now

        Logger.log(
            .info, msg: "Test", error: error, data: ["example": "data"], domain: "The Domain",
            date: date, file: "File Name", line: 1, method: "Crazy Horse"
        )
        Logger.drain()

        let entry = try XCTUnwrap(mock.last)
        XCTAssertEqual(entry.level, .info)
        XCTAssertEqual(entry.message, "Test")
        XCTAssertEqual(entry.error as? NSError, error)
        XCTAssertEqual(entry.data, ["example": "data"])
        XCTAssertEqual(entry.domain, "The Domain")
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.file, "File Name")
        XCTAssertEqual(entry.line, 1)
        XCTAssertEqual(entry.method, "Crazy Horse")
    }

    func testEveryInterceptorReceivesEveryLog() {
        let first = MockInterceptor()
        let second = MockInterceptor()
        Logger.apply(interceptors: [first, second])

        Logger.log(.info, msg: "shared")
        Logger.drain()

        XCTAssertEqual(first.messages, ["shared"])
        XCTAssertEqual(second.messages, ["shared"])
    }

    func testSourceLocationDefaultsToTheCallSite() throws {
        let mock = MockInterceptor()
        Logger.apply(interceptor: mock)

        Logger.log(.debug, msg: "located")
        Logger.drain()

        let entry = try XCTUnwrap(mock.last)
        // `#fileID` is module-relative. `#file` used to embed the absolute path of the machine
        // that compiled the binary.
        XCTAssertEqual(entry.file, "LoggerFoundationTests/LoggerTests.swift")
        XCTAssertFalse(entry.file.hasPrefix("/"))
        XCTAssertEqual(entry.method, "testSourceLocationDefaultsToTheCallSite()")
    }

    /// Logs arrive in the order they were recorded.
    ///
    /// Each log used to be dispatched in its own detached task, which left the ordering entirely
    /// to the scheduler.
    func testLogsArriveInTheOrderTheyWereRecorded() {
        let mock = MockInterceptor()
        Logger.apply(interceptor: mock)

        let expected = (0..<200).map(String.init)
        for message in expected {
            Logger.log(.info, msg: message)
        }
        Logger.drain()

        XCTAssertEqual(mock.messages, expected)
    }

    /// Logging and registering from many threads at once must not corrupt the interceptor list.
    ///
    /// The list used to be an unsynchronised array, appended to on the caller's thread while a
    /// detached task iterated it.
    func testConcurrentLoggingAndRegistrationIsSafe() {
        let mock = MockInterceptor()
        Logger.apply(interceptor: mock)

        DispatchQueue.concurrentPerform(iterations: 200) { iteration in
            if iteration.isMultiple(of: 10) {
                Logger.remove(Logger.apply(interceptor: MockInterceptor()))
            }
            Logger.log(.info, msg: "\(iteration)")
        }
        Logger.drain()

        XCTAssertEqual(mock.entries.count, 200)
        XCTAssertEqual(Logger.interceptorCount, 1)
    }

    // MARK: Filtering

    func testLogsBelowTheMinimumLevelAreDropped() {
        let mock = MockInterceptor()
        Logger.apply(interceptor: mock)
        Logger.minimumLevel = .warning

        Logger.log(.debug, msg: "debug")
        Logger.log(.info, msg: "info")
        Logger.log(.warning, msg: "warning")
        Logger.log(.critical, msg: "critical")
        Logger.drain()

        XCTAssertEqual(mock.messages, ["warning", "critical"])
    }

    func testTheDefaultMinimumLevelDeliversEverything() {
        let mock = MockInterceptor()
        Logger.apply(interceptor: mock)

        Logger.log(.debug, msg: "debug")
        Logger.log(.info, msg: "info")
        Logger.log(.warning, msg: "warning")
        Logger.log(.critical, msg: "critical")
        Logger.drain()

        XCTAssertEqual(mock.messages, ["debug", "info", "warning", "critical"])
    }

    func testACustomLevelFiltersByItsPriority() {
        let mock = MockInterceptor()
        Logger.apply(interceptor: mock)
        // Sits between info and warning.
        let notice = Logger.Level(name: "notice", priority: 2, osType: .default)
        Logger.minimumLevel = notice

        Logger.log(.info, msg: "info")
        Logger.log(notice, msg: "notice")
        Logger.drain()

        XCTAssertEqual(mock.messages, ["notice"])
    }

    func testLevelsAreOrderedByPriority() {
        XCTAssertLessThan(Logger.Level.debug, .info)
        XCTAssertLessThan(Logger.Level.info, .warning)
        XCTAssertLessThan(Logger.Level.warning, .critical)
    }

    func testResetRestoresTheDefaultMinimumLevel() {
        Logger.minimumLevel = .critical

        Logger.reset()

        XCTAssertEqual(Logger.minimumLevel, .debug)
    }
}
