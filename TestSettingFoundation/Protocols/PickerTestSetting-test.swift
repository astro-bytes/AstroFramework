//
//  PickerTestSetting.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import Foundation

public protocol PickerTestSetting: TestSetting {
    var initialSelection: String? { get async }
    var options: [PickerOption] { get }
    
    func onUpdate(_: String?)
}

public protocol PickerOption {
    var name: String { get }
}
