//
//  URL+Extension.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation
import LoggerFoundation

extension URL {
    /// Checks if the URL represents a directory.
    /// - Returns: `true` if the URL is a directory; otherwise, `false`.
    public var isDirectory: Bool {
        do {
            return try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true || hasDirectoryPath
        } catch CocoaError.fileReadNoSuchFile {
            return false
        } catch {
            Logger.log(.warning, error: error)
            return false
        }
    }
    
    /// Checks if the URL represents a regular file.
    /// - Returns: `true` if the URL is a regular file; otherwise, `false`.
    public var isFile: Bool {
        do {
            return try resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true
        } catch CocoaError.fileReadNoSuchFile {
            return false
        } catch {
            Logger.log(.warning, error: error)
            return false
        }
    }
}
