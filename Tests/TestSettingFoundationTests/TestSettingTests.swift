//
//  TestSettingTests.swift
//  TestSettingFoundationTests
//
//  Created by Porter McGary on 8/26/26.
//

import XCTest
@testable import TestSettingFoundation

final class TestSettingTests: XCTestCase {
    /// SwiftUI keys each row off `id`. Derived from content, two resolutions of the same setting are
    /// the same row, and a toggle or picker keeps its state across a re-render.
    func testIdentityIsStableAcrossInstances() {
        let first = StubSetting(title: "Premium", detail: "on", section: .general, priority: 2)
        let second = StubSetting(title: "Premium", detail: "on", section: .general, priority: 2)

        XCTAssertEqual(first.id, second.id)
    }

    func testIdentityDistinguishesSettingsThatDifferInAnyField() {
        let base = StubSetting(title: "Premium", detail: "on", section: .general, priority: 2)
        let git = TestSettingSection(label: "Git", priority: 3)

        XCTAssertNotEqual(base.id, StubSetting(title: "Tips", detail: "on", section: .general, priority: 2).id)
        XCTAssertNotEqual(base.id, StubSetting(title: "Premium", detail: "off", section: .general, priority: 2).id)
        XCTAssertNotEqual(base.id, StubSetting(title: "Premium", detail: "on", section: git, priority: 2).id)
        XCTAssertNotEqual(base.id, StubSetting(title: "Premium", detail: "on", section: .general, priority: 5).id)
    }

    func testDefaults() {
        let setting = MinimalSetting(title: "Bundle")

        XCTAssertNil(setting.detail)
        XCTAssertEqual(setting.section, .general)
        XCTAssertEqual(setting.priority, .max)
        XCTAssertFalse(setting.hidden)
    }

    func testSettingsSortByPriorityThenTitle() {
        let settings: TestSettings = [
            StubSetting(title: "Zebra", priority: 1),
            StubSetting(title: "Apple", priority: 2),
            StubSetting(title: "Banana", priority: 2)
        ]

        XCTAssertEqual(settings.sorted().map(\.title), ["Zebra", "Apple", "Banana"])
    }

    func testUnrankedSettingSinksBelowRankedOne() {
        let settings: TestSettings = [
            StubSetting(title: "Apple"),
            StubSetting(title: "Zebra", priority: 1)
        ]

        XCTAssertEqual(settings.sorted().map(\.title), ["Zebra", "Apple"])
    }

    func testGroupedBucketsBySectionAndKeepsEverything() {
        let git = TestSettingSection(label: "Git", priority: 3)
        let settings: TestSettings = [
            StubSetting(title: "Branch", section: git),
            StubSetting(title: "Commit", section: git),
            StubSetting(title: "Bundle")
        ]

        let grouped = settings.grouped()

        XCTAssertEqual(grouped.count, 2)
        XCTAssertEqual(grouped[git]?.count, 2)
        XCTAssertEqual(grouped[.general]?.map(\.title), ["Bundle"])
        XCTAssertEqual(grouped.values.map(\.count).reduce(0, +), settings.count)
    }

    func testGroupedOnEmptyInputIsEmpty() {
        XCTAssertTrue(TestSettings().grouped().isEmpty)
    }
}
