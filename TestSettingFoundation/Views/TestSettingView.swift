//
//  TestSettingView.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import Foundation
import SwiftUI

/// The Test Settings list.
///
/// Takes the settings it draws rather than reaching for a container, so it can be previewed and
/// tested with a literal.
public struct TestSettingsView: View {
    /// The section headings in the order they are drawn: by priority, ties alphabetical.
    /// Sorted once here rather than on every redraw.
    let sectionKeys: [TestSettingSection]
    private let sections: TestSettingSections
    private let configuration: TestSettingsConfiguration

    public init(_ sections: TestSettingSections, configuration: TestSettingsConfiguration = .init()) {
        self.sectionKeys = sections.keys.sorted()
        self.sections = sections
        self.configuration = configuration
    }

    public init(
        configuration: TestSettingsConfiguration = .init(),
        builder: () -> TestSettingSections
    ) {
        self.init(builder(), configuration: configuration)
    }

    public var body: some View {
        // The title goes on before the decorator runs, so an app that wraps the list in its own
        // navigation container still gets a titled list inside it. Tint and the configuration itself
        // go on after, because both travel down the environment either way.
        configuration.root(titledContent)
            .tint(configuration.tint)
            .testSettingsConfiguration(configuration)
    }

    private var titledContent: some View {
        content
            .navigationTitle(configuration.title)
            .dynamicTypeSize(configuration.dynamicTypeSizes)
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
    }

    @ViewBuilder
    private var content: some View {
        if sections.isEmpty {
            ContentUnavailableView(
                configuration.emptyState.title,
                systemImage: configuration.emptyState.systemImage,
                description: Text(configuration.emptyState.message)
            )
        } else {
            List {
                ForEach(sectionKeys) { key in
                    TestSettingSectionView(section: key, settings: sections[key] ?? [])
                }
            }
            .listStyle(.sidebar)
        }
    }
}

#Preview {
    TestSettingsView([:])
}
