// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EazySwiftUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "EazySwiftUI",
            targets: ["EazySwiftUI"]
        )
    ],
    targets: [
        .target(
            name: "EazySwiftUI",
            exclude: [
                "Shaders/Blur.metal",
                "Shaders/ChromaKey.metal",
                "Shaders/Pixellate.metal",
                "Shaders/Ripple.metal",
                "Shaders/Shake.metal"
            ],
            resources: [
                .process("Shaders")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "EazySwiftUITests",
            dependencies: ["EazySwiftUI"]
        )
    ]
)
