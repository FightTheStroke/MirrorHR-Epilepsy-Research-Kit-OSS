// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MirrorHRKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "MirrorHRKit",
            targets: ["MirrorHRKit"])
    ],
    dependencies: [
        // Local packages
        .package(path: "../Packages/RoberdanToolbox"),
        .package(path: "../Packages/PermissionsManager"),
        .package(path: "../Packages/SharedPkg"),
        .package(path: "../Packages/TherapyPackage"),
        .package(path: "../Packages/MyStripeApplePayPackage"),
        .package(path: "../Packages/StateMachineKit"),
        
        // Remote packages
        .package(url: "https://github.com/adrianmacarenco/WindowsAzureMessagingNotifications", branch: "main"),
        .package(url: "https://github.com/ivanvorobei/SPConfetti", from: "1.2.4"),
        .package(url: "https://github.com/ABTSoftware/SciChart-SP", from: "4.4.1")
    ],
    targets: [
        .target(
            name: "MirrorHRKit",
            dependencies: [
                .product(name: "RoberdanToolBox", package: "RoberdanToolbox"),
                .product(name: "SharedPkg", package: "SharedPkg"),
                .product(name: "SciChart", package: "SciChart-SP"),
                .product(name: "SPConfetti", package: "SPConfetti"),
                .product(name: "StateMachineKit", package: "StateMachineKit"),
                .product(name: "PermissionsManager", package: "PermissionsManager"),
                .product(name: "WindowsAzureMessagingNotifications", package: "WindowsAzureMessagingNotifications"),
                .product(name: "TherapyPackage", package: "TherapyPackage"),
                .product(name: "MyStripeApplePayPackage", package: "MyStripeApplePayPackage")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MirrorHRKitTests",
            dependencies: [
                .product(name: "RoberdanToolBox", package: "RoberdanToolbox"),
                .product(name: "SharedPkg", package: "SharedPkg"),
                .product(name: "SciChart", package: "SciChart-SP"),
                .product(name: "SPConfetti", package: "SPConfetti"),
                .product(name: "StateMachineKit", package: "StateMachineKit"),
                .product(name: "PermissionsManager", package: "PermissionsManager"),
                .product(name: "WindowsAzureMessagingNotifications", package: "WindowsAzureMessagingNotifications"),
                .product(name: "TherapyPackage", package: "TherapyPackage"),
                .product(name: "MyStripeApplePayPackage", package: "MyStripeApplePayPackage")
            ]
        )
    ]
)
