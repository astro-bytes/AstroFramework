//
//  TestSettingSection.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import Foundation

public struct TestSettingSection: Identifiable {
    public let id: UUID = .init()
    public let label: String
    public let priority: UInt
    
    public init(label: String, priority: UInt = 0) {
        self.label = label
        self.priority = priority
    }
}

public extension TestSettingSection {
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
    
    public static func == (lhs: TestSettingSection, rhs: TestSettingSection) -> Bool {
        lhs.label == rhs.label && lhs.priority == rhs.priority
    }
}

extension TestSettingSection: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(label)
        hasher.combine(priority)
    }
}
