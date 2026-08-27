//
//  StubSetting.swift
//  TestSettingFoundationTests
//
//  Created by Porter McGary on 8/26/26.
//

import Foundation
@testable import TestSettingFoundation

/// Leans on the protocol's defaults wherever a test does not care, so a change to those defaults
/// shows up as a failing test rather than a silent shift.
struct StubSetting: TestSetting {
    let title: String
    var detail: String?
    var section: TestSettingSection = .general
    var priority: UInt = .max

    init(
        title: String,
        detail: String? = nil,
        section: TestSettingSection = .general,
        priority: UInt = .max
    ) {
        self.title = title
        self.detail = detail
        self.section = section
        self.priority = priority
    }
}

/// Declares nothing but a title, so the protocol's own defaults are what gets measured.
struct MinimalSetting: TestSetting {
    let title: String
}
