//
//  URL+Extension.swift
//  Utility
//
//  Created by Porter McGary on 1/19/24.
//

import Foundation

extension URL {
    // TODO: Comment
    public var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    // TODO: Comment
    public var isFile: Bool {
        (try? resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile == true
    }
}
