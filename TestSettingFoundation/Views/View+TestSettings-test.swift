//
//  View+TestSettings.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 8/26/26.
//

import SwiftUI

@available(macOS, unavailable)
public extension View {
    /// Adds the Test Settings toolbar button to this view, presenting `sections` from it.
    ///
    /// ```swift
    /// content.testSettings(settings.grouped(), configuration: configuration)
    /// ```
    ///
    /// Whether the entry point should exist in a given build is the app's call — gate the call site
    /// on your own build configuration, or hand over a configuration with
    /// ``TestSettingsConfiguration/isEnabled`` set to `false`.
    func testSettings(
        _ sections: TestSettingSections,
        configuration: TestSettingsConfiguration = .init()
    ) -> some View {
        modifier(TestSettingsViewModifier(sections, configuration: configuration))
    }

    /// Adds the Test Settings toolbar button, grouping `settings` into sections for you.
    func testSettings(
        _ settings: TestSettings,
        configuration: TestSettingsConfiguration = .init()
    ) -> some View {
        testSettings(settings.grouped(), configuration: configuration)
    }
}
