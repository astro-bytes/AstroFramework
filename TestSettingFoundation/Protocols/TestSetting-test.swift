//
//  TestSetting.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import Foundation

/// One row in the Test Settings list.
///
/// Conformers describe themselves — what to call the row, which ``TestSettingSection`` it belongs
/// to, and how far up that section it sits. The framework decides how to draw it by looking for a
/// more specific conformance (``ToggleTestSetting``, ``PickerTestSetting``, and so on); a type that
/// conforms to this protocol alone renders as a read-only title and detail.
public protocol TestSetting {
    /// Identity for SwiftUI's row diffing.
    ///
    /// The default is derived from the row's own content rather than being freshly generated, so a
    /// setting that is resolved twice from a container keeps the same identity both times. That is
    /// what lets a toggle or a picker hold its `@State` across a re-render instead of being torn
    /// down and rebuilt underneath the user.
    var id: String { get }

    var title: String { get }
    var detail: String? { get }
    var section: TestSettingSection { get }

    /// Where the row sits within its section. Lower sorts first; ties break alphabetically on
    /// ``title``.
    var priority: UInt { get }

    /// Whether to leave the row out entirely. A section whose settings are all hidden draws no
    /// header.
    var hidden: Bool { get }
}

public extension TestSetting {
    var id: String { "\(section.id)|\(priority)|\(title)|\(detail ?? "")" }
    var detail: String? { nil }
    var section: TestSettingSection { .general }

    /// Unranked settings sink to the bottom of their section, where they sort alphabetically among
    /// themselves. The alternative — defaulting to `0` — means every unranked setting outranks
    /// anything you deliberately promoted, which is the opposite of what a priority is for.
    var priority: UInt { .max }

    var hidden: Bool { false }
}

public extension Array where Element == any TestSetting {
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

    /// Buckets settings into the sections they name.
    ///
    /// Saves every caller writing the same `reduce`. Ordering is not applied here — ``TestSettingsView``
    /// sorts the section keys and each bucket as it draws them.
    func grouped() -> TestSettingSections {
        reduce(into: TestSettingSections()) { sections, setting in
            sections[setting.section, default: []].append(setting)
        }
    }
}
