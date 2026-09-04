//
//  EazyLiquidGlass.swift
//  EazySwiftUI
//

import SwiftUI

// MARK: - Shape

/// One rounded rectangle of a liquid glass surface, in the coordinate space of
/// the view the surface is attached to.
///
/// A capsule is a rounded rectangle whose radius is half its height, and a
/// circle is a square one, so a single description covers every shape the
/// surface needs.
public struct EazyLiquidGlassShape: Equatable, Sendable, Animatable {
    /// The rectangle the shape occupies.
    public var frame: CGRect
    /// The corner radius, clamped by the shader to half the shorter side.
    public var cornerRadius: CGFloat

    public init(frame: CGRect, cornerRadius: CGFloat) {
        self.frame = frame
        self.cornerRadius = cornerRadius
    }

    /// A shape whose corners are fully rounded.
    public static func capsule(_ frame: CGRect) -> Self {
        Self(frame: frame, cornerRadius: min(frame.width, frame.height) / 2)
    }

    /// An absent shape. The surface skips it instead of drawing a point.
    public static let none = Self(frame: .zero, cornerRadius: 0)

    public var animatableData: AnimatablePair<CGRect.AnimatableData, CGFloat> {
        get { AnimatablePair(frame.animatableData, cornerRadius) }
        set {
            frame.animatableData = newValue.first
            cornerRadius = newValue.second
        }
    }

    /// The shape packed the way the shader reads it: centre and half size.
    fileprivate var packed: (x: CGFloat, y: CGFloat, halfWidth: CGFloat, halfHeight: CGFloat) {
        (frame.midX, frame.midY, max(frame.width, 0) / 2, max(frame.height, 0) / 2)
    }
}

// MARK: - Style

/// How a liquid glass surface is lit and blurred.
public struct EazyLiquidGlassStyle: Sendable {
    /// The blurred material behind the surface.
    public var material: Material
    /// An optional color blended into the material.
    public var tint: Color?
    /// How strongly the tint is applied.
    public var tintOpacity: Double
    /// How strongly the gradient that gives the surface structure is drawn.
    public var structureIntensity: Double
    /// A dark layer drawn behind the surface.
    ///
    /// The Human Interface Guidelines ask for one behind clear glass over
    /// bright content, at around 35% opacity, so foreground elements stay
    /// legible. Regular glass adjusts luminosity itself and needs none.
    public var dimming: Double
    /// How far apart two shapes start to merge, in points.
    public var smoothing: CGFloat
    /// The depth of the lit bevel at the edge of the surface, in points.
    public var highlightThickness: CGFloat
    /// The brightness of the specular highlight.
    public var highlightIntensity: Double
    /// Where the light sits above the surface.
    public var light: UnitPoint
    /// How high the light sits. Lower values graze the surface.
    public var lightElevation: Double
    /// The color of the drop shadow.
    public var shadowColor: Color
    /// The radius of the drop shadow.
    public var shadowRadius: CGFloat
    /// The vertical offset of the drop shadow.
    public var shadowOffset: CGFloat

    public init(
        material: Material = .ultraThinMaterial,
        tint: Color? = nil,
        tintOpacity: Double = 0.18,
        structureIntensity: Double = 0.35,
        dimming: Double = 0,
        smoothing: CGFloat = 14,
        highlightThickness: CGFloat = 5,
        highlightIntensity: Double = 0.6,
        light: UnitPoint = .init(x: 0.32, y: -0.1),
        lightElevation: Double = 0.42,
        shadowColor: Color = .black.opacity(0.16),
        shadowRadius: CGFloat = 14,
        shadowOffset: CGFloat = 5
    ) {
        self.material = material
        self.tint = tint
        self.tintOpacity = tintOpacity
        self.structureIntensity = structureIntensity
        self.dimming = dimming
        self.smoothing = smoothing
        self.highlightThickness = highlightThickness
        self.highlightIntensity = highlightIntensity
        self.light = light
        self.lightElevation = lightElevation
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
    }

    /// The default surface: blurred, and bright enough to read controls against
    /// whatever passes underneath.
    public static let regular = EazyLiquidGlassStyle()

    /// The surface the system draws a tab bar with.
    ///
    /// `UITabBar.standardAppearance` still reports `systemChromeMaterial`, but
    /// that describes the legacy blur, not what iOS 26 actually draws: sampling
    /// the two bars side by side over the same gradient, the system's glass
    /// carries the backdrop's colour through, while chrome material washes it
    /// out to near-white. So this is a thin material with the structure gradient
    /// and the bevel pulled right back - the tint under the bar has to survive.
    ///
    /// The system's platter also carries no layer shadow of its own; the shadow
    /// here is only what is needed to stand a floating capsule off a bright
    /// background.
    /// The rim is lit almost head-on rather than from above. Measured against
    /// the system bar, its edge is close to even - 21 levels of lift at the top
    /// and 17 at the bottom - where a raking light gave this one a rim that
    /// blew out to pure white on top and went dark underneath.
    public static let tabBar = EazyLiquidGlassStyle(
        material: .thinMaterial,
        // Nearly flat. Scanning down the system's bar, its glass holds one
        // luminance from top to bottom; the structure gradient was shading this
        // one by fifteen levels over the same distance, which is what made it
        // read as a lit object rather than as a sheet of glass.
        structureIntensity: 0.05,
        highlightThickness: 2.5,
        highlightIntensity: 0.07,
        light: .init(x: 0.5, y: 0.12),
        lightElevation: 0.9,
        // No shadow, which is what `_UITabBarPlatterView` reports: its layer
        // shadow opacity is zero. It also cannot be had cheaply - the glass is
        // translucent, so a shadow offset downwards shows *through* it and
        // shades everything below the top few points, which is what was tilting
        // this surface ten levels darker from top to bottom.
        shadowColor: .clear,
        shadowRadius: 0,
        shadowOffset: 0
    )

    /// A far more translucent surface, for components floating over media and
    /// other visually rich backgrounds, with the dimming layer the Human
    /// Interface Guidelines ask for in that case.
    public static let clear = EazyLiquidGlassStyle(
        structureIntensity: 0.18,
        dimming: 0.35,
        highlightThickness: 4,
        highlightIntensity: 0.8,
        shadowColor: .black.opacity(0.12),
        shadowRadius: 12,
        shadowOffset: 4
    )

    /// The light direction as the shader wants it.
    fileprivate var lightVector: (x: Double, y: Double, z: Double) {
        (Double(light.x) - 0.5, Double(light.y) - 0.5, max(lightElevation, 0.05))
    }
}

// MARK: - View modifier

public extension View {
    /// Draws a liquid glass surface behind the view.
    ///
    /// The surface is built the way a custom glass material is built rather than
    /// by adopting the system one, so it renders identically from iOS 18 and
    /// macOS 15 onwards: a blurred material masked by a signed distance field, a
    /// gradient for structure, and a specular highlight generated from the
    /// gradient of that field by a Metal shader.
    ///
    /// The surface blurs and lights what is behind it, but cannot refract it: a
    /// background layer has no access to the backdrop. To bend content the way
    /// glass does, apply ``eazyLiquidLens(_:refraction:depth:dispersion:)`` to
    /// the content itself, the way the selected tab of ``EazyMorphingTabBar``
    /// does.
    ///
    /// Both shapes are given in the coordinate space of the modified view, and
    /// merge into a single body of glass as they approach each other. Changing
    /// them inside `withAnimation` morphs the surface, because the shapes are
    /// animatable.
    ///
    /// ```swift
    /// Color.clear
    ///     .frame(width: 300, height: 80)
    ///     .eazyLiquidGlass(
    ///         .capsule(CGRect(x: 0, y: 12, width: 220, height: 56)),
    ///         merging: .capsule(CGRect(x: 240, y: 12, width: 56, height: 56))
    ///     )
    /// ```
    ///
    /// When Reduce Transparency is on, the surface drops the blur and the
    /// highlight and falls back to an opaque fill.
    func eazyLiquidGlass(
        _ primary: EazyLiquidGlassShape,
        merging secondary: EazyLiquidGlassShape = .none,
        style: EazyLiquidGlassStyle = .regular
    ) -> some View {
        modifier(
            EazyLiquidGlassModifier(
                primary: primary,
                secondary: secondary,
                style: style
            )
        )
    }
}

// MARK: - Lens

public extension View {
    /// Refracts the view through a lens, the way glass bends what sits under it.
    ///
    /// Unlike ``eazyLiquidGlass(_:merging:style:)``, which draws a surface
    /// behind the view, this samples the view itself: content near the rim of
    /// the lens is pulled inwards, and the three color channels are pulled by
    /// slightly different amounts, so the rim disperses light. Use it for an
    /// indicator that travels over content, such as the selected tab of
    /// ``EazyMorphingTabBar``.
    ///
    /// The lens is given in the coordinate space of the modified view, and is
    /// animatable, so moving it inside `withAnimation` slides the refraction
    /// across the content.
    ///
    /// - Parameters:
    ///   - lens: The shape content is refracted through.
    ///   - refraction: How far, in points, the rim pulls its sample.
    ///   - depth: How far into the lens the refraction reaches, in points.
    ///   - dispersion: How far apart the color channels are bent. Zero refracts
    ///     without dispersing.
    func eazyLiquidLens(
        _ lens: EazyLiquidGlassShape,
        refraction: CGFloat = 10,
        depth: CGFloat = 16,
        dispersion: Double = 0.12
    ) -> some View {
        modifier(
            EazyLiquidLensModifier(
                lens: lens,
                refraction: refraction,
                depth: depth,
                dispersion: dispersion
            )
        )
    }
}

private struct EazyLiquidLensModifier: ViewModifier, Animatable {
    var lens: EazyLiquidGlassShape
    var refraction: CGFloat
    var depth: CGFloat
    var dispersion: Double

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    nonisolated var animatableData: EazyLiquidGlassShape.AnimatableData {
        get { lens.animatableData }
        set { lens.animatableData = newValue }
    }

    func body(content: Content) -> some View {
        if reduceTransparency
            || EazyLiquidGlassShaders.library == nil
            || min(lens.frame.width, lens.frame.height) <= 0 {
            content
        } else {
            content.layerEffect(
                EazyLiquidGlassShaders.lens(
                    lens,
                    refraction: refraction,
                    depth: depth,
                    dispersion: dispersion
                ),
                maxSampleOffset: CGSize(
                    width: refraction * 2,
                    height: refraction * 2
                )
            )
        }
    }
}

private struct EazyLiquidGlassModifier: ViewModifier, Animatable {
    var primary: EazyLiquidGlassShape
    var secondary: EazyLiquidGlassShape
    var style: EazyLiquidGlassStyle

    nonisolated var animatableData: AnimatablePair<
        EazyLiquidGlassShape.AnimatableData,
        EazyLiquidGlassShape.AnimatableData
    > {
        get { AnimatablePair(primary.animatableData, secondary.animatableData) }
        set {
            primary.animatableData = newValue.first
            secondary.animatableData = newValue.second
        }
    }

    func body(content: Content) -> some View {
        content.background {
            EazyLiquidGlassSurface(
                primary: primary,
                secondary: secondary,
                style: style
            )
        }
    }
}

// MARK: - Surface

/// The rendered surface: blurred material, structure gradient, and specular
/// highlight, each masked by the same distance field.
private struct EazyLiquidGlassSurface: View {
    let primary: EazyLiquidGlassShape
    let secondary: EazyLiquidGlassShape
    let style: EazyLiquidGlassStyle

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        Group {
            if reduceTransparency || EazyLiquidGlassShaders.library == nil {
                EazyLiquidGlassFallbackSurface(
                    primary: primary,
                    secondary: secondary,
                    style: style,
                    isOpaque: reduceTransparency
                )
            } else {
                shadedSurface
            }
        }
        .allowsHitTesting(false)
    }

    private var shadedSurface: some View {
        ZStack {
            Rectangle()
                .fill(style.material)
                .background {
                    if style.dimming > 0 {
                        Rectangle().fill(.black.opacity(style.dimming))
                    }
                }
                .overlay {
                    if let tint = style.tint {
                        Rectangle().fill(tint.opacity(style.tintOpacity))
                    }
                }
                .overlay { EazyLiquidGlassStructureGradient(intensity: style.structureIntensity) }
                .mask {
                    Rectangle()
                        .fill(.white)
                        .colorEffect(
                            EazyLiquidGlassShaders.mask(
                                primary: primary,
                                secondary: secondary,
                                smoothing: style.smoothing
                            )
                        )
                }
                .compositingGroup()
                .shadow(
                    color: style.shadowColor,
                    radius: style.shadowRadius,
                    y: style.shadowOffset
                )

            Rectangle()
                .fill(.white)
                .colorEffect(
                    EazyLiquidGlassShaders.highlight(
                        primary: primary,
                        secondary: secondary,
                        style: style
                    )
                )
                .blendMode(.plusLighter)
        }
        .compositingGroup()
    }
}

/// The gradient that gives the material structure, brightest where the light is.
private struct EazyLiquidGlassStructureGradient: View {
    let intensity: Double

    var body: some View {
        LinearGradient(
            colors: [
                .white.opacity(0.20 * intensity),
                .white.opacity(0.04 * intensity),
                .black.opacity(0.06 * intensity)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .blendMode(.plusLighter)
    }
}

/// Used when the shader library is unavailable, or when Reduce Transparency
/// asks for a surface that does not rely on what is behind it. The two shapes
/// stay separate here: without the distance field there is nothing to merge.
private struct EazyLiquidGlassFallbackSurface: View {
    let primary: EazyLiquidGlassShape
    let secondary: EazyLiquidGlassShape
    let style: EazyLiquidGlassStyle
    let isOpaque: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            shape(primary)
            if min(secondary.frame.width, secondary.frame.height) > 0 {
                shape(secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private func shape(_ shape: EazyLiquidGlassShape) -> some View {
        let rounded = RoundedRectangle(
            cornerRadius: min(
                shape.cornerRadius,
                min(shape.frame.width, shape.frame.height) / 2
            ),
            style: .continuous
        )

        Group {
            if isOpaque {
                rounded.fill(.background)
            } else {
                rounded.fill(style.material)
            }
        }
        .overlay {
            rounded.stroke(.white.opacity(0.22), lineWidth: 0.75)
        }
        .frame(width: shape.frame.width, height: shape.frame.height)
        .offset(x: shape.frame.minX, y: shape.frame.minY)
        .shadow(color: style.shadowColor, radius: style.shadowRadius, y: style.shadowOffset)
    }
}

// MARK: - Shaders

/// Loads the precompiled liquid glass shaders and binds their arguments.
enum EazyLiquidGlassShaders {
    /// The compiled library, or `nil` when this build produced none, in which
    /// case callers draw the fallback surface.
    ///
    /// One library for the whole module, built for the destination being built
    /// for. There is no platform variant to pick: choosing between
    /// hand-compiled `-device`/`-sim`/`-macos` libraries was only ever needed
    /// because the build system was not compiling the shaders at all.
    static var library: ShaderLibrary? { EazyShaderLibrary.library }

    static func mask(
        primary: EazyLiquidGlassShape,
        secondary: EazyLiquidGlassShape,
        smoothing: CGFloat
    ) -> Shader {
        Shader(
            function: ShaderFunction(
                library: library ?? .default,
                name: "eazyLiquidGlassMask"
            ),
            arguments: shapeArguments(primary: primary, secondary: secondary)
                + [.float(smoothing)]
        )
    }

    static func highlight(
        primary: EazyLiquidGlassShape,
        secondary: EazyLiquidGlassShape,
        style: EazyLiquidGlassStyle
    ) -> Shader {
        let light = style.lightVector
        return Shader(
            function: ShaderFunction(
                library: library ?? .default,
                name: "eazyLiquidGlassHighlight"
            ),
            arguments: shapeArguments(primary: primary, secondary: secondary) + [
                .float(style.smoothing),
                .float3(light.x, light.y, light.z),
                .float(style.highlightThickness),
                .float(style.highlightIntensity)
            ]
        )
    }

    static func lens(
        _ lens: EazyLiquidGlassShape,
        refraction: CGFloat,
        depth: CGFloat,
        dispersion: Double
    ) -> Shader {
        let packed = lens.packed
        return Shader(
            function: ShaderFunction(
                library: library ?? .default,
                name: "eazyLiquidLens"
            ),
            arguments: [
                .float4(packed.x, packed.y, packed.halfWidth, packed.halfHeight),
                .float(lens.cornerRadius),
                .float(refraction),
                .float(depth),
                .float(dispersion)
            ]
        )
    }

    private static func shapeArguments(
        primary: EazyLiquidGlassShape,
        secondary: EazyLiquidGlassShape
    ) -> [Shader.Argument] {
        let first = primary.packed
        let second = secondary.packed
        return [
            .float4(first.x, first.y, first.halfWidth, first.halfHeight),
            .float4(second.x, second.y, second.halfWidth, second.halfHeight),
            .float2(primary.cornerRadius, secondary.cornerRadius)
        ]
    }
}
#if DEBUG
#Preview("Liquid Glass Surface") {
    ZStack {
        LinearGradient(
            colors: [.purple, .blue, .cyan, .mint],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ZStack {
            // Background content to make the blur/tint visible
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.18),
                            .white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 360, height: 160)
                .overlay {
                    // Subtle stripes for texture behind the glass
                    HStack(spacing: 0) {
                        ForEach(0..<16, id: \.self) { index in
                            Color.white.opacity(index.isMultiple(of: 2) ? 0.06 : 0.0)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }

            // The liquid glass surface (two shapes merging)
            Color.clear
                .frame(width: 340, height: 120)
                .eazyLiquidGlass(
                    .capsule(CGRect(x: 0, y: 16, width: 232, height: 88)),
                    merging: .capsule(CGRect(x: 244, y: 16, width: 96, height: 88)),
                    style: .tabBar
                )
        }
    }
}

#Preview("Liquid Lens") {
    ZStack {
        LinearGradient(
            colors: [.indigo, .blue, .teal, .green],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ZStack(alignment: .topLeading) {
            // Content that will be refracted by the lens
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.20),
                            .white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    VStack(spacing: 6) {
                        Text("Refraction")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                        Text("Lens bends the content")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.65))
                    }
                }
                .frame(width: 360, height: 160)
                .eazyLiquidLens(
                    .capsule(CGRect(x: 210, y: 28, width: 100, height: 50)),
                    refraction: 14,
                    depth: 24,
                    dispersion: 0.16
                )

            // Optional visual guide to show the lens position/shape
            Capsule()
                .stroke(.white.opacity(0.25), lineWidth: 1)
                .frame(width: 100, height: 80)
                .offset(x: 210, y: 28)
        }
    }
}
#endif

