// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EazySwiftUI",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EazySwiftUI",
            targets: ["EazySwiftUI"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EazySwiftUI",
            resources: [
                .process("Shaders")
                // Optional: Include Metal source files for debugging
            ],
            // Optional: Add Metal compiler flags
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "EazySwiftUITests",
            dependencies: ["EazySwiftUI"]
        ),
    ]
)

// MARK: - Swift Package Manager Configuration Template

/*
// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "YourPackageName",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "YourPackageName",
            targets: ["YourPackageName"]
        ),
    ],
    targets: [
        .target(
            name: "YourPackageName",
            resources: [
                // This MUST contain the .metallib files
                .process("Shaders"),

                // Optional: Include Metal source files for debugging
                .copy("Shaders/Source")  // For development/debugging only
            ],
            // Optional: Add Metal compiler flags
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "YourPackageNameTests",
            dependencies: ["YourPackageName"]
        ),
    ]
)

// MARK: - Build Rule for Xcode Project (if not using SPM Metal compilation)

/*
In Xcode project settings, add a Build Rule for .metal files:

1. Go to Build Rules in your target
2. Add New Build Rule
3. Set Process: "Source files with names matching:" *.metal
4. Using: "Metal Compiler"
5. Output Files: $(DERIVED_FILE_DIR)/$(INPUT_FILE_BASE).air
6. Add additional step to compile .air → .metallib

Or use custom script:
xcrun metal -c ${INPUT_FILE_PATH} -o ${DERIVED_FILE_DIR}/${INPUT_FILE_BASE}.air
xcrun metallib ${DERIVED_FILE_DIR}/${INPUT_FILE_BASE}.air -o ${METAL_LIBRARY_OUTPUT_DIR}/${INPUT_FILE_BASE}.metallib
*/
*/
