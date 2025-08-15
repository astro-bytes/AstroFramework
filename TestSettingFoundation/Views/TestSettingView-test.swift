
//
//  TestSettingView.swift
//  TestSettingFoundation
//
//  Created by Porter McGary on 5/26/24.
//

import Foundation
import SwiftUI

public struct TestSettingsView: View {
    @State private var isLoading = true
    
    private let sectionKeys: [TestSettingSection]
    private let sections: TestSettingSections
    
    public init(_ sections: TestSettingSections) {
        self.sectionKeys = sections.keys.sorted()
        self.sections = sections
    }
    
    public var body: some View {
        Group {
            if sections.isEmpty {
                ContentUnavailableView(
                    "No Settings!",
                    systemImage: "testtube.2",
                    description: Text("There are no settings to display.")
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
        .navigationTitle("Test Settings")
        .dynamicTypeSize(.large ... .xxxLarge)
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    TestSettingsView([:])
}
