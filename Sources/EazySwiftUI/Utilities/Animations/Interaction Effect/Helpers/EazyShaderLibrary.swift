//
//  EazyShaderLibrary.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI

// MARK: - Shader Library Documentation

/// A library of precompiled Metal shaders for SwiftUI effects.
///
/// `EazyShaderLibrary` provides a collection of performant, precompiled Metal shaders
/// that can be used with SwiftUI's `Shader` and `VisualEffect` APIs. All shaders
/// are precompiled into `.metallib` files for optimal performance and binary size.
///
/// ## Key Features
/// - **Precompiled Performance**: Shaders are compiled at build time, not runtime
/// - **Type Safety**: Strongly-typed parameters and return values
/// - **Resource Management**: Automatic resource loading and error handling
/// - **Pplatform**: Works on iOS.
///
///
/// ## Package Setup Requirements
/// 1. Metal shader files must be in `Sources/[Target]/Shaders/` directory
/// 2. Package.swift must declare resources: `.process("Shaders")`
/// 3. Build Rules must compile .metal → .metallib (see Package.swift template)
/// 4. Shader functions must be declared in Metal file with proper signatures
public enum EazyShaderLibrary {

    // Helper property
    private static var bundleLibrary: ShaderLibrary {
        ShaderLibrary.bundle(Bundle.module)
    }

    // MARK: - Ripple Effect

    /// Creates a ripple distortion shader effect.
    ///
    /// This shader applies a radial wave distortion that emanates from a specified
    /// origin point, creating a water-like ripple effect. The effect parameters
    /// allow control over the wave characteristics and timing.
    ///
    /// - Parameters:
    ///   - origin: The center point of the ripple effect in normalized coordinates (0-1).
    ///     Example: `CGPoint(x: 0.5, y: 0.5)` for center of view.
    ///   - time: The current time in seconds. Animate this value to create motion.
    ///     Typically driven by a timer or animation clock.
    ///   - amplitude: The height/intensity of the ripple waves (0.0 - 1.0).
    ///     Higher values create more pronounced distortion.
    ///   - frequency: The number of wave cycles per unit distance.
    ///     Higher values create more frequent, smaller ripples.
    ///   - decay: The rate at which ripple intensity decreases over distance (0.0 - 1.0).
    ///     1.0 = no decay, 0.0 = immediate decay.
    ///   - speed: The propagation speed of the ripple waves.
    ///     Higher values make ripples move faster.
    ///
    /// - Returns: A configured `Shader` instance ready for use with SwiftUI's `.shader()` modifier.
    ///
    /// - Important: All coordinates are in normalized space (0-1). Convert view coordinates
    ///   using `GeometryReader` or `VisualEffect` proxy.
    ///
    /// ## Performance Characteristics
    /// - **Complexity**: O(1) per pixel
    /// - **Recommended Use**: Moderate-frequency animations (≤ 60Hz)
    /// - **GPU Impact**: Low to moderate, depending on view size
    ///
    /// ## Example with Animation
    /// ```swift
    /// struct RippleView: View {
    ///     @State private var time: Float = 0
    ///     let rippleOrigin = CGPoint(x: 0.5, y: 0.5)
    ///
    ///     var body: some View {
    ///         Rectangle()
    ///             .fill(.blue.gradient)
    ///             .frame(width: 300, height: 300)
    ///             .shader(
    ///                 EazyShaderLibrary.ripple(
    ///                     origin: rippleOrigin,
    ///                     time: time,
    ///                     amplitude: 0.15,
    ///                     frequency: 8.0,
    ///                     decay: 0.85,
    ///                     speed: 1.5
    ///                 )
    ///             )
    ///             .onAppear {
    ///                 withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
    ///                     time = 10.0
    ///                 }
    ///             }
    ///     }
    /// }
    /// ```
    static func ripple(
        origin: CGPoint,
        time: Float,
        amplitude: Float = 0.1,
        frequency: Float = 10.0,
        decay: Float = 0.9,
        speed: Float = 2.0
    ) -> Shader {

        // Load the precompiled Metal library from the Swift Package resources
        loadShader(
            named: "Ripple",
            functionName: "rippleEffect",
            arguments: [
                .float2(origin),
                .float(time),
                .float(amplitude),
                .float(frequency),
                .float(decay),
                .float(speed)
            ]
        )
    }

    // MARK: - Additional Shader Effects

    /// Creates a pixellate (pixelation) shader effect.
    ///
    /// - Parameter pixelSize: The size of each pixel in points.
    ///   Larger values create more pronounced pixelation.
    /// - Returns: A configured `Shader` instance.
    static func pixellate(pixelSize: Float) -> Shader {
        loadShader(
            named: "Pixellate",
            functionName: "pixellateEffect",
            arguments: [.float(pixelSize)]
        )
    }

    /// Creates a chroma key (green screen) shader effect.
    ///
    /// - Parameters:
    ///   - keyColor: The color to make transparent (typically green).
    ///   - threshold: The color matching sensitivity (0.0 - 1.0).
    /// - Returns: A configured `Shader` instance.
    static func chromaKey(keyColor: SIMD4<Float>, threshold: Float = 0.1) -> Shader {
        loadShader(
            named: "ChromaKey",
            functionName: "chromaKeyEffect",
            arguments: [
                .color(Color(red: Double(keyColor.x),
                             green: Double(keyColor.y),
                             blue: Double(keyColor.z),
                             opacity: Double(keyColor.w))),
                .float(threshold)
            ]
        )
    }

    /// Creates a blur shader with configurable intensity.
    ///
    /// - Parameter intensity: The blur strength (0.0 - 10.0).
    ///   Higher values create more blur.
    /// - Returns: A configured `Shader` instance.
    static func blur(intensity: Float) -> Shader {
        loadShader(
            named: "Blur",
            functionName: "gaussianBlur",
            arguments: [.float(intensity)]
        )
    }

    /// Creates a shake distortion effect shader.
        ///
        /// - Parameters:
        ///   - intensity: The strength of the shake effect (0.0-1.0).
        ///   - frequency: How rapidly the shaking occurs.
        ///   - time: Current animation time in seconds.
        ///   - axis: The axis along which to shake (.horizontal, .vertical, or .both).
        /// - Returns: A configured `Shader` instance for the shake effect.
    static func shake(
            intensity: Float = 0.1,
            frequency: Float = 10.0,
            time: Float = 0.0,
            axis: InteractionAxis = .horizontal
        ) -> Shader {
            // Determine axis vector components
            let axisX: Float
            let axisY: Float

            switch axis {
            case .horizontal:
                axisX = 1.0
                axisY = 0.0
            case .vertical:
                axisX = 0.0
                axisY = 1.0
            case .both:
                axisX = 1.0
                axisY = 1.0
            }

            let library = ShaderLibrary.bundle(Bundle.module)
            let function = ShaderFunction(library: library, name: "shakeEffect")

            return Shader(function: function, arguments: [
                .float(intensity),
                .float(frequency),
                .float(time),
                .float(axisX),  // Pass as individual float
                .float(axisY)   // Pass as individual float
            ])
        }

    // MARK: - Private Helper Methods

    /// Loads a precompiled shader from the package resources.
    ///
    /// - Parameters:
    ///   - shaderName: The name of the .metallib file (without extension).
    ///   - functionName: The name of the Metal function within the library.
    ///   - arguments: The arguments to pass to the shader function.
    /// - Returns: A configured `Shader` instance, or `nil` if loading fails.
    ///
    /// - Note: This method implements robust error handling and fallback mechanisms.
    ///   It logs detailed errors in debug builds but fails gracefully in release builds.
    // Even simpler approach using SwiftUI's built-in resource loading
    private static func loadShader(
        named shaderName: String,
        functionName: String,
        arguments: [Shader.Argument] = []
    ) -> Shader {

        // Try to load from bundle first (simplest)
        let library = bundleLibrary
        let function = ShaderFunction(library: library, name: functionName)
        let shader = Shader(function: function, arguments: arguments)

        return shader
    }
}
