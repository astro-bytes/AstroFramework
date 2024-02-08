//
//  VersioningCommandPlugin.swift
//  VersioningCommandPlugin
//
//  Created by Porter McGary on 2/6/24.
//

import Foundation
import PackagePlugin

@main
struct VersioningCommandPlugin: CommandPlugin {
    // MARK: - Command Execution
    
    /// Executes the versioning command with the provided context and arguments.
    ///
    /// - Parameters:
    ///   - context: The plugin context.
    ///   - arguments: The command arguments.
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let toolPath = try context.tool(named: "AutomatedAppVersioning").path
        let process = Process()
        process.executableURL = URL(filePath: toolPath.string)
        process.arguments = arguments
        try process.run()
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension VersioningCommandPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let toolPath = try context.tool(named: "AutomatedAppVersioning").path
        let process = Process()
        process.executableURL = URL(filePath: toolPath.string)
        process.arguments = arguments
        try process.run()
    }
}
#endif
