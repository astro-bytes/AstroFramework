//
//  OnDiskCache.swift
//  GatewayBasics
//
//  Created by Porter McGary on 1/17/24.
//

import Foundation
import Logger
import UseCaseBasics
import Utility

/// Requirements:
/// - Store Data to cache directory
/// - Store the Data Securely with encryption
/// - Access data via memory object
public class OnDiskCache<Payload: Codable>: InMemoryCache<Payload> {
    /// The name of the cache file
    let filename: String
    
    /// Flag indicating that the cache is encrypted or not
    let encrypted: Bool
    
    /// container with access to cached values with
    let defaults: UserDefaults
    
    /// the name used that is unique enough to work as a key
    let name: String
    
    public override var cachedDate: Date? {
        /// sets the cached date value to user defaults for safe keeping
        set { defaults.set(newValue, forKey: name) }
        /// retrieves the cached date value from user defaults
        get { defaults.object(forKey: name) as? Date }
    }
    
    /// Creates a datastore with an on disk expirable cache
    /// - Parameters:
    ///   - name: the key name used to store the CachedDate and CacheFile, defaults to the Payload.type
    ///   - lifetime: the time that the cache has to live before becoming expired
    ///   - encrypted: flag indicating the data is stored as encrypted objects
    ///   - invalidateImmediately: flag that indicates if when initialized the cache should be immediately invalidated and removed from disk
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
    
    public override func set(_ result: DataResult<Payload>) throws {
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
    }
    
    public override func clear() throws {
        try super.clear()
        // Delete File
        let url = try cacheFileURL()
        try FileManager.default.removeItem(at: url)
        // delete key
        if encrypted {
            // TODO: delete key
        }
    }
    
    /// - Returns a data result of the cache value
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
        } catch let error as DecodingError {
            // Decoding clearing the cache of corrupt data
            Logger.log(.warning, error: error)
            try? clear()
            return .uninitialized
        } catch {
            Logger.log(.warning, error: error)
            return .failure(cachedData: nil, error: error)
        }
    }
    
    /// - Returns the file URL related to the Cache
    func cacheFileURL() throws -> URL {
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
    }
}

enum EncryptionManager {
    //TODO: encrypt
    
    //TODO: Decrypt
    
    //TODO: get key
}
