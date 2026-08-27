//
//  InputTestSetting.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 6/22/24.
//

import Foundation

public protocol InputTestSetting: TestSetting {
    var prompt: String { get }
    var buttonLabel: String { get }
    var alertLabel: String { get }
    
    func onUpdate(_: String)
}

public extension InputTestSetting {
    var prompt: String { "" }
    var buttonLabel: String { "Change" }
    var alertLabel: String { "Input" }
}
