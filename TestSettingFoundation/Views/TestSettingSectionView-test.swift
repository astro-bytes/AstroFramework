//
//  TestSettingSectionView.swift
//  DailyDoublet
//
//  Created by Porter McGary on 10/17/24.
//

import SwiftUI

public struct TestSettingSectionView: View {
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
                        if let setting = setting as? DestinationTestSetting {
                            DestinationSettingRow(setting)
                        } else if let setting = setting as? PickerTestSetting {
                            PickerSettingRow(setting)
                        } else if let setting = setting as? ToggleTestSetting {
                            ToggleSettingRow(setting)
                        } else if let setting = setting as? ActionTestSetting {
                            ActionTestSettingView(setting)
                        } else if let setting = setting as? InputTestSetting {
                            InputTestSettingRow(setting)
                        } else {
                            TestSettingRow(setting)
                        }
                    }
                }
            }
        }
    }
}
