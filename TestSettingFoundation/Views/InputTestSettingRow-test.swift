//
//  InputTestSettingRow.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 6/22/24.
//

import SwiftUI

public struct InputTestSettingRow: View {
    @State private var isAlertPresented = false
    @State private var input = ""

    let setting: any InputTestSetting

    public init(_ setting: any InputTestSetting) {
        self.setting = setting
    }

    public var body: some View {
        HStack {
            TestSettingRow(setting)
            Spacer()
            Button(setting.buttonLabel) { isAlertPresented.toggle() }
                .buttonStyle(.bordered)
        }
        .alert(setting.alertLabel, isPresented: $isAlertPresented) {
            TextField(setting.prompt, text: $input)

            // The value commits here and nowhere else. Reporting it from an `onChange` of the field
            // sends a value per keystroke — so a setting reading it is walked through every prefix
            // of what is being typed — and clearing the field on dismissal reports the empty string
            // as though the user had chosen it, wiping the setting on Cancel.
            Button(setting.buttonLabel) {
                setting.onUpdate(input)
                input = ""
            }

            Button("Cancel", role: .cancel) {
                input = ""
            }
        }
    }
}
