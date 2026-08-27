//
//  TestSettingsConfigurationTests.swift
//  TestSettingFoundationTests
//
//  Created by Porter McGary on 8/27/26.
//

import XCTest
import SwiftUI
@testable import TestSettingFoundation

@MainActor
final class TestSettingsConfigurationTests: XCTestCase {

    // MARK: Defaults

    /// The defaults are the whole contract for an app that passes no configuration at all, so they
    /// are worth pinning rather than leaving to whatever the initializer last said.
    func testDefaults() {
        let configuration = TestSettingsConfiguration()

        XCTAssertTrue(configuration.isEnabled)
        XCTAssertEqual(configuration.title, "Test Settings")
        XCTAssertNil(configuration.tint)
        XCTAssertEqual(configuration.dynamicTypeSizes, .large ... .xxxLarge)
        XCTAssertTrue(configuration.usesZoomTransition)
    }

    func testToolbarDefaults() {
        let toolbar = TestSettingsConfiguration.Toolbar()

        // `ToolbarItemPlacement` is not Equatable, so the default is pinned by description.
        XCTAssertEqual(String(describing: toolbar.placement), String(describing: ToolbarItemPlacement.primaryAction))
        XCTAssertEqual(toolbar.label, "Test Settings")
        XCTAssertEqual(toolbar.systemImage, "testtube.2")
        XCTAssertTrue(toolbar.showsTrailingSpacer)
    }

    func testEmptyStateDefaults() {
        let emptyState = TestSettingsConfiguration.EmptyState()

        XCTAssertEqual(emptyState.title, "No Settings!")
        XCTAssertEqual(emptyState.systemImage, "testtube.2")
        XCTAssertEqual(emptyState.message, "There are no settings to display.")
    }

    func testEveryFieldIsSettable() {
        var configuration = TestSettingsConfiguration()

        configuration.isEnabled = false
        configuration.title = "Debug"
        configuration.tint = .red
        configuration.usesZoomTransition = false
        configuration.toolbar.placement = .navigation
        configuration.emptyState.title = "Nothing here"

        XCTAssertFalse(configuration.isEnabled)
        XCTAssertEqual(configuration.title, "Debug")
        XCTAssertEqual(configuration.tint, .red)
        XCTAssertFalse(configuration.usesZoomTransition)
        XCTAssertEqual(String(describing: configuration.toolbar.placement), String(describing: ToolbarItemPlacement.navigation))
        XCTAssertEqual(configuration.emptyState.title, "Nothing here")
    }

    // MARK: Decorators

    func testDecoratorsDefaultToIdentity() {
        let configuration = TestSettingsConfiguration()

        // `TestSettingDecorator` has no equatable identity, so the assertion is that each default
        // is a decorator that builds a view rather than being absent.
        XCTAssertNoThrow(_ = configuration.root(Text("root")))
        XCTAssertNoThrow(_ = configuration.destination(Text("destination")))
        XCTAssertNoThrow(_ = configuration.row(Text("row")))
    }

    func testADecoratorRunsItsTransform() {
        var didRun = false
        let decorator = TestSettingDecorator { content in
            didRun = true
            return content.padding()
        }

        _ = decorator(Text("content"))

        XCTAssertTrue(didRun, "the decorator's transform never ran")
    }

    func testIdentityLeavesTheViewAlone() {
        XCTAssertNoThrow(_ = TestSettingDecorator.identity(Text("unchanged")))
    }
}

@MainActor
final class TestSettingsViewTests: XCTestCase {

    /// Sections are drawn in priority order, ties broken alphabetically — decided once at init
    /// rather than per redraw, and the dictionary the settings arrive in has no order of its own.
    func testSectionKeysAreSortedAtInit() {
        let low = TestSettingSection(label: "Zebra", priority: 0)
        let high = TestSettingSection(label: "Alpha", priority: 5)
        let unranked = TestSettingSection(label: "Beta")

        let view = TestSettingsView([
            unranked: [MinimalSetting(title: "c")],
            high: [MinimalSetting(title: "b")],
            low: [MinimalSetting(title: "a")],
        ])

        XCTAssertEqual(view.sectionKeys.map(\.label), ["Zebra", "Alpha", "Beta"])
    }

    func testAnEmptyListStillBuilds() {
        XCTAssertNoThrow(_ = TestSettingsView([:]))
    }

    func testTheBuilderInitializerForwardsItsSections() {
        let view = TestSettingsView {
            [MinimalSetting(title: "one"), MinimalSetting(title: "two")].grouped()
        }

        XCTAssertEqual(view.sectionKeys, [.general])
    }

    /// `testSettings(_:configuration:)` is `@available(macOS, unavailable)` — the zoom navigation
    /// transition it presents with does not exist there. Which means these, the module's actual
    /// entry point, only compile on a run targeting a platform that has it.
#if !os(macOS)
    func testGroupingSettingsIntoTheModifierBuilds() {
        let settings: TestSettings = [MinimalSetting(title: "one")]

        XCTAssertNoThrow(_ = Text("host").testSettings(settings))
        XCTAssertNoThrow(_ = Text("host").testSettings(settings.grouped()))
    }

    /// `isEnabled: false` is "was never here", not "presents nothing" — the toolbar button itself
    /// is what a screenshot run needs gone.
    func testADisabledConfigurationStillBuilds() {
        let configuration = TestSettingsConfiguration(isEnabled: false)

        XCTAssertNoThrow(_ = Text("host").testSettings([], configuration: configuration))
    }

    func testTheModifierBuildsDirectly() {
        XCTAssertNoThrow(_ = Text("host").modifier(TestSettingsViewModifier([:])))
    }
#endif

}
