//
//  VariableBlur.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 04.09.2026.
//


#if canImport(UIKit)
import SwiftUI
import UIKit

/// A backdrop that ramps from full blur at one edge to clear at the other.
///
/// A uniform blur band can leave a visible line where it ends. `VariableBlur`
/// instead drives Core Animation's variable blur filter with a generated alpha
/// mask, allowing the backdrop to resolve gradually into the content behind it.
///
/// SwiftUI's `blur(radius:)` and layer effects operate on a view's own rendered
/// layer. This component uses a `UIVisualEffectView` because a backdrop effect
/// must sample content behind the view. If the variable filter is unavailable,
/// it falls back to ``fallbackStyle``.
///
/// ```swift
/// content.safeAreaInset(edge: .top) {
///     header.background {
///         VariableBlur(edge: .top, maxRadius: 4)
///             .ignoresSafeArea(edges: .top)
///     }
/// }
/// ```
///
/// `VariableBlur` is available on UIKit platforms and does not intercept input
/// or appear in the accessibility tree.
public struct VariableBlur: View {
    /// The edge held at full blur radius.
    public var edge: VariableBlurEdge

    /// The blur radius at the anchored edge, in backdrop pixels.
    ///
    /// The backdrop is downsampled, so useful values are generally smaller
    /// than radii passed to SwiftUI's `blur(radius:)`. Negative values render
    /// as zero.
    public var maxRadius: CGFloat

    /// The fraction of the view, measured from ``edge``, held at
    /// ``maxRadius`` before the ramp begins.
    ///
    /// Values are clamped to `0...1` when rendered. A value of `0` ramps across
    /// the whole view; `1` produces a uniform blur.
    public var plateau: CGFloat

    /// The contrast gradient, or `nil` for blur alone.
    public var dimming: VariableBlurDimming?

    /// The material used when the variable blur filter is unavailable.
    public var fallbackStyle: UIBlurEffect.Style

    /// Creates a variable backdrop blur.
    ///
    /// - Parameters:
    ///   - edge: The edge where the blur reaches its full radius.
    ///   - maxRadius: The blur radius at the anchored edge.
    ///   - plateau: The fraction held at full radius before fading.
    ///   - dimming: An optional contrast gradient over the blur.
    ///   - fallbackStyle: The material used when variable blur is unavailable.
    public init(
        edge: VariableBlurEdge = .top,
        maxRadius: CGFloat = 4,
        plateau: CGFloat = 0,
        dimming: VariableBlurDimming? = .bar,
        fallbackStyle: UIBlurEffect.Style = .systemUltraThinMaterial
    ) {
        self.edge = edge
        self.maxRadius = maxRadius
        self.plateau = plateau
        self.dimming = dimming
        self.fallbackStyle = fallbackStyle
    }

    public var body: some View {
        Representable(
            edge: edge,
            maxRadius: maxRadius,
            plateau: plateau,
            dimming: dimming,
            fallbackStyle: fallbackStyle
        )
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private extension VariableBlur {
    struct Representable: UIViewRepresentable {
        let edge: VariableBlurEdge
        let maxRadius: CGFloat
        let plateau: CGFloat
        let dimming: VariableBlurDimming?
        let fallbackStyle: UIBlurEffect.Style

        func makeUIView(context: Context) -> VariableBlurBackdropView {
            VariableBlurBackdropView()
        }

        func updateUIView(_ view: VariableBlurBackdropView, context: Context) {
            view.configure(
                edge: edge,
                maxRadius: maxRadius,
                plateau: plateau,
                dimmingColor: dimming.map { UIColor($0.color) },
                dimmingLightAlpha: dimming?.lightAlpha ?? 0,
                dimmingDarkAlpha: dimming?.darkAlpha ?? 0,
                dimmingOvershoot: dimming?.overshoot ?? 1,
                fallbackStyle: fallbackStyle
            )
        }
    }
}
#endif
