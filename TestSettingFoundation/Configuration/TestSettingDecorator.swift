//
//  TestSettingDecorator.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 8/26/26.
//

import SwiftUI

/// A view transform an app hands to ``TestSettingsConfiguration`` to reach inside views the
/// framework builds for itself.
///
/// The typed knobs on the configuration cover the settings most apps want to change. A decorator
/// covers the rest — an app's own theming, a toast overlay, a navigation container — in the three
/// places the framework owns the view and the app cannot otherwise get a modifier onto it: the
/// list, a pushed destination, and an individual row.
///
/// ```swift
/// configuration.destination = TestSettingDecorator { $0.themeTint() }
/// ```
///
/// The `AnyView` boxing is the price of storing a view transform in a value type. It runs once per
/// decorated view, which is not a hot path.
public struct TestSettingDecorator {
    private let transform: (AnyView) -> AnyView

    public init<Body: View>(@ViewBuilder _ transform: @escaping (AnyView) -> Body) {
        self.transform = { AnyView(transform($0)) }
    }

    /// Leaves the view exactly as the framework built it.
    public static var identity: TestSettingDecorator {
        TestSettingDecorator { $0 }
    }

    func callAsFunction(_ view: some View) -> AnyView {
        transform(AnyView(view))
    }
}
