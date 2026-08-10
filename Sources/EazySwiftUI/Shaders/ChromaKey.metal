//
//  ChromaKey.metal
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//


#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

// `keyColor` is half4 and not half3 because a `Shader.Argument.color` is bound
// as a half4. Declaring three components made every argument after it read the
// wrong bytes, threshold included.
[[ stitchable ]]
half4 chromaKeyEffect(
    float2 position,
    SwiftUI::Layer layer,
    half4 keyColor,    // Color to remove (e.g., green)
    float threshold    // Sensitivity (0.0-1.0)
) {
    half4 color = layer.sample(position);

    // Calculate color difference
    half3 diff = abs(color.rgb - keyColor.rgb);
    float difference = length(diff);

    // If color is similar to key color, make it transparent
    if (difference < threshold) {
        return half4(0.0, 0.0, 0.0, 0.0); // Transparent
    }

    return color;
}
