// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PackageDeal",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v10),
        .tvOS(.v17),
        .macCatalyst(.v17),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        
        // MARK: Libraries
        
        .library(
            name: "ConcreteBasics",
            targets: ["ConcreteBasics"]
        ),
        .library(
            name: "EntityBasics",
            targets: ["EntityBasics"]
        ),
        .library(
            name: "GatewayBasics",
            targets: ["GatewayBasics"]
        ),
        .library(
            name: "Logger",
            targets: ["Logger"]
        ),
        .library(
            name: "UniversalUI",
            targets: ["UniversalUI"]
        ),
        .library(
            name: "UseCaseBasics",
            targets: ["UseCaseBasics"]
        ),
        .library(
            name: "Utility",
            targets: ["Utility"]
        ),
        
        // MARK: Plugins
        
        .plugin(
            name: "AutomatedAppVersioningCommand",
            targets: ["AutomatedAppVersioningCommand"]
        ),
        .plugin(
            name: "AutomatedAppVersioningBuildTool",
            targets: ["AutomatedAppVersioningBuildTool"]
        ),
        
        // MARK: Executables
        
        .executable(
            name: "AutomatedAppVersioning",
            targets: ["AutomatedAppVersioning"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.0.0"
        )
    ],
    targets: [
        // MARK: Targets
        
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ConcreteBasics",
            dependencies: ["GatewayBasics", "UseCaseBasics"],
            path: "ConcreteBasics"
        ),
        .target(
            name: "EntityBasics",
            path: "EntityBasics",
            plugins: [
                .plugin(name: "AutomatedAppVersioningBuildTool")
            ]
        ),
        .target(
            name: "GatewayBasics",
            dependencies: ["Logger", "Utility", "UseCaseBasics"],
            path: "GatewayBasics"
        ),
        .target(
            name: "Logger",
            path: "Logger"
        ),
        .target(
            name: "UniversalUI",
            dependencies: ["Logger", "Utility"],
            path: "UniversalUI"
        ),
        .target(
            name: "UseCaseBasics",
            dependencies: ["EntityBasics"],
            path: "UseCaseBasics"
        ),
        .target(
            name: "Utility",
            path: "Utility"
        ),
        .target(
            name: "Mocks",
            dependencies: ["GatewayBasics", "UseCaseBasics"],
            path: "Mocks"
        ),
        
        // MARK: Executable Targets
        
        .executableTarget(
            name: "AutomatedAppVersioning",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "AutomatedAppVersioning/Executable"
        ),
        
        // MARK: Plugins
        
        .plugin(
            name: "AutomatedAppVersioningCommand",
            capability: .command(
                intent: .custom(
                    verb: "automated-app-versioning",
                    description: "Automates the increment of the app version."
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Adds a version-info.xcconfig file.")
                ]
            ),
            dependencies: ["AutomatedAppVersioning"],
            path: "AutomatedAppVersioning/Command"
        ),
        .plugin(
            name: "AutomatedAppVersioningBuildTool",
            capability: .buildTool,
            dependencies: [
                .target(
                    name: "AutomatedAppVersioningBinary",
                    condition: .when(platforms: [.macOS])
                )
            ],
            path: "AutomatedAppVersioning/BuildTool"
        ),
        
        // MARK: Test Targets
        
        .testTarget(
            name: "EntityBasicsTests",
            dependencies: ["EntityBasics", "Mocks"]
        ),
        .testTarget(
            name: "GatewayBasicsTests",
            dependencies: ["GatewayBasics", "Mocks"]
        ),
        .testTarget(
            name: "LoggerTests",
            dependencies: ["Logger", "Mocks"]
        ),
        .testTarget(
            name: "UniversalUITests",
            dependencies: ["UniversalUI", "Mocks"]
        ),
        .testTarget(
            name: "UseCaseBasicsTests",
            dependencies: ["UseCaseBasics", "Mocks"]
        ),
        .testTarget(
            name: "UtilityTests",
            dependencies: ["Utility", "Mocks"]
        ),
        
        // MARK: Binary Targets
        
        .binaryTarget(
            name: "AutomatedAppVersioningBinary",
            path: "AutomatedAppVersioning/Executable/versioning.artifactbundle"
        ),
    ]
)
