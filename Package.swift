// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-elevenlabs",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "ElevenLabs", targets: ["ElevenLabs"]),
        .executable(name: "ElevenLabsCmd", targets: ["ElevenLabsCmd"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", branch: "main"),
        .package(url: "https://github.com/nathanborror/swift-shared-kit", branch: "main"),
    ],
    targets: [
        .target(name: "ElevenLabs", dependencies: [
            .product(name: "SharedKit", package: "swift-shared-kit"),
        ]),
        .executableTarget(name: "ElevenLabsCmd", dependencies: [
            "ElevenLabs",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "SharedKit", package: "swift-shared-kit"),
        ]),
        .testTarget(name: "ElevenLabsTests", dependencies: ["ElevenLabs"]),
    ]
)
