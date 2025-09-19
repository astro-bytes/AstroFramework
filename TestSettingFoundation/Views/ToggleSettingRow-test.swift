//
//  ToggleSettingRow.swift
//  DailyDoublet
//
//  Created by Porter McGary on 10/17/24.
//

import SwiftUI

public struct ToggleSettingRow: View {
    @State private var isOn: Bool
    
    let setting: any ToggleTestSetting
    
    public init(_ setting: any ToggleTestSetting) {
        self.setting = setting
        self._isOn = State(initialValue: setting.initialValue)
    }
    
    public var body: some View {
        Toggle(isOn: setting.mutable ? $isOn : .constant(isOn)) {
            TestSettingRow(setting)
        }
        .onChange(of: isOn) { _, newValue in
            setting.onToggle(newValue)
        }
    }
}
