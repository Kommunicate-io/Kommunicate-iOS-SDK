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
    //a97bd3ede123f281f4b913cbe1c3fff9cc634a20
    dependencies: [
//        .package(name: "KommunicateChatUI-iOS-SDK", url: "https://github.com/Kommunicate-io/KommunicateChatUI-iOS-SDK.git", from: "1.0.0"),
        .package(url:"https://github.com/Sathyan-KM/KommunicateChatUI-iOS-SDK.git",.revisionItem("a97bd3ede123f281f4b913cbe1c3fff9cc634a20"))
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
