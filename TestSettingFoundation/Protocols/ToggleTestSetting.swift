//
//  ToggleTestSetting.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import Foundation

public protocol ToggleTestSetting: TestSetting {
    var initialValue: Bool { get }
    var mutable: Bool { get }
    
    func onToggle(_: Bool)
}

public extension ToggleTestSetting {
    var mutable: Bool { true }
}
