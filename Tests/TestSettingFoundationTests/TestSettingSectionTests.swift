//
//  TestSettingSectionTests.swift
//  TestSettingFoundationTests
//
//  Created by Porter McGary on 8/26/26.
//

import XCTest
@testable import TestSettingFoundation

final class TestSettingSectionTests: XCTestCase {
    /// The reason `id` is derived rather than generated: sections are dictionary keys, and settings
    /// name their section independently. Per-instance identity made two equal sections hash apart,
    /// so the same heading was drawn twice.
    func testIndependentlyConstructedEqualSectionsAreOneKey() {
        let first = TestSettingSection(label: "Git", priority: 3)
        let second = TestSettingSection(label: "Git", priority: 3)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.hashValue, second.hashValue)

        var sections: TestSettingSections = [:]
        sections[first, default: []].append(StubSetting(title: "Branch"))
        sections[second, default: []].append(StubSetting(title: "Commit"))

        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[first]?.count, 2)
    }

    func testSectionsDifferingOnlyByPriorityAreDistinct() {
        XCTAssertNotEqual(
            TestSettingSection(label: "Git", priority: 1),
            TestSettingSection(label: "Git", priority: 2)
        )
    }

    func testSectionsSortByPriorityThenLabel() {
        let user = TestSettingSection(label: "User", priority: 1)
        let configuration = TestSettingSection(label: "Configuration", priority: 2)
        let ads = TestSettingSection(label: "Ads")
        let design = TestSettingSection(label: "Design")

        XCTAssertEqual(
            [design, configuration, ads, user].sorted(),
            [user, configuration, ads, design]
        )
    }

    func testUnrankedSectionSortsBelowRankedOne() {
        // `.max` by default, so a section only rises when it is told to.
        XCTAssertEqual(TestSettingSection(label: "Ads").priority, .max)
        XCTAssertTrue(TestSettingSection(label: "Zebra", priority: 1) < TestSettingSection(label: "Ads"))
    }
}
