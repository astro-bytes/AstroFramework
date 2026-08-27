//
//  TestSettingsConfiguration.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 8/26/26.
//

import SwiftUI

/// Everything about the Test Settings screen an app is allowed to have an opinion about.
///
/// The framework owns the structure — the list, the rows, the navigation — and nothing here can
/// change that. What it does not own is personality: an app's tint, its transitions, whether the
/// entry point should exist at all during a screenshot run. Those were the parts that used to be
/// hardcoded, which is what forced apps to keep a private fork of this whole module.
///
/// Build one, and hand it over at the call site:
///
/// ```swift
/// content.testSettings(settings.grouped(), configuration: configuration)
/// ```
///
/// The configuration is written into the SwiftUI environment from there, so rows and pushed
/// destinations the framework builds internally can read it without it being threaded through.
///
/// Nothing here knows about any particular DI container. An app resolves a configuration however it
/// already resolves anything else and passes the result in.
public struct TestSettingsConfiguration {
    /// When `false`, ``SwiftUI/View/testSettings(_:configuration:)`` adds nothing at all — no
    /// toolbar button, no presentation. For screenshot and demo runs, where the testtube button
    /// would otherwise end up in the captures.
    public var isEnabled: Bool

    public var title: String

    /// Applied to the presented list and everything inside it. `nil` leaves the inherited tint
    /// alone.
    public var tint: Color?

    public var dynamicTypeSizes: ClosedRange<DynamicTypeSize>

    /// Whether the presentation animates out of the toolbar button it was opened from.
    public var usesZoomTransition: Bool

    public var toolbar: Toolbar
    public var emptyState: EmptyState

    /// Wraps the whole list. The place for an app's theming, a toast overlay, or its own
    /// navigation container.
    public var root: TestSettingDecorator

    /// Wraps each screen pushed from a ``DestinationTestSetting``. These are presented by the
    /// framework's `NavigationLink`, so an app cannot reach them any other way.
    public var destination: TestSettingDecorator

    /// Wraps every individual row.
    public var row: TestSettingDecorator

    public init(
        isEnabled: Bool = true,
        title: String = "Test Settings",
        tint: Color? = nil,
        dynamicTypeSizes: ClosedRange<DynamicTypeSize> = .large ... .xxxLarge,
        usesZoomTransition: Bool = true,
        toolbar: Toolbar = .init(),
        emptyState: EmptyState = .init(),
        root: TestSettingDecorator = .identity,
        destination: TestSettingDecorator = .identity,
        row: TestSettingDecorator = .identity
    ) {
        self.isEnabled = isEnabled
        self.title = title
        self.tint = tint
        self.dynamicTypeSizes = dynamicTypeSizes
        self.usesZoomTransition = usesZoomTransition
        self.toolbar = toolbar
        self.emptyState = emptyState
        self.root = root
        self.destination = destination
        self.row = row
    }
}

public extension TestSettingsConfiguration {
    /// The toolbar button that opens Test Settings.
    struct Toolbar {
        public var placement: ToolbarItemPlacement
        public var label: String
        public var systemImage: String

        /// Whether to follow the button with a fixed `ToolbarSpacer`, keeping it clear of whatever
        /// the app puts beside it.
        public var showsTrailingSpacer: Bool

        public init(
            placement: ToolbarItemPlacement = .primaryAction,
            label: String = "Test Settings",
            systemImage: String = "testtube.2",
            showsTrailingSpacer: Bool = true
        ) {
            self.placement = placement
            self.label = label
            self.systemImage = systemImage
            self.showsTrailingSpacer = showsTrailingSpacer
        }
    }

    /// Shown when there is nothing to list — usually a sign the app forgot to register anything.
    struct EmptyState {
        public var title: String
        public var systemImage: String
        public var message: String

        public init(
            title: String = "No Settings!",
            systemImage: String = "testtube.2",
            message: String = "There are no settings to display."
        ) {
            self.title = title
            self.systemImage = systemImage
            self.message = message
        }
    }
}
