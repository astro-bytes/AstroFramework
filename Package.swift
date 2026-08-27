// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AstroFramework",
    // The iOS 18 line. Spelled as strings because the matching `.v18` cases need
    // PackageDescription 6.0, and raising swift-tools-version that far would also switch every
    // target to the Swift 6 language mode.
    platforms: [
        .macOS("15.0"),
        .iOS("18.0"),
        .watchOS("11.0"),
        .tvOS("18.0"),
        .macCatalyst("18.0"),
        .visionOS("2.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EntityFoundation",
            targets: ["EntityFoundation"]),
        .library(
            name: "GatewayFoundation",
            targets: ["GatewayFoundation"]),
        .library(
            name: "LoggerFoundation",
            targets: ["LoggerFoundation"]),
        .library(
            name: "TestSettingFoundation",
            targets: ["TestSettingFoundation"]
        ),
        .library(
            name: "UIFoundation",
            targets: ["UIFoundation"]),
        .library(
            name: "UseCaseFoundation",
            targets: ["UseCaseFoundation"]),
        .library(
            name: "UtilityFoundation",
            targets: ["UtilityFoundation"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EntityFoundation",
            path: "EntityFoundation"
        ),
        .target(
            name: "GatewayFoundation",
            dependencies: ["LoggerFoundation", "UtilityFoundation", "UseCaseFoundation"],
            path: "GatewayFoundation"
        ),
        .target(
            name: "LoggerFoundation",
            path: "LoggerFoundation"
        ),
        .target(
            name: "TestSettingFoundation",
            path: "TestSettingFoundation",
            exclude: ["README.md"]
        ),
        .target(
            name: "UIFoundation",
            dependencies: ["LoggerFoundation", "UtilityFoundation"],
            path: "UIFoundation"
        ),
        .target(
            name: "UseCaseFoundation",
            dependencies: ["EntityFoundation", "UtilityFoundation"],
            path: "UseCaseFoundation"
        ),
        .target(
            name: "UtilityFoundation",
            dependencies: ["LoggerFoundation"],
            path: "UtilityFoundation"
        ),
        
        .target(
            name: "Mocks",
            dependencies: ["GatewayFoundation", "UseCaseFoundation"],
            path: "Mocks"
        ),
        
        // MARK: Test Targets
        .testTarget(
            name: "EntityFoundationTests",
            dependencies: ["EntityFoundation", "Mocks"]
        ),
        .testTarget(
            name: "GatewayFoundationTests",
            dependencies: ["GatewayFoundation", "Mocks"]
        ),
        .testTarget(
            name: "LoggerFoundationTests",
            dependencies: ["LoggerFoundation", "Mocks"]
        ),
        .testTarget(
            name: "TestSettingFoundationTests",
            dependencies: ["TestSettingFoundation"]
        ),
        .testTarget(
            name: "UIFoundationTests",
            dependencies: ["UIFoundation", "Mocks"]
        ),
        .testTarget(
            name: "UseCaseFoundationTests",
            dependencies: ["UseCaseFoundation", "Mocks"]
        ),
        .testTarget(
            name: "UtilityFoundationTests",
            dependencies: ["UtilityFoundation", "Mocks"]
        )
    ]
)
