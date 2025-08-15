//
//  InputTestSettingRow.swift
//  DailyDoublet
//
//  Created by Porter McGary on 10/17/24.
//

import SwiftUI

public struct InputTestSettingRow: View {
    @State private var isAlertPresented = false
    @State private var input = ""
    
    let setting: InputTestSetting
    
    public init(_ setting: InputTestSetting) {
        self.setting = setting
    }
    
    public var body: some View {
        HStack {
            TestSettingRow(setting)
            Spacer()
            Button(setting.buttonLabel) { isAlertPresented.toggle() }
                .buttonStyle(.bordered)
        }
        .onChange(of: input) { oldValue, newValue in
            setting.onUpdate(newValue)
        }
        .alert(setting.alertLabel, isPresented: $isAlertPresented) {
            TextField(setting.prompt, text: $input)
            
            Button(setting.buttonLabel, role: .destructive) {
                input = ""
            }
            
            Button("Cancel", role: .cancel) {
                input = ""
            }
        }
    }
}
