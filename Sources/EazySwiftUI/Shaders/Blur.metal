//
//  Blur.metal
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//


#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]]
half4 gaussianBlur(
    float2 position,
    SwiftUI::Layer layer,
    float radius
) {
    half4 accumulatedColor = half4(0.0);
    float totalWeight = 0.0;
    
    // Simple 3x3 Gaussian blur
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            float2 offset = float2(x, y) * radius;
            float weight = 1.0 / (1.0 + length(offset));
            
            accumulatedColor += layer.sample(position + offset) * weight;
            totalWeight += weight;
        }
    }
    
    return accumulatedColor / totalWeight;
}