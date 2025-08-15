//
//  PickerSettingRow.swift
//  DailyDoublet
//
//  Created by Porter McGary on 10/17/24.
//

import SwiftUI

public struct PickerSettingRow: View {
    @State private var selection: String?
    
    let setting: any PickerTestSetting
    
    public init(_ setting: any PickerTestSetting) {
        self.setting = setting
    }
    
    public var body: some View {
        Picker(selection: $selection) {
            Text("Select a Value")
                .tag(String?(nil))
            
            ForEach(setting.options, id: \.name) { option in
                Text(option.name)
                    .tag(option.name as String?)
            }
        } label: {
            TestSettingRow(setting)
        }
        .onChange(of: selection) { _, newValue in
            setting.onUpdate(newValue)
        }
        .task {
            selection = await setting.initialSelection
        }
    }
}
