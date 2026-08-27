//
//  DestinationSettingRow.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import SwiftUI

public struct DestinationSettingRow: View {
    @Environment(\.testSettingsConfiguration) private var configuration

    let setting: any DestinationTestSetting

    public init(_ setting: any DestinationTestSetting) {
        self.setting = setting
    }

    public var body: some View {
        NavigationLink {
            // The pushed screen is built by the app but presented by us, so the app's own theming
            // never reaches it on its own. The decorator is how it gets back on.
            configuration.destination(setting.destination)
        } label: {
            TestSettingRow(setting)
        }
    }
}
