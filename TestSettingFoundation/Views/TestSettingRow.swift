//
//  TestSettingRow.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import SwiftUI

/// The plain title-and-detail row, and the label every other row type is built around.
public struct TestSettingRow: View {
    let setting: any TestSetting

    public init(_ setting: any TestSetting) {
        self.setting = setting
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(setting.title)
            if let detail = setting.detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
