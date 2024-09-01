// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AstroFramework",
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
