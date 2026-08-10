//
//  EazyShaderLibrary.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI

// MARK: - Shader Library Documentation

/// The module's Metal shaders, and the one place that resolves the library
/// they live in.
///
/// Every `.metal` file under `Sources/EazySwiftUI/Shaders` is a source of this
/// target, so the build system compiles the lot into a single
/// `default.metallib` inside the generated resource bundle. Nothing is
/// compiled by hand and nothing binary is committed: change a shader, build,
/// and the library that ships is the one you just wrote.
///
/// ## Adding a shader
/// 1. Put the `.metal` file in `Sources/EazySwiftUI/Shaders`. It needs no
///    entry in `Package.swift` - the target picks it up as a source.
/// 2. Mark the entry point `[[ stitchable ]]` and give it the signature the
///    SwiftUI modifier you intend to use requires:
///    - `.colorEffect` - `(float2 position, half4 color, …) -> half4`
///    - `.layerEffect` - `(float2 position, SwiftUI::Layer layer, …) -> half4`
///    - `.distortionEffect` - `(float2 position, …) -> float2`
///    A shader handed to the wrong one of those does not draw. There is no
///    compile-time check for it: the signature is matched at draw time.
/// 3. Add a factory here that names the function and binds its arguments.
public enum EazyShaderLibrary {

    /// The compiled library, or `nil` when this build produced none.
    ///
    /// Only `swift build` produces none - SwiftPM's own build system has no
    /// Metal rule and skips the `.metal` sources with an unhandled-file
    /// warning. Callers that can draw something without a shader should check
    /// this and fall back; the rest go through ``bundleLibrary``.
    static let library: ShaderLibrary? = {
        #if SWIFT_MODULE_RESOURCE_BUNDLE_AVAILABLE
        // Asking the bundle for the file rather than trusting
        // `ShaderLibrary.bundle` to report a miss: it has no failable form, so
        // a missing library only surfaces at draw time, as nothing drawn.
        guard Bundle.module.url(
            forResource: "default",
            withExtension: "metallib"
        ) != nil else {
            return nil
        }
        return ShaderLibrary.bundle(Bundle.module)
        #else
        return nil
        #endif
    }()

    /// The compiled library, falling back to the app's own default library.
    ///
    /// The fallback is not expected to hold these functions. It is there so
    /// the type stays non-optional for callers that have no second way to
    /// draw, and so a missing library degrades to an effect that does nothing
    /// rather than to a crash.
    public static var bundleLibrary: ShaderLibrary {
        library ?? .default
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
    public static func ripple(
        origin: CGPoint,
        time: Float,
        amplitude: Float = 0.1,
        frequency: Float = 10.0,
        decay: Float = 0.9,
        speed: Float = 2.0
    ) -> Shader {

        // Load the precompiled Metal library from the Swift Package resources
        loadShader(
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
    public static func pixellate(pixelSize: Float) -> Shader {
        loadShader(
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
    public static func chromaKey(keyColor: SIMD4<Float>, threshold: Float = 0.1) -> Shader {
        loadShader(
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
    public static func blur(intensity: Float) -> Shader {
        loadShader(
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
    public static func shake(
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

            return loadShader(
                functionName: "shakeEffect",
                arguments: [
                    .float(intensity),
                    .float(frequency),
                    .float(time),
                    .float(axisX),  // Pass as individual float
                    .float(axisY)   // Pass as individual float
                ]
            )
        }

    // MARK: - Private Helper Methods

    /// Binds a function from the compiled library.
    ///
    /// Every shader in the package lands in the same `default.metallib`, so
    /// the function name is the whole address - there is no per-shader library
    /// to pick first.
    ///
    /// - Parameters:
    ///   - functionName: The name of the Metal function within the library.
    ///   - arguments: The arguments to pass to the shader function.
    /// - Returns: A configured `Shader` instance.
    private static func loadShader(
        functionName: String,
        arguments: [Shader.Argument] = []
    ) -> Shader {

        let function = ShaderFunction(library: bundleLibrary, name: functionName)
        let shader = Shader(function: function, arguments: arguments)

        return shader
    }
}
