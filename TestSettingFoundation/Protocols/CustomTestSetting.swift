//
//  CustomTestSetting.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 8/27/26.
//

import SwiftUI

/// A setting that draws its own row.
///
/// The built-in row types — a toggle, a picker, a button, a text prompt, a pushed screen — cover
/// what most debug screens need. This is the way in for the ones they do not: a slider, a colour
/// well, a live-updating readout, anything an app wants.
///
/// Without it, the only way to add a row type was to fork the module, which is the same problem
/// ``TestSettingsConfiguration`` was written to solve for everything else.
///
/// ```swift
/// struct FrameRateSetting: CustomTestSetting {
///     let title = "Render Scale"
///     @Bindable var renderer: Renderer
///
///     func makeRow() -> some View {
///         VStack(alignment: .leading) {
///             Text(title)
///             Slider(value: $renderer.scale, in: 0.5 ... 2)
///         }
///     }
/// }
/// ```
///
/// A custom row is checked for before any of the built-in conformances, so a setting that is both
/// this and, say, a ``ToggleTestSetting`` draws what ``makeRow()`` returns.
///
/// The row is placed in the list and decorated like any other, so it inherits the app's row
/// decorator and the section it named.
public protocol CustomTestSetting: TestSetting {
    associatedtype Row: View

    /// Builds the row.
    @ViewBuilder @MainActor func makeRow() -> Row
}
