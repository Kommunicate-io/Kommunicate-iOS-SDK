// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Kommunicate",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Kommunicate",
            targets: ["Kommunicate"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kommunicate-io/KommunicateChatUI-iOS-SDK.git", .branch("sanity/1.2.2")),
    ],
    targets: [
        .target(
            name: "Kommunicate",
            dependencies: [.product(name: "KommunicateChatUI-iOS-SDK", package: "KommunicateChatUI-iOS-SDK")],
            path: "Sources",
            resources: [.process("Resources")]
        ),
    ]
)
