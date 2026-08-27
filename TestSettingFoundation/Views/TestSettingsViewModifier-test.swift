//
//  TestSettingsViewModifier.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import SwiftUI

/// Puts the Test Settings entry point in the toolbar and presents the list from it.
///
/// Reach for ``SwiftUI/View/testSettings(_:configuration:)`` rather than this directly.
@available(macOS, unavailable)
public struct TestSettingsViewModifier: ViewModifier {
    private static let transitionID = "test-settings"

    @State private var isTestSettingsPresented = false
    @Namespace private var namespace

    private let sections: TestSettingSections
    private let configuration: TestSettingsConfiguration

    public init(_ sections: TestSettingSections, configuration: TestSettingsConfiguration = .init()) {
        self.sections = sections
        self.configuration = configuration
    }

    public func body(content: Content) -> some View {
        if configuration.isEnabled {
            content
                .fullScreenCover(isPresented: $isTestSettingsPresented) { cover }
                .toolbar {
                    ToolbarItem(placement: configuration.toolbar.placement) { button }

                    // `ToolbarSpacer` is newer than the package's floor, so below it the button
                    // simply sits where the app's own toolbar content leaves it.
                    if configuration.toolbar.showsTrailingSpacer,
                       #available(iOS 26, macCatalyst 26, tvOS 26, watchOS 26, visionOS 26, *) {
                        ToolbarSpacer(.fixed, placement: configuration.toolbar.placement)
                    }
                }
        } else {
            // Not "present nothing" but "was never here" — the button itself is what a screenshot
            // run needs gone.
            content
        }
    }

    private var cover: some View {
        NavigationStack {
            TestSettingsView(sections, configuration: configuration)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", systemImage: "xmark") {
                            isTestSettingsPresented = false
                        }
                    }
                }
        }
        .zoomTransition(id: Self.transitionID, in: namespace, enabled: configuration.usesZoomTransition)
    }

    private var button: some View {
        Button(configuration.toolbar.label, systemImage: configuration.toolbar.systemImage) {
            isTestSettingsPresented = true
        }
        .zoomTransitionSource(id: Self.transitionID, in: namespace, enabled: configuration.usesZoomTransition)
    }
}

// Zoom navigation transitions do not exist on macOS, which is also why the modifier above is
// unavailable there.
@available(macOS, unavailable)
private extension View {
    @ViewBuilder
    func zoomTransition(id: String, in namespace: Namespace.ID, enabled: Bool) -> some View {
        if enabled {
            navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            self
        }
    }

    @ViewBuilder
    func zoomTransitionSource(id: String, in namespace: Namespace.ID, enabled: Bool) -> some View {
        if enabled {
            matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }
}

@available(macOS, unavailable)
#Preview {
    NavigationStack {
        Text("Hello, world!")
            .modifier(TestSettingsViewModifier([:]))
    }
}
