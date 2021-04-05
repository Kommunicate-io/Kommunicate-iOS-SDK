// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kommunicate-iOS-SDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Kommunicate-iOS-SDK",
            targets: ["Kommunicate-iOS-SDK"]),
    ],
    dependencies: [
        .package(name: "Applozic", url: "https://github.com/AppLozic/Applozic-Chat-iOS-Framework.git", .branch("spm-test-core")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Kommunicate-iOS-SDK",
            dependencies: [],
            path: "Example/Kommunicate"
        ),
        .testTarget(
            name: "Kommunicate-iOS-SDKTests",
            dependencies: ["Kommunicate-iOS-SDK"],
            path: "Example/Tests"
        ),
    ]
)
