//
//  DestinationSettingRow.swift
//  DailyDoublet
//
//  Created by Porter McGary on 10/17/24.
//

import SwiftUI

public struct DestinationSettingRow: View {
    let setting: DestinationTestSetting
    
    public init(_ setting: DestinationTestSetting) {
        self.setting = setting
    }
    
    public var body: some View {
        NavigationLink {
            setting.destination
        } label: {
            TestSettingRow(setting)
        }
    }
}
