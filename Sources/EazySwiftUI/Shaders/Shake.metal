//
//  Shake.metal
//  EazySwiftUI
//
//  Created by Leon Salvatore on 23.12.2025.
//

#include <metal_stdlib>
using namespace metal;

// MARK: - Shake Metal Shader File

// Create this file at: Sources/EazySwiftUI/Shaders/Shake.metal
// Then compile it with: ./compile_shaders.sh

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]]
float2 shakeEffect(
    float2 position,
    float intensity,
    float frequency,
    float time,
    float axisX,
    float axisY
) {
    // Calculate shake offset using multiple sine waves for natural feel
    float shakeX = 0.0;
    float shakeY = 0.0;

    // Primary shake wave
    float primaryWave = sin(time * frequency * 2.0) * intensity;

    // Secondary wave for more natural motion (slightly out of phase)
    float secondaryWave = sin(time * frequency * 1.7 + 1.2) * intensity * 0.6;

    // Tertiary wave for subtle variation
    float tertiaryWave = sin(time * frequency * 2.3 + 2.4) * intensity * 0.3;

    // Combine waves
    float totalShake = (primaryWave + secondaryWave + tertiaryWave) / 1.9;

    // Apply shake along specified axis
    shakeX = totalShake * axisX;
    shakeY = totalShake * axisY;

    // Add slight randomness for more organic feel
    float randomOffset = sin(position.x * 100.0 + position.y * 100.0 + time * 5.0) * intensity * 0.05;
    shakeX += randomOffset * axisX;
    shakeY += randomOffset * axisY;

    // Return shaken position
    return float2(position.x + shakeX, position.y + shakeY);
}
