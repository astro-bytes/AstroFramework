//
//  DestinationTestSetting.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import SwiftUI

/// A setting whose row pushes a screen of the app's own.
///
/// ```swift
/// struct FeatureFlagsSetting: DestinationTestSetting {
///     let title = "Feature Flags"
///     let flags: FlagStore
///
///     var destination: some View { FeatureFlagList(flags: flags) }
/// }
/// ```
///
/// The pushed screen is built by the app but presented by the framework's `NavigationLink`, so the
/// app's own theming does not reach it on its own — ``TestSettingsConfiguration/destination`` is
/// how it gets back on.
public protocol DestinationTestSetting: TestSetting {
    associatedtype Destination: View

    /// The screen the row pushes.
    ///
    /// An `associatedtype` rather than a bare `AnyView`: conformers return whatever they build and
    /// the erasure, if any is needed at all, happens here rather than in every app's setting.
    @ViewBuilder @MainActor var destination: Destination { get }
}
