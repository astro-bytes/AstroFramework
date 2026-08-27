//
//  TypeAliases.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 8/10/25.
//

import Foundation

public typealias TestSettings = [any TestSetting]

/// The settings of a Test Settings screen, grouped under the sections that head them.
///
/// Build one with ``Swift/Array/grouped()`` rather than by hand.
public typealias TestSettingSections = [TestSettingSection: TestSettings]
