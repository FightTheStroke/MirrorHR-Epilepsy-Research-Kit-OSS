// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MirrorHRTelemetryPackage",
    platforms: [.iOS(.v16), .watchOS(.v8)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MirrorHRTelemetryPackage",
            targets: ["MirrorHRTelemetryPackage"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "TelemetryClient", url: "https://github.com/TelemetryDeck/SwiftClient", from: "2.0.0"),
        .package(name: "Alamofire", url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1")),
        .package(name: "RoberdanSecretsPackage", path: "../RoberdanSecretsPackage"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MirrorHRTelemetryPackage",
            dependencies: ["TelemetryClient", "Alamofire", "ZIPFoundation", "RoberdanSecretsPackage"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MirrorHRTelemetryPackageTests",
            dependencies: ["MirrorHRTelemetryPackage", "Alamofire"]
        )
    ]
)
