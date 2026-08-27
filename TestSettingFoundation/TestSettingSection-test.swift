//
//  TestSettingSection.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import Foundation

/// A heading in the Test Settings list, and the key settings group themselves under.
///
/// A section is a value, not a container — it carries only its name and where it sits. The settings
/// that belong to it live in ``TestSettingSections``, keyed by the section itself. That means two
/// settings can name their section independently and still land under one heading, which is why
/// ``id``, `==` and `hash(into:)` all agree on the same two fields: had identity been per-instance,
/// equal sections would occupy separate slots in that dictionary and draw the same header twice.
///
/// A section earns its existence by having something to group. Settings that are one of a kind
/// belong in ``general`` — a section of one is a heading that costs a row and says nothing.
public struct TestSettingSection: Identifiable, Hashable, Sendable {
    public let label: String

    /// Where the section sits in the list. Lower sorts first; ties break alphabetically on
    /// ``label``.
    public let priority: UInt

    public var id: String { "\(priority)|\(label)" }

    /// - Parameter priority: Defaults to sorting last, so a section only rises above the
    ///   alphabetical crowd when you say so.
    public init(label: String, priority: UInt = .max) {
        self.label = label
        self.priority = priority
    }
}

public extension TestSettingSection {
    /// Everything with nothing to be grouped with.
    static let general = TestSettingSection(label: "General")
}

extension TestSettingSection: Comparable {
    public static func < (lhs: TestSettingSection, rhs: TestSettingSection) -> Bool {
        if lhs.priority == rhs.priority {
            lhs.label < rhs.label
        } else {
            lhs.priority < rhs.priority
        }
    }
}
