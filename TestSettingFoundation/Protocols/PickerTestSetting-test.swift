//
//  PickerTestSetting.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import Foundation

/// A setting that picks one value out of a fixed set.
public protocol PickerTestSetting: TestSetting {
    /// The option showing when the row first appears, matched against ``PickerOption/name``.
    ///
    /// Read synchronously as the row is built, so the picker is never briefly empty. A setting that
    /// needs to await something should cache it before it is registered rather than making every
    /// row wait a frame.
    var initialSelection: String? { get }

    var options: [any PickerOption] { get }

    /// - Parameter selection: `nil` when the user picks the placeholder row, which is not one of
    ///   ``options``. Most settings should ignore that rather than reset themselves.
    func onUpdate(_: String?)
}

/// One choice in a ``PickerTestSetting``.
public protocol PickerOption {
    /// Both the label and the identity of the option, so it has to be present.
    var name: String { get }
}
