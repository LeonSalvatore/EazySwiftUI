#!/bin/bash

#  compile_shaders.sh
#  EazySwiftUI - Universal Metal Shader Compiler
#
#  Created by Leon Salvatore on 22.12.2025.
#
#!/bin/bash

# Simple Metal Shader Compiler for iOS
# Creates separate .metallib files for device and simulator

SHADER_DIR="Sources/EazySwiftUI/Shaders"

# A metallib can only be loaded by a system at or above the version it was built
# for, and the Metal compiler defaults to the SDK version rather than to the
# package's deployment targets. Without these triples the libraries build
# against the newest SDK and silently fail to load on the oldest supported OS.
IOS_MIN="18.0"
MACOS_MIN="15.0"

echo "🔨 Compiling Metal shaders..."

for METAL_FILE in "$SHADER_DIR"/*.metal; do
    if [ -f "$METAL_FILE" ]; then
        FILENAME=$(basename "$METAL_FILE" .metal)
        echo "Processing $FILENAME.metal"

        # Create device version
        echo "  → iOS Device"
        xcrun -sdk iphoneos metal -target air64-apple-ios$IOS_MIN -c "$METAL_FILE" -o /tmp/"$FILENAME"-device.air
        xcrun -sdk iphoneos metallib /tmp/"$FILENAME"-device.air -o "$SHADER_DIR/$FILENAME"-device.metallib

        # Create simulator version
        echo "  → iOS Simulator"
        xcrun -sdk iphonesimulator metal -target air64-apple-ios$IOS_MIN-simulator -c "$METAL_FILE" -o /tmp/"$FILENAME"-sim.air
        xcrun -sdk iphonesimulator metallib /tmp/"$FILENAME"-sim.air -o "$SHADER_DIR/$FILENAME"-sim.metallib

        # Create macOS version
        echo "  → macOS"
        xcrun -sdk macosx metal -target air64-apple-macos$MACOS_MIN -c "$METAL_FILE" -o /tmp/"$FILENAME"-macos.air
        xcrun -sdk macosx metallib /tmp/"$FILENAME"-macos.air -o "$SHADER_DIR/$FILENAME"-macos.metallib

        # Clean up
        rm -f /tmp/"$FILENAME"-*.air

        echo "  ✅ Done: $FILENAME-device.metallib, $FILENAME-sim.metallib & $FILENAME-macos.metallib"
    fi
done

echo ""
echo "📦 To use in your package, rename files based on target:"
echo "   For iOS targets:   Ripple.metallib → Ripple-device.metallib"
echo "   For tests/simulator: Ripple.metallib → Ripple-sim.metallib"
echo ""
echo "💡 Better: Update your ShaderLibrary to load platform-specific files"
