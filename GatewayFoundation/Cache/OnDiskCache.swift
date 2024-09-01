//
//  OnDiskCache.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation
import LoggerFoundation
import UseCaseFoundation
import UtilityFoundation

/// A class representing an on-disk cache with expirable data, inheriting from `InMemoryCache`.
/// This cache persists data on disk, allowing for retrieval even after the application restarts.
/// It supports optional encryption for added security.
public class OnDiskCache<Payload: Codable>: InMemoryCache<Payload> {
    /// The name of the cache file.
    let filename: String
    
    /// Flag indicating whether the cache is encrypted or not.
    let encrypted: Bool
    
    /// Container with access to cached values.
    let defaults: UserDefaults
    
    /// The unique name used as a key for UserDefaults.
    let name: String
    
    /// Overrides the cachedDate property to persist the value in UserDefaults.
    public override var cachedDate: Date? {
        /// sets the cached date value to user defaults for safe keeping
        set { defaults.set(newValue, forKey: name) }
        /// retrieves the cached date value from user defaults
        get { defaults.object(forKey: name) as? Date }
    }
    
    /// Creates a datastore with an on-disk expirable cache.
    /// - Parameters:
    ///   - name: The key name used to store the cached date and cache file, defaults to Payload.type.
    ///   - lifetime: The time that the cache has to live before becoming expired.
    ///   - encrypted: Flag indicating if the data is stored as encrypted objects.
    ///   - invalidateImmediately: Flag indicating if the cache should be immediately invalidated and removed from disk when initialized.
    public init(name: String = "\(Payload.self)",
                lifetime: TimeInterval, encrypted: Bool = true,
                invalidateImmediately: Bool = false) {
        guard let defaults = UserDefaults.init(suiteName: "caches") else {
            // WTF UserDefaults
            fatalError("UserDefaults suite 'caches' failed")
        }
        
        self.filename = "\(name).json"
        self.encrypted = encrypted
        self.defaults = defaults
        self.name = name
        super.init(lifetime: lifetime)
        
        if !invalidateImmediately {
            let result = get()
            switch result {
            case .success:
                try? super.set(result)
            default:
                self.value = result
            }
        } else {
            // clear the cache if it is to be immediately invalidated.
            // no need to keep it around
            try? self.clear()
        }
    }
    
    /// Overrides the set method to encode, encrypt (if applicable), and store the cache on disk.
    public override func set(_ result: DataResult<Payload>) throws {
        do {
            try super.set(result)
            // encode
            guard case .success(let payload) = result else { return }
            let jsonData = try JSONEncoder().encode(payload)
            // encrypt
            if encrypted {
                // TODO: Encrypt
            }
            // store
            let url = try cacheFileURL()
            try jsonData.write(to: url)
        } catch {
            Logger.log(.warning, error: error)
        }
    }
    
    /// Overrides the clear method to delete the cache file and key (if applicable).
    public override func clear() throws {
        try super.clear()
        // Delete File
        let url = try cacheFileURL()
        do {
            try FileManager.default.removeItem(at: url)
        } catch CocoaError.fileNoSuchFile {
            // Do nothing
        } catch {
            throw error
        }
        // delete key
        if encrypted {
            // TODO: delete key
        }
    }
    
    /// Retrieves the cache value from the disk.
    /// - Returns: A data result of the cache value.
    func get() -> DataResult<Payload> {
        do {
            // read file
            let url = try cacheFileURL()
            let cachedData = try Data(contentsOf: url)
            // decrypt
            if encrypted {
                // TODO: Decrypt
            }
            // decode
            let payload = try JSONDecoder().decode(Payload.self, from: cachedData)
            
            if isExpired {
                return .loading(cachedData: payload)
            } else {
                return .success(data: payload)
            }
        } catch is DecodingError {
            // Decoding clearing the cache of corrupt data
            try? clear()
            return .uninitialized
        } catch CocoaError.fileReadNoSuchFile {
            return .uninitialized
        } catch {
            Logger.log(.warning, error: error)
            return .failure(cachedData: nil, error: error)
        }
    }
    
    /// Returns the file URL related to the cache.
    /// - Returns: The file URL related to the cache.
    func cacheFileURL() throws -> URL {
        do {
            let manager = FileManager.default
            let cacheURL = try manager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            guard let identifier = Bundle.main.bundleIdentifier else {
                fatalError("Bundle Identifier is Essential")
            }
            let bundleDirectory = cacheURL.appending(path: identifier)
            if !bundleDirectory.isDirectory {
                try manager.createDirectory(at: bundleDirectory, withIntermediateDirectories: true)
            }
            let fileURL = bundleDirectory.appending(path: filename, directoryHint: .notDirectory)
            return fileURL
        } catch {
            throw error
        }
    }
}

enum EncryptionManager {
    //TODO: encrypt
    
    //TODO: Decrypt
    
    //TODO: get key
}
