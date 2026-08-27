//
//  ActionTestSetting.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import Foundation

public protocol ActionTestSetting: TestSetting {
    var buttonTitle: String { get }
    var presentConfirmation: Bool { get }
    
    func onInteraction()
}

public extension ActionTestSetting {
    var buttonTitle: String { "Perform" }
    var presentConfirmation: Bool { true }
}
