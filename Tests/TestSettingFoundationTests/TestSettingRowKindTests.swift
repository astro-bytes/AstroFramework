//
//  TestSettingRowKindTests.swift
//  TestSettingFoundationTests
//
//  Created by Porter McGary on 8/27/26.
//

import XCTest
import SwiftUI
@testable import TestSettingFoundation

/// Which row a setting draws, and — where a setting conforms to more than one of the protocols —
/// which conformance wins.
@MainActor
final class TestSettingRowKindTests: XCTestCase {

    // MARK: One conformance each

    func testASettingWithNoSpecialisedConformanceIsPlain() {
        XCTAssertEqual(TestSettingRowKind(for: MinimalSetting(title: "Build")), .plain)
    }

    func testEachSpecialisedConformanceGetsItsOwnRow() {
        XCTAssertEqual(TestSettingRowKind(for: StubDestinationSetting()), .destination)
        XCTAssertEqual(TestSettingRowKind(for: StubPickerSetting()), .picker)
        XCTAssertEqual(TestSettingRowKind(for: StubToggleSetting()), .toggle)
        XCTAssertEqual(TestSettingRowKind(for: StubActionSetting()), .action)
        XCTAssertEqual(TestSettingRowKind(for: StubInputSetting()), .input)
        XCTAssertEqual(TestSettingRowKind(for: StubCustomSetting()), .custom)
    }

    // MARK: Precedence

    /// A custom row beats every built-in kind, which is the whole point of being able to supply
    /// one — an app adding a row type should not have to avoid the other protocols to be heard.
    func testACustomRowWinsOverABuiltInConformance() {
        XCTAssertEqual(TestSettingRowKind(for: CustomAndToggleSetting()), .custom)
    }

    /// Precedence among the built-ins is a fixed order, not a judgement about specificity. Pinning
    /// it here means reordering the checks is a deliberate act.
    func testBuiltInPrecedenceIsDestinationPickerTogglActionInput() {
        XCTAssertEqual(TestSettingRowKind(for: DestinationAndToggleSetting()), .destination)
        XCTAssertEqual(TestSettingRowKind(for: PickerAndToggleSetting()), .picker)
        XCTAssertEqual(TestSettingRowKind(for: ToggleAndActionSetting()), .toggle)
        XCTAssertEqual(TestSettingRowKind(for: ActionAndInputSetting()), .action)
    }

    // MARK: Rows build

    func testEverySettingKindBuildsARow() {
        let settings: TestSettings = [
            MinimalSetting(title: "Plain"),
            StubDestinationSetting(),
            StubPickerSetting(),
            StubToggleSetting(),
            StubActionSetting(),
            StubInputSetting(),
            StubCustomSetting(),
        ]

        // Building the section view is the assertion: a row kind with no matching branch would
        // fail to compile, and a setting that cannot be cast would produce an empty cell.
        XCTAssertNoThrow(_ = TestSettingSectionView(section: .general, settings: settings))
        XCTAssertEqual(Set(settings.map { TestSettingRowKind(for: $0) }).count, settings.count)
    }
}

// MARK: - Stubs

private struct StubDestinationSetting: DestinationTestSetting {
    let title = "Destination"
    var destination: some View { Text("pushed") }
}

private struct StubPickerSetting: PickerTestSetting {
    struct Option: PickerOption { let name: String }

    let title = "Picker"
    var initialSelection: String? { "a" }
    var options: [any PickerOption] { [Option(name: "a"), Option(name: "b")] }
    func onUpdate(_: String?) {}
}

private struct StubToggleSetting: ToggleTestSetting {
    let title = "Toggle"
    let initialValue = false
    func onToggle(_: Bool) {}
}

private struct StubActionSetting: ActionTestSetting {
    let title = "Action"
    func onInteraction() {}
}

private struct StubInputSetting: InputTestSetting {
    let title = "Input"
    func onUpdate(_: String) {}
}

private struct StubCustomSetting: CustomTestSetting {
    let title = "Custom"
    func makeRow() -> some View { Slider(value: .constant(0.5)) }
}

// MARK: Stubs conforming to two protocols at once

private struct CustomAndToggleSetting: CustomTestSetting, ToggleTestSetting {
    let title = "Both"
    let initialValue = false
    func onToggle(_: Bool) {}
    func makeRow() -> some View { Text("custom wins") }
}

private struct DestinationAndToggleSetting: DestinationTestSetting, ToggleTestSetting {
    let title = "Both"
    let initialValue = false
    func onToggle(_: Bool) {}
    var destination: some View { Text("pushed") }
}

private struct PickerAndToggleSetting: PickerTestSetting, ToggleTestSetting {
    let title = "Both"
    let initialValue = false
    var initialSelection: String? { nil }
    var options: [any PickerOption] { [] }
    func onToggle(_: Bool) {}
    func onUpdate(_: String?) {}
}

private struct ToggleAndActionSetting: ToggleTestSetting, ActionTestSetting {
    let title = "Both"
    let initialValue = false
    func onToggle(_: Bool) {}
    func onInteraction() {}
}

private struct ActionAndInputSetting: ActionTestSetting, InputTestSetting {
    let title = "Both"
    func onInteraction() {}
    func onUpdate(_: String) {}
}
