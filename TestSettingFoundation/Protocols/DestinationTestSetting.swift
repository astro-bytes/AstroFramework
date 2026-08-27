//
//  DestinationTestSetting.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import Foundation
import SwiftUI

public protocol DestinationTestSetting: TestSetting {
    var destination: AnyView { get }
}
