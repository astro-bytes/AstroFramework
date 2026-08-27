//
//  Logger.swift
//  LoggerFoundation
//
//  Created by Porter McGary on 1/18/24.
//

import Foundation

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
///
/// ## Thread safety
///
/// Safe to call from any thread. All state is guarded by a lock, which is what the `@unchecked`
/// conformance stands in for.
public final class Logger: @unchecked Sendable {

    /// Singleton pattern shared instance.
    static let shared = Logger()

    // MARK: Configuration

    /// The least severe level that will be delivered. Defaults to ``Level/debug``, which delivers
    /// everything.
    ///
    /// Filtering happens before any interceptor is consulted, and before the log is dispatched, so
    /// a call below the threshold costs an integer comparison.
    public static var minimumLevel: Level {
        get { shared.withState { $0.minimumLevel } }
        set { shared.withState { $0.minimumLevel = newValue } }
    }

    // MARK: Interceptors

    /// Registers an interceptor.
    /// - Parameter interceptor: The interceptor to receive subsequent logs.
    /// - Returns: A token identifying the registration, for handing to ``remove(_:)``.
    @discardableResult
    public static func apply(interceptor: any Interceptor) -> InterceptorToken {
        let token = InterceptorToken()
        shared.withState { $0.interceptors.append((token, interceptor)) }
        return token
    }

    /// Registers several interceptors at once.
    /// - Parameter interceptors: The interceptors to receive subsequent logs.
    /// - Returns: One token per interceptor, in the order given.
    @discardableResult
    public static func apply(interceptors: [any Interceptor]) -> [InterceptorToken] {
        let registrations = interceptors.map { (InterceptorToken(), $0) }
        shared.withState { $0.interceptors.append(contentsOf: registrations) }
        return registrations.map(\.0)
    }

    /// Stops the interceptor registered under `token` from receiving further logs.
    ///
    /// A token that is not registered — already removed, or from a previous ``reset()`` — is
    /// ignored.
    public static func remove(_ token: InterceptorToken) {
        shared.withState { $0.interceptors.removeAll { $0.token == token } }
    }

    /// Removes every interceptor, including the one registered automatically in `DEBUG` builds.
    public static func removeAllInterceptors() {
        shared.withState { $0.interceptors.removeAll() }
    }

    /// Returns the logger to the state it starts a process in: default interceptors, default
    /// threshold.
    ///
    /// Intended for tests, which otherwise leak registrations into each other.
    public static func reset() {
        shared.withState {
            $0.interceptors = Logger.defaultInterceptors()
            $0.minimumLevel = .debug
        }
    }

    /// How many interceptors are currently registered.
    static var interceptorCount: Int {
        shared.withState { $0.interceptors.count }
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

    /// Everything guarded by ``lock``.
    private struct State {
        var interceptors: [(token: InterceptorToken, interceptor: any Interceptor)]
        var minimumLevel: Level
    }

    private let lock = NSLock()
    private var state: State

    /// Delivery runs here, so interceptors see logs in the order the calls were made and never
    /// concurrently with each other.
    ///
    /// Previously each log spawned its own detached task, which left ordering to chance and read
    /// the interceptor list without synchronising against registration.
    private let queue = DispatchQueue(label: "me.astrobytes.AstroFramework.Logger", qos: .utility)

    private init() {
        state = State(interceptors: Logger.defaultInterceptors(), minimumLevel: .debug)
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

    private func withState<Value>(_ body: (inout State) -> Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        return body(&state)
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
        let recipients: [any Interceptor] = withState { state in
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
        shared.queue.sync {}
    }
}
