//
//  Logger.swift
//  LoggerFoundation
//
//  Created by Porter McGary on 1/18/24.
//

import Foundation
import Synchronization

/// Integrated logging component.
///
/// ```swift
/// Logger.log(.info, msg: "Signed in.")
/// Logger.log(.warning, error: error, data: ["endpoint": url.absoluteString])
/// ```
///
/// ## Interceptors
///
/// Every log is handed to each registered ``Interceptor`` in turn, on a private serial queue, in
/// the order the calls were made. In a `DEBUG` build an interceptor writing to the unified logging
/// system is registered for you; in any other build the list starts empty, so an app decides for
/// itself where its logs go.
///
/// ```swift
/// let token = Logger.apply(interceptor: MyCustomInterceptor())
/// Logger.remove(token)   // when it should stop receiving them
/// ```
///
/// ## Filtering
///
/// ``minimumLevel`` drops anything less severe before it reaches an interceptor, so a noisy
/// `.debug` call costs nothing in a build that is not listening for it.
///
/// ```swift
/// Logger.minimumLevel = .warning
/// ```
public final class Logger {

    /// Singleton pattern shared instance.
    static let shared = Logger()

    // MARK: Configuration

    /// The least severe level that will be delivered. Defaults to ``Level/debug``, which delivers
    /// everything.
    ///
    /// Filtering happens before any interceptor is consulted, and before the log is dispatched, so
    /// a call below the threshold costs an integer comparison.
    public static var minimumLevel: Level {
        get { shared.state.withLock { $0.minimumLevel } }
        set { shared.state.withLock { $0.minimumLevel = newValue } }
    }

    // MARK: Interceptors

    /// Registers an interceptor.
    /// - Parameter interceptor: The interceptor to receive subsequent logs.
    /// - Returns: A token identifying the registration, for handing to ``remove(_:)``.
    @discardableResult
    public static func apply(interceptor: any Interceptor) -> InterceptorToken {
        let token = InterceptorToken()
        shared.state.withLock { $0.interceptors.append((token, interceptor)) }
        return token
    }

    /// Registers several interceptors at once.
    /// - Parameter interceptors: The interceptors to receive subsequent logs.
    /// - Returns: One token per interceptor, in the order given.
    @discardableResult
    public static func apply(interceptors: [any Interceptor]) -> [InterceptorToken] {
        let registrations = interceptors.map { (InterceptorToken(), $0) }
        shared.state.withLock { $0.interceptors.append(contentsOf: registrations) }
        return registrations.map(\.0)
    }

    /// Stops the interceptor registered under `token` from receiving further logs.
    ///
    /// A token that is not registered — already removed, or from a previous ``reset()`` — is
    /// ignored.
    public static func remove(_ token: InterceptorToken) {
        shared.state.withLock { $0.interceptors.removeAll { $0.token == token } }
    }

    /// Removes every interceptor, including the one registered automatically in `DEBUG` builds.
    public static func removeAllInterceptors() {
        shared.state.withLock { $0.interceptors.removeAll() }
    }

    /// Returns the logger to the state it starts a process in: default interceptors, default
    /// threshold.
    ///
    /// Intended for tests, which otherwise leak registrations into each other.
    public static func reset() {
        shared.state.withLock {
            $0.interceptors = Logger.defaultInterceptors()
            $0.minimumLevel = .debug
        }
    }

    /// How many interceptors are currently registered.
    static var interceptorCount: Int {
        shared.state.withLock { $0.interceptors.count }
    }

    // MARK: Logging

    /// Records a log.
    /// - Parameters:
    ///   - level: The status or importance of the log.
    ///   - message: The content of the log, or information to be passed along.
    ///   - error: The error being reported, if there is one.
    ///   - data: Additional context to pass along.
    ///   - domain: The specific context the log came from. Defaults to `Core`.
    ///   - date: When the log occurred. Defaults to now.
    ///   - file: The file the log was called from. Defaults to the caller's.
    ///   - line: The line the log was called from. Defaults to the caller's.
    ///   - method: The method the log was called from. Defaults to the caller's.
    public static func log(
        _ level: Level,
        msg message: String = "",
        error: (any Error)? = nil,
        data: [String: String]? = nil,
        domain: String = "Core",
        date: Date = .now,
        // `#fileID` rather than `#file`: the latter embeds the absolute path of the machine that
        // compiled the binary, which is both noise in the log and a small information leak.
        file: String = #fileID,
        line: Int = #line,
        method: String = #function
    ) {
        shared.deliver(
            level: level, message: message, error: error, data: data,
            domain: domain, date: date, file: file, line: line, method: method
        )
    }

    // MARK: Internals

    /// Everything guarded by ``state``.
    private struct State {
        var interceptors: [(token: InterceptorToken, interceptor: any Interceptor)]
        var minimumLevel: Level
    }

    /// `Mutex` rather than a lock sitting beside the data: the state is reachable only through
    /// `withLock`, so it cannot be read without holding the lock. It is also `Sendable` on its
    /// own, which is what lets this class drop `@unchecked`.
    private let state: Mutex<State>

    /// Delivery runs here, so interceptors see logs in the order the calls were made and never
    /// concurrently with each other.
    ///
    /// Previously each log spawned its own detached task, which left ordering to chance and read
    /// the interceptor list without synchronising against registration. An actor would not fix
    /// that either: entering one from separate unstructured tasks has no FIFO guarantee.
    private let queue = DispatchQueue(label: "me.astrobytes.AstroFramework.Logger", qos: .utility)

    /// Marks the delivery queue, so a fatal raised from inside an interceptor can tell it is
    /// already on that queue and run inline instead of deadlocking on `sync`.
    private static let queueKey = DispatchSpecificKey<Bool>()

    private init() {
        state = Mutex(State(interceptors: Logger.defaultInterceptors(), minimumLevel: .debug))
        queue.setSpecific(key: Logger.queueKey, value: true)
    }

    /// Whether the caller is already running on the delivery queue.
    private var isOnDeliveryQueue: Bool {
        DispatchQueue.getSpecific(key: Logger.queueKey) == true
    }

    /// Waits for everything already queued to reach its interceptors.
    ///
    /// On a serial queue an empty `sync` is a barrier: it cannot start until every block enqueued
    /// before it has finished.
    fileprivate func flush() {
        guard !isOnDeliveryQueue else { return }
        queue.sync {}
    }

    /// Delivers a terminating log on the calling thread, after everything already queued.
    ///
    /// Split from ``Logger/log(_:msg:error:data:domain:date:file:line:method:)-(Fatal,_,_,_,_,_,_,_,_)``
    /// so tests can assert the flush and the delivery without ending the test runner.
    func recordFatal(
        message: String,
        error: (any Error)?,
        data: [String: String]?,
        domain: String,
        date: Date,
        file: String,
        line: Int,
        method: String
    ) {
        // A fatal ignores `minimumLevel`. A process that is about to die owes an explanation
        // regardless of how quiet the build was configured to be.
        let recipients = state.withLock { $0.interceptors.map(\.interceptor) }

        let deliver = {
            for interceptor in recipients {
                interceptor.intercept(
                    level: Fatal.level, message: message, error: error, data: data,
                    domain: domain, date: date, file: file, line: line, method: method
                )
            }
        }

        if isOnDeliveryQueue {
            // Reached from inside an interceptor. `sync` here would deadlock on the queue we are
            // already on, and everything ahead of us has by definition already run.
            deliver()
        } else {
            // `sync` on a serial queue runs after every block enqueued before it, so the trail
            // that explains the crash lands ahead of the crash itself — and this call does not
            // return until the fatal has been delivered too.
            queue.sync(execute: deliver)
        }
    }

    /// When the build environment is DEBUG the OSLogInterceptor is automatically registered. In any
    /// other environment the list starts empty.
    private static func defaultInterceptors() -> [(token: InterceptorToken, interceptor: any Interceptor)] {
        #if DEBUG
        [(InterceptorToken(), OSLogInterceptor())]
        #else
        []
        #endif
    }

    private func deliver(
        level: Level,
        message: String,
        error: (any Error)?,
        data: [String: String]?,
        domain: String,
        date: Date,
        file: String,
        line: Int,
        method: String
    ) {
        // Snapshot under the lock, then hand the copy to the queue. Holding the lock across
        // delivery would let an interceptor that logs deadlock the logger.
        let recipients: [any Interceptor] = state.withLock { state in
            guard level >= state.minimumLevel else { return [] }
            return state.interceptors.map(\.interceptor)
        }

        guard !recipients.isEmpty else { return }

        queue.async {
            for interceptor in recipients {
                interceptor.intercept(
                    level: level, message: message, error: error, data: data, domain: domain,
                    date: date, file: file, line: line, method: method
                )
            }
        }
    }
}

// MARK: - Terminating logs

public extension Logger {
    /// The severity that ends the process, as a type of its own.
    ///
    /// ## Why this is a type and not another ``Logger/Level``
    ///
    /// So the overload below can return `Never`. Swift picks a return type from the *type* of an
    /// argument, never from its value, so one `log(_ level: Level, …) -> Void` cannot return
    /// `Never` for one particular level. Without `Never` a fatal could not be the whole body of a
    /// `guard … else`, which is where most of them live — a dependency that will not resolve, a
    /// database that will not open, a configuration file that is not there.
    ///
    /// It also means `.fatal` resolves to exactly one overload, so there is no way to write
    /// `Logger.log(.fatal, …)` and get the ordinary asynchronous, non-terminating path by
    /// accident.
    struct Fatal: Sendable {
        /// The single value, so `.fatal` resolves to the terminating overload.
        public static let fatal = Fatal()

        /// What is actually recorded: one priority above ``Logger/Level/critical``, so it clears
        /// every threshold a critical clears.
        ///
        /// Deliberately not `Level.fatal`: a static of that name on `Level` would make
        /// `Logger.log(.fatal, …)` ambiguous between the two overloads, and the wrong resolution
        /// would silently fail to terminate.
        public static let level = Level(
            name: "fatal",
            priority: Level.critical.priority + 1,
            osType: .fault
        )

        public init() {}
    }

    /// Records an unrecoverable failure, then ends the process.
    ///
    /// Use it wherever the code would otherwise call `fatalError()`: an unregistered dependency, a
    /// database that will not open, a missing configuration. The app is over at that point, so the
    /// only question left is whether the reason survives.
    ///
    /// ```swift
    /// guard let url = try? RawDatabaseManager.url(for: .database) else {
    ///     Logger.log(.fatal, msg: "Database path failed", domain: "Database")
    /// }
    /// ```
    ///
    /// ## What it guarantees
    ///
    /// - Everything logged before it is delivered first. An ordinary log is handed to a queue and
    ///   returns; a fatal that crashed immediately would take the whole trail with it.
    /// - The fatal reaches **every** interceptor, on the calling thread, before the process ends.
    /// - `fatalError` is called after that loop, not inside an interceptor — so a sink's position
    ///   in the list cannot decide whether it is starved.
    /// - ``Logger/minimumLevel`` is ignored. A process about to die owes an explanation whatever
    ///   the build was configured to keep.
    ///
    /// - Returns: Never. The process ends before this call returns.
    static func log(
        _ level: Fatal,
        msg message: String,
        error: (any Error)? = nil,
        data: [String: String]? = nil,
        domain: String = "Core",
        date: Date = .now,
        file: String = #fileID,
        line: Int = #line,
        method: String = #function
    ) -> Never {
        shared.recordFatal(
            message: message, error: error, data: data, domain: domain,
            date: date, file: file, line: line, method: method
        )

        // After the loop, never inside it. `fatalError` takes a `StaticString` for its own file and
        // line, which `#fileID` is not, so the call site goes in the message instead.
        fatalError("[\(domain)] \(file):\(line) \(method) — \(message)")
    }
}

public extension Logger.Level {
    /// Whether a log at this level ends the process.
    ///
    /// Lets an interceptor treat a fatal differently — flush its own buffer, skip filing a
    /// duplicate report — without hard-coding a name.
    var isTerminating: Bool {
        priority >= Logger.Fatal.level.priority
    }
}

/// Identifies one interceptor registration, so it can be removed again.
public struct InterceptorToken: Hashable, Sendable {
    private let id = UUID()
    public init() {}
}

extension Logger {
    /// Blocks until every log recorded so far has reached its interceptors.
    ///
    /// Delivery is asynchronous, so a test that logs and immediately asserts is racing it. Test
    /// support rather than something an app should need.
    static func drain() {
        shared.flush()
    }
}
