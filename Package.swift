// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Kommunicate",
    defaultLocalization: "en",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "Kommunicate",
            targets: ["Kommunicate"]),
    ],
    dependencies: [
        .package(name: "ApplozicSwift", url: "https://github.com/AppLozic/ApplozicSwift.git", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "Kommunicate",
            dependencies: [.product(name: "ApplozicSwift", package: "ApplozicSwift")],
            path: "Kommunicate",
            resources: [.process("Kommunicate/Assets")]
        ),
    ]
)
