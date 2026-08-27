//
//  TestSettingSectionView.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import SwiftUI

public struct TestSettingSectionView: View {
    @Environment(\.testSettingsConfiguration) private var configuration

    @State private var isExpanded: Bool = true

    let section: TestSettingSection
    let settings: TestSettings

    public init(section: TestSettingSection, settings: TestSettings) {
        self.section = section
        self.settings = settings
    }

    public var body: some View {
        if !settings.allSatisfy({ $0.hidden }) {
            Section(section.label, isExpanded: $isExpanded) {
                ForEach(settings.sorted(), id: \.id) { setting in
                    if !setting.hidden {
                        // Decorated once, here, rather than inside each row type — so an app's row
                        // modifier lands on the whole cell and lands on it exactly once.
                        configuration.row(row(for: setting))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func row(for setting: any TestSetting) -> some View {
        switch TestSettingRowKind(for: setting) {
        case .custom:
            // Safe: `TestSettingRowKind` reports `.custom` only for this conformance.
            if let setting = setting as? (any CustomTestSetting) {
                AnyView(setting.makeRow())
            }
        case .destination:
            if let setting = setting as? (any DestinationTestSetting) {
                DestinationSettingRow(setting)
            }
        case .picker:
            if let setting = setting as? (any PickerTestSetting) {
                PickerSettingRow(setting)
            }
        case .toggle:
            if let setting = setting as? (any ToggleTestSetting) {
                ToggleSettingRow(setting)
            }
        case .action:
            if let setting = setting as? (any ActionTestSetting) {
                ActionTestSettingView(setting)
            }
        case .input:
            if let setting = setting as? (any InputTestSetting) {
                InputTestSettingRow(setting)
            }
        case .plain:
            TestSettingRow(setting)
        }
    }
}

/// Which row a setting draws.
///
/// Split out from the view so the choice can be asserted on directly. It is decided by a fixed
/// order of conformance checks, and the order is the part that quietly matters: a setting that
/// conforms to two of these protocols draws the first one listed, not "the most specific" in any
/// sense the compiler knows about.
enum TestSettingRowKind: Equatable {
    /// The setting builds its own row, which beats every built-in kind.
    case custom
    case destination
    case picker
    case toggle
    case action
    case input
    /// Conforms to none of the specialised protocols: a read-only title and detail.
    case plain

    init(for setting: any TestSetting) {
        switch setting {
        case is any CustomTestSetting: self = .custom
        case is any DestinationTestSetting: self = .destination
        case is any PickerTestSetting: self = .picker
        case is any ToggleTestSetting: self = .toggle
        case is any ActionTestSetting: self = .action
        case is any InputTestSetting: self = .input
        default: self = .plain
        }
    }
}
