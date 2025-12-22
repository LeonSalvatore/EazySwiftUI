//
//  ChromaKey.metal
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//


#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]]
half4 chromaKeyEffect(
    float2 position,
    SwiftUI::Layer layer,
    half3 keyColor,    // Color to remove (e.g., green)
    float threshold    // Sensitivity (0.0-1.0)
) {
    half4 color = layer.sample(position);

    // Calculate color difference
    half3 diff = abs(color.rgb - keyColor);
    float difference = length(diff);

    // If color is similar to key color, make it transparent
    if (difference < threshold) {
        return half4(0.0, 0.0, 0.0, 0.0); // Transparent
    }

    return color;
}
