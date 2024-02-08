//
//  AutomatedAppVersioning.swift
//  AutomatedAppVersioning
//
//  Created by Porter McGary on 2/5/24.
//

import Foundation
import RegexBuilder
import ArgumentParser

/// Plugin for automated app versioning during the build process.
@main
public struct AutomatedAppVersioning: ParsableCommand {
    // MARK: - Properties
    
    private(set) var gitURL = URL(filePath: "/usr/bin/git")
    
    // Default test build flag
    @Option(name: .shortAndLong, help: "Specify the flag used to identify a test tag.")
    var testFlag: String = "T"
    
    // Default hot fix flag
    @Option(name: .shortAndLong, help: "Specify the flag used to identify a Hot Fix or BCR branch.")
    var hotFixFlag: String = "HF"
    
    // Default xcConfig file name
    @Option(name: .shortAndLong, help: "Specify the name of the xcconfig file.")
    var xcConfigName: String = "version-info"
    
    @Option(name: .long)
    var target: String = ""
    
    var filename: String {
        "\(xcConfigName).xcconfig"
    }
    
    private(set) var appVersionStr = "APP_VERSION"
    private(set) var buildNumberStr = "BUILD_NUMBER"
    
    // Calculated build number
    func buildNumber() -> Int {
        guard let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? Int else {
            print("Could not locate previous build number in info.plist checking \(filename)")
            do {
                let contents = try String(contentsOfFile: filename)
                let lines = contents.split(separator: "\n")
                let keyValues = lines.filter { $0.prefix(2) != "//" || !$0.isEmpty }
                let dictionary = keyValues.reduce(into: [String: String]()) { partialResult, string in
                    let components = string.split(separator: "=").map { $0.description }
                    guard components.count == 2 else { return }
                    let (key, value) = (components.first!, components.last!)
                    partialResult[key] = value
                }
                
                guard let stringValue = dictionary[buildNumberStr],
                      let buildNumber = Int(stringValue) else {
                    print("Could not find build number in \(filename), defaulting to 0")
                    return 0
                }
                
                return buildNumber
            } catch {
                print("Could not locate previous build number in \(filename), defaulting to 0")
                return 0
            }
        }
        
        return buildNumber
    }
    
    public init() {}
    
    public func run() throws {
        // Check if the commit includes a tag
        guard let tag = try commitIncludesTag() else {
            try createWithoutTag()
            return
        }
        
        // Determine whether the tag is a pre-release
        if tag.isPreRelease {
            let buildNo = buildNumber() + 1
            print("Using Commit Tag, with pre-release, increasing the build number \(tag.description)-\(buildNo)")
            // Bump the build number for pre-release versions
            try createConfig(appVersion: tag, buildNumber: buildNo)
        } else {
            // Use the tag as is for non-pre-release versions
            print("Using Commit Tag, with same build number \(tag.description)-\(buildNumber())")
            try createConfig(appVersion: tag)
        }
    }
    
    // MARK: - Version Configuration Creation
    
    /// Creates a configuration when there is no Git tag available.
    /// It determines the version bump based on whether it's a hotfix branch or not.
    ///
    /// - Throws: An error if there's an issue with Git operations.
    func createWithoutTag() throws {
        // Attempt to retrieve the previous Git tag
        guard var tag = try previousTag() else {
            let firstVersionTag = Tag("0.0.0", preReleaseFlag: testFlag)
            print("Creating the very first version because there are no previous commits \(firstVersionTag.description)-\(buildNumber())")
            try createConfig(appVersion: firstVersionTag)
            return
        }
        
        if try isHotFixBranch() {
            if tag.isPreRelease {
                let buildNo = buildNumber() + 1
                print("No Tag on Commit, Hot Fix Branch, Pre-release, incrementing build number - \(tag.description)-\(buildNo)")
                try createConfig(appVersion: tag, buildNumber: buildNo)
            } else {
                // Bump the patch version for hotfix
                tag.patch += 1
                print("No Tag on Commit, Hot Fix Branch incrementing the patch from \(tag.patch - 1) to \(tag.patch) - \(tag.description)-\(buildNumber())")
                try createConfig(appVersion: tag)
            }
        } else {
            // Bump minor version and set patch to 0 for non-hotfix
            tag.minor += 1
            tag.patch = 0
            print("No Tag on Commit, regular branch incrementing the minor from \(tag.minor - 1) to \(tag.minor) - \(tag.description)-\(buildNumber())")
            try createConfig(appVersion: tag)
        }
    }
    
    /// Creates the configuration file with the specified app version and build number.
    ///
    /// - Parameters:
    ///   - appVersion: The app version.
    ///   - buildNumber: The build number.
    func createConfig(appVersion: Tag, buildNumber: Int = 1) throws {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        let contents = """
        //
        // DO NOT DELETE auto generated from Automated App Versioning Plugin
        //
        // Created on \(formatter.string(from: .now))
        //
        
        // Be sure to add `#import \(xcConfigName)` to the base application configuration file OR `\(xcConfigName)` to your project configuration.
        // See https://github.com/astro-bytes/PackageDeal/tree/main/AutomatedAppVersioning#configuration for further instructions on how configurations are integrated into applications
        \(appVersionStr)=\(appVersion.description)
        \(buildNumberStr)=\(buildNumber)
        """
        try contents.write(toFile: filename, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Branch and Tag Analysis
    
    /// Checks if the current branch is a hotfix branch.
    ///
    /// - Returns: A boolean indicating whether it's a hotfix branch.
    func isHotFixBranch() throws -> Bool {
        let process = Process()
        process.executableURL = gitURL
        process.arguments = ["branch", "--show-current"]
        
        guard let output = try execute(process) else { return false}
        let components = output.split(separator: "-")
        
        return components.first?.description == hotFixFlag
    }
    
    /// Checks if the commit includes a tag.
    ///
    /// - Returns: The tag if found, otherwise nil.
    func commitIncludesTag() throws -> Tag? {
        let process = Process()
        process.executableURL = gitURL
        process.arguments = ["tag", "--points-at", "HEAD"]
        
        guard let output = try execute(process) else { return nil }
        
        let strings = output.split(separator: "\n").map { $0.description }
        guard let tag = match(tags: strings) else { return nil }
        return Tag(tag, preReleaseFlag: testFlag)
    }
    
    /// Retrieves the previous tag.
    ///
    /// - Returns: The previous tag if found, otherwise nil.
    func previousTag() throws -> Tag? {
        let process = Process()
        process.executableURL = gitURL
        process.arguments = ["describe", "--tags", "--abbrev=0", "--match=*[0-9].[0-9]*"]
        
        do {
            guard let output = try execute(process),
                    let tag = match(tags: [output])
            else {
                return nil
            }
            
            return Tag(tag, preReleaseFlag: testFlag)
        } catch GitError.descriptive(let description) {
            switch description {
            case "fatal: No names found, cannot describe anything.":
                // No Commit Tags at all
                return nil
            default:
                throw GitError.descriptive(description)
            }
        }
    }
    
    // MARK: - Tag Matching
    
    /// Matches the numeric components of tags and returns the highest valued one.
    ///
    /// - Parameter tags: The list of tags.
    /// - Returns: The highest valued tag if found, otherwise nil.
    func match(tags strings: [String]) -> String? {
        // Application Version Pattern
        let appVersionPattern = Regex {
            Optionally {
                Capture {
                    // Flag indicating this is a TestBuild
                    "\(testFlag)-"
                }
            }
            OneOrMore(.digit)
            "."
            OneOrMore(.digit)
            Optionally {
                Capture {
                    Regex {
                        "."
                        OneOrMore(.digit)
                    }
                }
            }
        }
        
        // Filter out the tags that are NOT numeric
        var tags = strings.reduce(into: [String]()) { partialResult, tag in
            if let result = tag.firstMatch(of: appVersionPattern) {
                partialResult.append(result.output.0.description)
            }
        }
        
        // Sort the tags and take the highest valued one
        tags.sort(by: <)
        guard let tag = tags.last else { return nil }
        return tag
    }
    
    // MARK: - Process Execution
    
    /// Executes a process and returns the output as a string.
    ///
    /// - Parameter process: The process to execute.
    /// - Returns: The output of the process.
    func execute(_ process: Process) throws -> String? {
        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        guard let data = try pipe.fileHandleForReading.readToEnd(),
              let string = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !string.isEmpty else {
            guard let data = try errorPipe.fileHandleForReading.readToEnd(),
                  let error = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !error.isEmpty else {
                if process.terminationStatus == 0 {
                    return nil
                } else {
                    throw GitError.unknown
                }
            }
            
            throw GitError.descriptive(error)
        }
        print("Result of process - \(string)")
        return string
    }
}

/// Struct representing a version tag.
struct Tag: CustomStringConvertible {
    let isPreRelease: Bool
    var major: Int
    var minor: Int
    var patch: Int
    
    /// Initializes a Tag instance with a tag string.
    ///
    /// - Parameters:
    ///   - tag: The tag string.
    ///   - preReleaseFlag: The flag indicating if the tag is a pre-release.
    init(_ tag: String, preReleaseFlag: String) {
        let components = tag.split(separator: "-").map { $0.description }
        isPreRelease = components.first == preReleaseFlag
        
        guard let versions = components.last?.split(separator: ".").map({ $0.description }) else {
            fatalError("Failure to get components from string")
        }
        
        major = versions.count >= 1 ? Int(versions[0])! : 0
        minor = versions.count >= 2 ? Int(versions[1])! : 0
        patch = versions.count >= 3 ? Int(versions[2])! : 0
    }
    
    var description: String {
        "\(major).\(minor).\(patch)"
    }
}

/// Enum representing possible errors during Git operations.
enum GitError: Error {
    case unknown
    case descriptive(String)
}
