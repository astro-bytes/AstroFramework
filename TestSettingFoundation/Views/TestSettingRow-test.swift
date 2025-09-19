//
//  TestSettingRow.swift
//  DailyDoublet
//
//  Created by Porter McGary on 10/17/24.
//

import SwiftUI

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
