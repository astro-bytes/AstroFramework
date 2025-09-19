//
//  DestinationSettingRow.swift
//  DailyDoublet
//
//  Created by Porter McGary on 10/17/24.
//

import SwiftUI

public struct DestinationSettingRow: View {
    let setting: any DestinationTestSetting
    
    public init(_ setting: any DestinationTestSetting) {
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
