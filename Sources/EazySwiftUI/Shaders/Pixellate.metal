//
//  Pixellate.metal
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//


#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]]
half4 pixellateEffect(
    float2 position,
    SwiftUI::Layer layer,
    float pixelSize
) {
    // Round position to nearest pixel grid
    float2 pixelatedPosition = floor(position / pixelSize) * pixelSize;

    // Sample color at pixelated position
    return layer.sample(pixelatedPosition);
}
