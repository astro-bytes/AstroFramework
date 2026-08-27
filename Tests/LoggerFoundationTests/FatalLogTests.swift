//
//  FatalLogTests.swift
//  LoggerFoundationTests
//
//  Created by Porter McGary on 8/27/26.
//

import XCTest
@testable import LoggerFoundation

/// A fatal ends the process, so the terminating call itself cannot be tested — it would take the
/// runner with it. What *can* be tested is everything it does first, which is the part that
/// matters: `recordFatal` is split out for exactly that.
final class FatalLogTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Logger.reset()
        Logger.removeAllInterceptors()
    }

    override func tearDown() {
        Logger.reset()
        super.tearDown()
    }

    private func recordFatal(message: String = "unrecoverable", domain: String = "Test") {
        Logger.shared.recordFatal(
            message: message, error: nil, data: nil, domain: domain,
            date: .now, file: #fileID, line: #line, method: #function
        )
    }

    // MARK: The guarantee that matters

    /// Everything logged before the fatal is delivered before it.
    ///
    /// An ordinary log is handed to a queue and returns. A fatal that crashed immediately would
    /// take the whole trail with it — and the trail is the only thing that explains the crash.
    func testEverythingQueuedBeforeTheFatalIsDeliveredFirst() {
        let mock = MockInterceptor()
        Logger.apply(interceptor: mock)

        for index in 0 ..< 100 {
            Logger.log(.info, msg: "\(index)")
        }
        recordFatal(message: "the end")

        XCTAssertEqual(mock.messages, (0 ..< 100).map(String.init) + ["the end"])
    }

    /// The delivery is synchronous: by the time the call returns, every interceptor has seen it.
    /// That is what makes it safe to call `fatalError` on the next line.
    func testTheFatalIsDeliveredBeforeTheCallReturns() {
        let mock = MockInterceptor()
        Logger.apply(interceptor: SlowInterceptor(delay: 0.2))
        Logger.apply(interceptor: mock)

        Logger.log(.info, msg: "queued ahead")
        recordFatal(message: "the end")

        // No drain, no waiting — if delivery were asynchronous this would be empty.
        XCTAssertEqual(mock.messages, ["queued ahead", "the end"])
    }

    func testTheFatalReachesEveryInterceptorNotJustTheFirst() {
        let first = MockInterceptor()
        let second = MockInterceptor()
        let third = MockInterceptor()
        Logger.apply(interceptors: [first, second, third])

        recordFatal(message: "the end")

        for mock in [first, second, third] {
            XCTAssertEqual(mock.messages, ["the end"])
        }
    }

    /// A process about to die owes an explanation whatever the build was configured to keep.
    func testAFatalIgnoresTheMinimumLevel() {
        let mock = MockInterceptor()
        Logger.apply(interceptor: mock)
        Logger.minimumLevel = Logger.Level(name: "silent", priority: .max, osType: .fault)

        Logger.log(.critical, msg: "filtered out")
        recordFatal(message: "still recorded")

        XCTAssertEqual(mock.messages, ["still recorded"])
    }

    func testAFatalIsRecordedAtTheFatalLevel() throws {
        let mock = MockInterceptor()
        Logger.apply(interceptor: mock)

        recordFatal()

        let entry = try XCTUnwrap(mock.last)
        XCTAssertEqual(entry.level, Logger.Fatal.level)
        XCTAssertEqual(entry.level.name, "fatal")
    }

    func testEveryFieldReachesTheInterceptor() throws {
        let mock = MockInterceptor()
        Logger.apply(interceptor: mock)
        let error = NSError(domain: "example", code: 7)
        let date = Date.now

        Logger.shared.recordFatal(
            message: "Boom", error: error, data: ["reason": "disk"], domain: "Database",
            date: date, file: "File.swift", line: 42, method: "load()"
        )

        let entry = try XCTUnwrap(mock.last)
        XCTAssertEqual(entry.message, "Boom")
        XCTAssertEqual(entry.error as? NSError, error)
        XCTAssertEqual(entry.data, ["reason": "disk"])
        XCTAssertEqual(entry.domain, "Database")
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.file, "File.swift")
        XCTAssertEqual(entry.line, 42)
        XCTAssertEqual(entry.method, "load()")
    }

    /// An interceptor that logs a fatal is already on the delivery queue. Blocking on it would
    /// deadlock, so the loop runs inline instead — everything ahead of it has already run by
    /// definition.
    func testAFatalRaisedFromInsideAnInterceptorDoesNotDeadlock() {
        let mock = MockInterceptor()
        Logger.apply(interceptor: ReentrantInterceptor())
        Logger.apply(interceptor: mock)

        Logger.log(.info, msg: "triggers a fatal")

        let finished = expectation(description: "delivery completed without deadlocking")
        DispatchQueue.global().async {
            Logger.drain()
            finished.fulfill()
        }
        wait(for: [finished], timeout: 5)

        XCTAssertTrue(mock.messages.contains("triggers a fatal"))
    }

    // MARK: The level

    func testTheFatalLevelOutranksCritical() {
        XCTAssertGreaterThan(Logger.Fatal.level.priority, Logger.Level.critical.priority)
        XCTAssertGreaterThan(Logger.Fatal.level, .critical)
    }

    /// Lets an interceptor treat a fatal differently without hard-coding a name.
    func testIsTerminatingDistinguishesFatalFromEveryOtherLevel() {
        XCTAssertTrue(Logger.Fatal.level.isTerminating)

        for level in [Logger.Level.debug, .info, .warning, .critical] {
            XCTAssertFalse(level.isTerminating, "\(level.name) should not be terminating")
        }
    }

    func testTheFatalLevelUsesTheFaultOSType() {
        XCTAssertEqual(Logger.Fatal.level.osType, .fault)
    }
}

// MARK: - Stubs

/// Holds up delivery so a test can tell a synchronous fatal from an asynchronous one.
private struct SlowInterceptor: Interceptor {
    let delay: TimeInterval

    func intercept(
        level: Logger.Level, message: String, error: (any Error)?, data: [String: String]?,
        domain: String, date: Date, file: String, line: Int, method: String
    ) {
        Thread.sleep(forTimeInterval: delay)
    }
}

/// Records a fatal from inside the delivery loop, which is where a deadlock would show up.
private struct ReentrantInterceptor: Interceptor {
    func intercept(
        level: Logger.Level, message: String, error: (any Error)?, data: [String: String]?,
        domain: String, date: Date, file: String, line: Int, method: String
    ) {
        guard !level.isTerminating else { return }

        Logger.shared.recordFatal(
            message: "from inside an interceptor", error: nil, data: nil, domain: "Test",
            date: .now, file: #fileID, line: #line, method: #function
        )
    }
}

// MARK: - Compile-time contract

/// These are never called. Their existence is the assertion: each one compiles only because
/// `Logger.log(.fatal, …)` returns `Never`, which is the whole reason `Fatal` is a type rather
/// than another `Logger.Level`.
private enum FatalReturnsNever {

    /// The shape most fatals actually take — a function that must produce a value and cannot.
    static func asTheWholeBodyOfAGuardElse(_ candidate: Int?) -> Int {
        guard let candidate else {
            Logger.log(.fatal, msg: "no value", domain: "Test")
        }
        return candidate
    }

    /// No `return` after it, because control flow provably ends there.
    static func asTheLastStatementOfAThrowingFunction() throws -> String {
        Logger.log(.fatal, msg: "unreachable state", domain: "Test")
    }

    /// In a switch arm, without needing a `return` to satisfy exhaustiveness.
    static func inASwitchArm(_ flag: Bool) -> Int {
        switch flag {
        case true: 1
        case false: Logger.log(.fatal, msg: "impossible", domain: "Test")
        }
    }

    /// `.fatal` resolves to exactly one overload. Were the level also `Logger.Level.fatal`, this
    /// would be ambiguous — and the wrong resolution would silently fail to terminate.
    static func resolvesUnambiguously() -> Never {
        Logger.log(.fatal, msg: "unambiguous", domain: "Test")
    }
}
