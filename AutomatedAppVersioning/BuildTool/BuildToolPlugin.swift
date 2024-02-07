//
//  VersioningBuildToolPlugin.swift
//  XcodeBuildTool
//
//  Created by Porter McGary on 2/6/24.
//

import Foundation
import PackagePlugin

@main
struct VersioningBuildToolPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        [
            .prebuildCommand(
                displayName: "Automated App Versioning",
                executable: try context.tool(named: "AutomatedAppVersioning").path,
                arguments: extractArguments(),
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }
    
    func extractArguments() -> [String] {
        guard let info = Bundle.main.infoDictionary else { return [] }
        var arguments = [String]()
        
        if let flag = info["test-flag"] as? String {
            arguments.append(contentsOf: ["-t", flag])
        }
        
        if let flag = info["hot-fix-flag"] as? String {
            arguments.append(contentsOf: ["-h", flag])
        }
        
        if let flag = info["config-name"] as? String {
            arguments.append(contentsOf: ["-x", flag])
        }
        
        // TODO: Consider looking for target and passing it along
        
        return arguments
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension VersioningBuildToolPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        [
            .prebuildCommand(
                displayName: "Automated App Versioning",
                executable: try context.tool(named: "AutomatedAppVersioning").path,
                arguments: extractArguments(),
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }
}
#endif
