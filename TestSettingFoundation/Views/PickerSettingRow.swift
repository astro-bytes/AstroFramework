//
//  PickerSettingRow.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import SwiftUI

public struct PickerSettingRow: View {
    @State private var selection: String?

    let setting: any PickerTestSetting

    public init(_ setting: any PickerTestSetting) {
        self.setting = setting
        self._selection = .init(initialValue: setting.initialSelection)
    }

    public var body: some View {
        content
            .onChange(of: selection) { _, newValue in
                setting.onUpdate(newValue)
            }
    }

    // The picker sits beside the title rather than being the row's own label, so the detail line can
    // run the full width underneath both. A `Picker` labelled by a two-line `TestSettingRow` puts
    // the menu opposite the middle of the label and leaves the detail squeezed against it.
    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(setting.title)
                Spacer()

                Picker("", selection: $selection) {
                    Text("Select a Value")
                        .tag(String?(nil))

                    ForEach(setting.options, id: \.name) { option in
                        Text(option.name)
                            // Tagged as `String?` to match the type of `selection`. A bare `String`
                            // tag never compares equal to an optional selection, and the picker
                            // silently stops tracking what the user chose.
                            .tag(option.name as String?)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

            if let detail = setting.detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
