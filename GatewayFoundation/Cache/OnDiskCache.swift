//
//  OnDiskCache.swift
//  GatewayFoundation
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation
import LoggerFoundation
import UseCaseFoundation
import UtilityFoundation

/// An expirable cache that persists its payload to disk, so a value survives relaunches.
///
/// The payload and the date it was written travel together in one file. Keeping the date beside
/// the value rather than in `UserDefaults` means clearing the cache is a single delete that cannot
/// half-succeed, and there is no separately-keyed date to fall out of step with the file.
public class OnDiskCache<Payload: Codable>: InMemoryCache<Payload> {
    /// What actually goes in the file: the payload, plus when it was written.
    private struct Envelope: Codable {
        let cachedDate: Date
        let payload: Payload
    }

    /// The name of the cache file.
    let filename: String

    /// The unique name identifying this cache.
    let name: String

    /// Creates a datastore with an on-disk expirable cache.
    /// - Parameters:
    ///   - name: The name used for the cache file, defaults to the payload's type name.
    ///   - lifetime: The time that the cache has to live before becoming expired.
    ///   - invalidateImmediately: Flag indicating if the cache should be immediately invalidated and removed from disk when initialized.
    public init(name: String = "\(Payload.self)",
                lifetime: TimeInterval,
                invalidateImmediately: Bool = false) {
        self.filename = "\(name).json"
        self.name = name
        super.init(lifetime: lifetime)

        guard !invalidateImmediately else {
            // Clear the cache if it is to be immediately invalidated. No need to keep it around.
            try? clear()
            return
        }

        let (result, writtenAt) = read()
        restore(result, cachedAt: writtenAt)
    }

    /// Writes the result to disk, restarting the expiry clock.
    ///
    /// Only a success is worth persisting; anything else removes the file, so what is on disk and
    /// what is in memory never disagree.
    /// - Throws: If the payload cannot be encoded, or the file cannot be written or removed.
    public override func set(_ result: DataResult<Payload>) throws {
        try super.set(result)

        guard case .success(let payload) = result, let cachedDate else {
            try removeFile()
            return
        }

        let data = try JSONEncoder().encode(Envelope(cachedDate: cachedDate, payload: payload))
        let url = try cacheFileURL()
        try data.write(to: url)
    }

    /// Clears the in-memory value and deletes the backing file.
    /// - Throws: If the file exists but cannot be removed.
    public override func clear() throws {
        try super.clear()
        try removeFile()
    }

    /// Reads the cache back from disk.
    /// - Returns: The result to adopt, and the date the value was originally written.
    func read() -> (DataResult<Payload>, Date?) {
        do {
            let url = try cacheFileURL()
            let data = try Data(contentsOf: url)
            let envelope = try JSONDecoder().decode(Envelope.self, from: data)

            // `isExpired` reads `cachedDate`, which is not set yet — so ask the date directly.
            let hasExpired = Date.now > envelope.cachedDate.addingTimeInterval(lifetime)
            let result: DataResult<Payload> = hasExpired
                ? .loading(cachedData: envelope.payload)
                : .success(data: envelope.payload)

            return (result, envelope.cachedDate)
        } catch is DecodingError {
            // The file is corrupt, or was written by an older format. Either way it is unusable,
            // so drop it and start over rather than reporting an error the caller cannot act on.
            try? clear()
            return (.uninitialized, nil)
        } catch CocoaError.fileReadNoSuchFile {
            return (.uninitialized, nil)
        } catch {
            Logger.log(.warning, error: error)
            return (.failure(cachedData: nil, error: error), nil)
        }
    }

    /// Deletes the backing file, treating "it was not there" as success.
    private func removeFile() throws {
        do {
            try FileManager.default.removeItem(at: cacheFileURL())
        } catch CocoaError.fileNoSuchFile {
            // Already gone, which is what was wanted.
        }
    }

    /// Returns the file URL related to the cache, creating the containing directory if needed.
    func cacheFileURL() throws -> URL {
        let manager = FileManager.default
        let cacheURL = try manager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        // `bundleIdentifier` is nil in plenty of legitimate hosts — a plain XCTest runner among
        // them — so fall back rather than trapping. The name only has to keep this package's
        // caches out of everyone else's.
        let container = Bundle.main.bundleIdentifier ?? "AstroFramework"

        let directory = cacheURL.appending(path: container, directoryHint: .isDirectory)
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)

        return directory.appending(path: filename, directoryHint: .notDirectory)
    }
}
