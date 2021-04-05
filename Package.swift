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
        .package(name: "ApplozicSwift", url: "https://github.com/AppLozic/ApplozicSwift.git", .branch("SPM-Support-changes")),
        .package(name: "Kingfisher", url: "https://github.com/onevcat/Kingfisher.git", "5.14.0" ..< "5.15.0"),
    ],
    targets: [
        .target(
            name: "Kommunicate",
            dependencies: [.product(name: "ApplozicSwift", package: "ApplozicSwift")],
            path: "Kommunicate"
        ),
    ]
)
