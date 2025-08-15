//
//  ActionTestSettingView.swift
//  DailyDoublet
//
//  Created by Porter McGary on 10/17/24.
//

import SwiftUI

public struct ActionTestSettingView: View {
    @State private var presentConfirmation = false
    
    let setting: ActionTestSetting
    
    public init(_ setting: ActionTestSetting) {
        self.setting = setting
    }
    
    public var body: some View {
        if setting.presentConfirmation {
            base.confirmationDialog("Are you sure?", isPresented: $presentConfirmation) {
                Button("Confirm", role: .destructive, action: setting.onInteraction)
            }
        } else {
            base
        }
    }
    
    private var base: some View {
        HStack {
            TestSettingRow(setting)
            Spacer()
            Button(setting.buttonTitle) {
                if setting.presentConfirmation {
                    presentConfirmation.toggle()
                } else {
                    setting.onInteraction()
                }
            }
            .buttonStyle(.bordered)
        }
    }
}
