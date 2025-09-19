//
//  TestSetting.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import Foundation

public protocol TestSetting: Identifiable, Hashable {
    var id: UUID { get }
    var title: String { get }
    var detail: String? { get }
    var section: TestSettingSection { get }
    var priority: UInt { get }
    var hidden: Bool { get }
}

public extension TestSetting {
    var hidden: Bool { false }
    var detail: String? { nil }
    var priority: UInt { 0 }
    var section: TestSettingSection { .general }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(detail)
        hasher.combine(section)
        hasher.combine(priority)
        hasher.combine(hidden)
    }
}

extension Array where Element == (any TestSetting) {
    mutating func sort() {
        self = sorted()
    }
    
    func sorted() -> [Element] {
        sorted {
            if $0.priority == $1.priority {
                return $0.title < $1.title
            }
            return $0.priority < $1.priority
        }
    }
}
