// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedPkg",
    platforms: [.iOS(.v16), .watchOS(.v8)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SharedPkg",
            targets: ["SharedPkg"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "RoberdanToolBox", path: "../RoberdanToolbox"),
        .package(name: "PermissionsManager", path: "../PermissionsManager"),
        .package(name: "XlsxReaderWriter", url: "https://github.com/charlymr/XlsxReaderWriter", from: "2.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SharedPkg",
            dependencies: ["RoberdanToolBox", "XlsxReaderWriter", "PermissionsManager"]
        )
    ]
)
