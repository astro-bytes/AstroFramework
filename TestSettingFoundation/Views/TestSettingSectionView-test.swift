//
//  TestSettingSectionView.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import SwiftUI

public struct TestSettingSectionView: View {
    @Environment(\.testSettingsConfiguration) private var configuration

    @State private var isExpanded: Bool = true

    let section: TestSettingSection
    let settings: TestSettings

    public init(section: TestSettingSection, settings: TestSettings) {
        self.section = section
        self.settings = settings
    }

    public var body: some View {
        if !settings.allSatisfy({ $0.hidden }) {
            Section(section.label, isExpanded: $isExpanded) {
                ForEach(settings.sorted(), id: \.id) { setting in
                    if !setting.hidden {
                        // Decorated once, here, rather than inside each row type — so an app's row
                        // modifier lands on the whole cell and lands on it exactly once.
                        configuration.row(row(for: setting))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func row(for setting: any TestSetting) -> some View {
        // Most specific conformance wins; a setting conforming to none of them is read-only.
        if let setting = setting as? (any DestinationTestSetting) {
            DestinationSettingRow(setting)
        } else if let setting = setting as? (any PickerTestSetting) {
            PickerSettingRow(setting)
        } else if let setting = setting as? (any ToggleTestSetting) {
            ToggleSettingRow(setting)
        } else if let setting = setting as? (any ActionTestSetting) {
            ActionTestSettingView(setting)
        } else if let setting = setting as? (any InputTestSetting) {
            InputTestSettingRow(setting)
        } else {
            TestSettingRow(setting)
        }
    }
}
