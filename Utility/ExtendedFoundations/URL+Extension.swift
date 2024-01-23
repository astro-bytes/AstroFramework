//
//  URL+Extension.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation

extension URL {
    /// Checks if the URL represents a directory.
    /// - Returns: `true` if the URL is a directory; otherwise, `false`.
    public var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    /// Checks if the URL represents a regular file.
    /// - Returns: `true` if the URL is a regular file; otherwise, `false`.
    public var isFile: Bool {
        (try? resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile == true
    }
}
