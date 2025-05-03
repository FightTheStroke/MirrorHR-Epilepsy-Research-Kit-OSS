// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyStripeApplePayPackage",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16), // Specify minimum platform version for iOS as 13.0
    ], products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MyStripeApplePayPackage",
            targets: ["MyStripeApplePayPackage"]),
    ],
    dependencies: [
        // Adding Stripe iOS SDK as a dependency
        .package(url: "https://github.com/stripe/stripe-ios-spm", from: "23.0.0"),
        .package(name: "RoberdanSecretsPackage", path: "../RoberdanSecretsPackage"),
        .package(name: "SharedPkg", path: "../SharedPkg")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MyStripeApplePayPackage",
            dependencies: [
                .product(name: "Stripe", package: "stripe-ios-spm"),
                "RoberdanSecretsPackage",
                "SharedPkg"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MyStripeApplePayPackageTests",
            dependencies: ["MyStripeApplePayPackage"]),
    ]
)
