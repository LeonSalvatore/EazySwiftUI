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
        // `Sources/EazySwiftUI/Shaders/*.metal` are sources, not resources.
        //
        // Xcode's build system runs the Metal compiler over a package target's
        // `.metal` sources and links the result into `default.metallib` inside
        // this target's generated resource bundle, which is where
        // `ShaderLibrary.bundle(.module)` looks. Excluding them and shipping
        // hand-compiled `.metallib` files instead is what left the bundle with
        // no `default.metallib` at all, so every effect that resolved through
        // it silently drew nothing.
        //
        // `swift build` is the one build that does not compile them: SwiftPM's
        // own build system has no Metal rule, so it reports them as unhandled
        // files and skips them. That is only a warning, and the shaders are
        // unreachable from a command-line build regardless - see
        // ``EazyShaderLibrary/library``, which resolves to `nil` there.
        .target(
            name: "EazySwiftUI",
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
