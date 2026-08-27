//
//  Bundle+Extension.swift
//  UtilityFoundation
//
//  Created by Porter McGary on 8/23/25.
//

import Foundation

public extension Bundle {
    /// The marketing version and build number together, for example `"1.4.2 (317)"`.
    ///
    /// `nil` unless the bundle declares both keys.
    var fullAppVersion: String? {
        guard let appVersion, let buildVersion else { return nil }
        return "\(appVersion) (\(buildVersion))"
    }

    /// The bundle's `CFBundleShortVersionString`, if it declares one.
    ///
    /// Optional rather than force-cast: plenty of legitimate bundles have no version key — test
    /// bundles, app extensions, command-line targets — and a version string is never worth
    /// trapping the host app over.
    var appVersion: String? {
        infoDictionaryString(forKey: "CFBundleShortVersionString")
    }

    /// The bundle's `CFBundleVersion`, if it declares one.
    var buildVersion: String? {
        infoDictionaryString(forKey: "CFBundleVersion")
    }

    private func infoDictionaryString(forKey key: String) -> String? {
        object(forInfoDictionaryKey: key) as? String
    }
}
