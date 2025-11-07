//
//  File.swift
//  AstroFramework
//
//  Created by Porter McGary on 8/23/25.
//

import Foundation

public extension Bundle {
    var fullAppVersion: String {
        return "\(appVersion) (\(buildVersion))"
    }
    
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    var buildVersion: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
}
