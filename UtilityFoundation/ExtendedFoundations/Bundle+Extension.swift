//
//  File.swift
//  AstroFramework
//
//  Created by Porter McGary on 8/23/25.
//

import Foundation

import Foundation

public extension Bundle {
    var appVersion: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "\(version) (\(build))"
    }
}

