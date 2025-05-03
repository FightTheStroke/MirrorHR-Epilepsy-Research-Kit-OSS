// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TherapyPackage",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TherapyPackage",
            targets: ["TherapyPackage"]),
        
    ],
    dependencies: [
        .package(name: "RoberdanToolBox", path: "../RoberdanToolbox"),
        .package(name: "PermissionsManager", path: "../PermissionsManager"),
        .package(name: "SharedPkg", path: "../SharedPkg"),
        .package(name: "OpenAIPackage", path: "../OpenAIPackage")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TherapyPackage",
            dependencies: ["RoberdanToolBox", "PermissionsManager", "SharedPkg", "OpenAIPackage"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "TherapyPackageTests",
            dependencies: ["TherapyPackage"]),
    ]
)
