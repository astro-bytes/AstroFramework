//
//  TestSettingsConfiguration+Environment.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 8/26/26.
//

import SwiftUI

public extension EnvironmentValues {
    /// The configuration in force for the Test Settings views below this point.
    ///
    /// ``TestSettingsView`` sets this from the configuration it is given, so rows and pushed
    /// destinations pick it up without it being passed down by hand.
    @Entry var testSettingsConfiguration = TestSettingsConfiguration()
}

public extension View {
    func testSettingsConfiguration(_ configuration: TestSettingsConfiguration) -> some View {
        environment(\.testSettingsConfiguration, configuration)
    }
}
