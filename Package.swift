// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Kommunicate",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "Kommunicate",
            targets: ["Kommunicate"]
        ),
    ],
    dependencies: [
        .package(name: "KommunicateChatUI-iOS-SDK", url: "https://github.com/Kommunicate-io/KommunicateChatUI-iOS-SDK.git", .revision("5c286c2cabf022a58ee934447861b52cd0acc1d1")),
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
