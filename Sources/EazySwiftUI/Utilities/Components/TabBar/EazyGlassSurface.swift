//
//  EazyGlassSurface.swift
//  EazySwiftUI
//

import SwiftUI

/// Groups glass shapes so they can blend and morph into each other.
///
/// Falls back to a plain passthrough on systems without Liquid Glass.
struct EazyGlassContainer<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) {
                content
            }
        } else {
            content
        }
    }
}

extension View {
    /// Applies a Liquid Glass background, falling back to a material capsule on
    /// systems that predate it.
    ///
    /// - Parameters:
    ///   - shape: The shape the surface is clipped to.
    ///   - tint: An optional tint blended into the glass.
    ///   - isInteractive: Whether the glass reacts to touches.
    ///   - morphID: An identity shared across states so the surface morphs
    ///     instead of cross-fading. Requires `namespace`.
    ///   - namespace: The namespace `morphID` is resolved in.
    @ViewBuilder
    func eazyGlassSurface(
        in shape: some Shape,
        tint: Color? = nil,
        isInteractive: Bool = false,
        morphID: String? = nil,
        namespace: Namespace.ID? = nil
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            eazyLiquidGlassSurface(
                in: shape,
                tint: tint,
                isInteractive: isInteractive,
                morphID: morphID,
                namespace: namespace
            )
        } else {
            background {
                shape
                    .fill(.ultraThinMaterial)
                    .overlay(shape.fill(tint?.opacity(0.28) ?? .clear))
                    .overlay(shape.stroke(Color.primary.opacity(0.08), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.14), radius: 12, y: 4)
            }
        }
    }

    @available(iOS 26.0, macOS 26.0, *)
    @ViewBuilder
    fileprivate func eazyLiquidGlassSurface(
        in shape: some Shape,
        tint: Color?,
        isInteractive: Bool,
        morphID: String?,
        namespace: Namespace.ID?
    ) -> some View {
        let glass = Glass.regular
            .tint(tint)
            .interactive(isInteractive)

        if let morphID, let namespace {
            glassEffect(glass, in: shape)
                .glassEffectID(morphID, in: namespace)
        } else {
            glassEffect(glass, in: shape)
        }
    }
}
