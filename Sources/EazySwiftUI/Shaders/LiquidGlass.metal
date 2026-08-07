//
//  LiquidGlass.metal
//  EazySwiftUI
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace eazy_liquid_glass {

/// Signed distance to a rounded box centred on the origin.
static float roundedBoxDistance(float2 point, float2 halfSize, float radius) {
    float r = clamp(radius, 0.0, min(halfSize.x, halfSize.y));
    float2 q = abs(point) - halfSize + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

/// Quadratic polynomial smooth minimum.
///
/// Blending two fields instead of taking their minimum is what grows a liquid
/// neck between the shapes as they approach each other, and what lets one shape
/// absorb the other rather than clip through it.
static float smoothUnion(float a, float b, float k) {
    if (k <= 0.001) {
        return min(a, b);
    }
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

/// The distance field for the whole surface.
///
/// Each shape is packed as (centreX, centreY, halfWidth, halfHeight) in the
/// user-space coordinates of the view the effect is applied to. A shape with a
/// non-positive half size is treated as absent.
static float surfaceDistance(
    float2 point,
    float4 primary,
    float4 secondary,
    float2 radii,
    float smoothing
) {
    float distance = roundedBoxDistance(point - primary.xy, primary.zw, radii.x);
    if (min(secondary.z, secondary.w) <= 0.0) {
        return distance;
    }
    float other = roundedBoxDistance(point - secondary.xy, secondary.zw, radii.y);
    return smoothUnion(distance, other, smoothing);
}

}

/// Refracts the content a lens travels over.
///
/// Sampling is pulled inwards along the outward normal of the shape, hardest at
/// the rim and not at all past `depth`. That is what bends content around the
/// edge of a lens instead of simply magnifying it. Red, green, and blue are bent
/// by slightly different amounts, so the rim disperses light the way real glass
/// does.
[[ stitchable ]]
half4 eazyLiquidLens(
    float2 position,
    SwiftUI::Layer layer,
    float4 lens,
    float radius,
    float amount,
    float depth,
    float dispersion
) {
    float2 local = position - lens.xy;
    float distance = eazy_liquid_glass::roundedBoxDistance(local, lens.zw, radius);
    if (distance > 0.0) {
        return layer.sample(position);
    }

    float2 gradient = float2(
        eazy_liquid_glass::roundedBoxDistance(local + float2(1.0, 0.0), lens.zw, radius)
            - eazy_liquid_glass::roundedBoxDistance(local - float2(1.0, 0.0), lens.zw, radius),
        eazy_liquid_glass::roundedBoxDistance(local + float2(0.0, 1.0), lens.zw, radius)
            - eazy_liquid_glass::roundedBoxDistance(local - float2(0.0, 1.0), lens.zw, radius)
    );
    float gradientLength = length(gradient);
    if (gradientLength <= 0.0001) {
        return layer.sample(position);
    }
    float2 outward = gradient / gradientLength;

    float edge = 1.0 - smoothstep(0.0, max(depth, 0.001), -distance);
    float bend = edge * edge * amount;
    if (bend <= 0.0) {
        return layer.sample(position);
    }

    half4 green = layer.sample(position - outward * bend);
    if (dispersion <= 0.0) {
        return green;
    }

    half4 red = layer.sample(position - outward * bend * (1.0 + dispersion));
    half4 blue = layer.sample(position - outward * bend * (1.0 - dispersion));
    return half4(red.r, green.g, blue.b, green.a);
}

/// Fills the distance field so the result can mask the blurred material that
/// sits behind the surface.
[[ stitchable ]]
half4 eazyLiquidGlassMask(
    float2 position,
    half4 color,
    float4 primary,
    float4 secondary,
    float2 radii,
    float smoothing
) {
    float distance = eazy_liquid_glass::surfaceDistance(
        position, primary, secondary, radii, smoothing
    );
    float coverage = saturate(0.5 - distance);
    return color * half(coverage);
}

/// Lights the surface.
///
/// The gradient of the distance field is used as a normal map, and a single
/// light source above the plane produces the specular rim that reads as glass.
/// The backdrop is never sampled, so the surface adds no refraction: dense
/// interfaces stay readable through it.
[[ stitchable ]]
half4 eazyLiquidGlassHighlight(
    float2 position,
    half4 color,
    float4 primary,
    float4 secondary,
    float2 radii,
    float smoothing,
    float3 light,
    float thickness,
    float intensity
) {
    float distance = eazy_liquid_glass::surfaceDistance(
        position, primary, secondary, radii, smoothing
    );
    float coverage = saturate(0.5 - distance);
    if (coverage <= 0.0 || intensity <= 0.0) {
        return half4(0.0h);
    }

    // Central differences of the field give the outward normal in the plane.
    float step = 1.0;
    float right = eazy_liquid_glass::surfaceDistance(
        position + float2(step, 0.0), primary, secondary, radii, smoothing
    );
    float left = eazy_liquid_glass::surfaceDistance(
        position - float2(step, 0.0), primary, secondary, radii, smoothing
    );
    float down = eazy_liquid_glass::surfaceDistance(
        position + float2(0.0, step), primary, secondary, radii, smoothing
    );
    float up = eazy_liquid_glass::surfaceDistance(
        position - float2(0.0, step), primary, secondary, radii, smoothing
    );

    float2 gradient = float2(right - left, down - up) * 0.5;
    float gradientLength = length(gradient);
    float2 outward = gradientLength > 0.0001
        ? gradient / gradientLength
        : float2(0.0, -1.0);

    // Zero at the rim, one at `thickness` inside: the bevel the light rolls off.
    float depth = saturate(-distance / max(thickness, 1.0));
    float3 normal = normalize(float3(outward * (1.0 - depth), depth * 0.9 + 0.1));
    float3 lightDirection = normalize(light);

    float lambert = saturate(dot(normal, lightDirection));
    float specular = pow(lambert, 24.0);

    // Energy stays concentrated in the edge band.
    float rim = 1.0 - depth;
    rim *= rim;

    float value = saturate((specular * 0.9 + lambert * rim * 0.55) * intensity) * coverage;
    return half4(color.rgb * half(value), color.a * half(value));
}
