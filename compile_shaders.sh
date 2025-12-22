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

echo "🔨 Compiling Metal shaders..."

for METAL_FILE in "$SHADER_DIR"/*.metal; do
    if [ -f "$METAL_FILE" ]; then
        FILENAME=$(basename "$METAL_FILE" .metal)
        echo "Processing $FILENAME.metal"

        # Create device version
        echo "  → iOS Device"
        xcrun -sdk iphoneos metal -c "$METAL_FILE" -o /tmp/"$FILENAME"-device.air
        xcrun -sdk iphoneos metallib /tmp/"$FILENAME"-device.air -o "$SHADER_DIR/$FILENAME"-device.metallib

        # Create simulator version
        echo "  → iOS Simulator"
        xcrun -sdk iphonesimulator metal -c "$METAL_FILE" -o /tmp/"$FILENAME"-sim.air
        xcrun -sdk iphonesimulator metallib /tmp/"$FILENAME"-sim.air -o "$SHADER_DIR/$FILENAME"-sim.metallib

        # Clean up
        rm -f /tmp/"$FILENAME"-*.air

        echo "  ✅ Done: $FILENAME-device.metallib & $FILENAME-sim.metallib"
    fi
done

echo ""
echo "📦 To use in your package, rename files based on target:"
echo "   For iOS targets:   Ripple.metallib → Ripple-device.metallib"
echo "   For tests/simulator: Ripple.metallib → Ripple-sim.metallib"
echo ""
echo "💡 Better: Update your ShaderLibrary to load platform-specific files"
