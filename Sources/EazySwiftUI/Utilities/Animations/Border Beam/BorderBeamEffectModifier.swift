//
//  BorderBeamEffectModifier.swift
//  EazySwiftUI
//

import SwiftUI

/// A modifier that draws an animated gradient beam around a rounded border.
public struct BorderBeamEffectModifier: ViewModifier {
    private let border: Color
    private let showsBaseBorder: Bool
    private let beam: [Color]
    private let beamBlur: CGFloat
    private let cornerRadius: CGFloat
    private let duration: Double
    private let isEnabled: Bool

    /// Creates an animated border beam modifier.
    ///
    /// - Parameters:
    ///   - border: The color of the rotating border highlight.
    ///   - showsBaseBorder: Whether to draw a subtle border beneath the beam.
    ///   - beam: The colors used by the blurred beam. An empty array falls back
    ///     to `border`.
    ///   - beamBlur: The blur radius applied to the beam.
    ///   - cornerRadius: The radius of the rounded border.
    ///   - duration: The duration of one complete rotation.
    ///   - isEnabled: Whether the border is visible and animated.
    public init(
        border: Color,
        showsBaseBorder: Bool = false,
        beam: [Color],
        beamBlur: CGFloat,
        cornerRadius: CGFloat,
        duration: Double = 2.5,
        isEnabled: Bool = true
    ) {
        self.border = border
        self.showsBaseBorder = showsBaseBorder
        self.beam = beam
        self.beamBlur = beamBlur
        self.cornerRadius = cornerRadius
        self.duration = duration
        self.isEnabled = isEnabled
    }

    public func body(content: Content) -> some View {
        content
            .background {
                BorderBeamBorder(
                    border: border,
                    showsBaseBorder: showsBaseBorder,
                    beam: beam,
                    beamBlur: beamBlur,
                    cornerRadius: cornerRadius,
                    duration: duration,
                    isEnabled: isEnabled
                )
            }
    }
}

public extension View {
    /// Draws an animated gradient beam around the view's rounded border.
    ///
    /// The beam is decorative and does not affect hit testing or accessibility.
    /// When Reduce Motion is enabled, the border remains visible without
    /// rotating.
    ///
    /// - Parameters:
    ///   - border: The color of the rotating border highlight.
    ///   - showsBaseBorder: Whether to draw a subtle border beneath the beam.
    ///   - beam: The colors used by the blurred beam. An empty array falls back
    ///     to `border`.
    ///   - beamBlur: The blur radius applied to the beam.
    ///   - cornerRadius: The radius of the rounded border.
    ///   - duration: The duration of one complete rotation.
    ///   - isEnabled: Whether the border is visible and animated.
    /// - Returns: A view with the border beam applied.
    func borderBeamEffect(
        border: Color,
        showsBaseBorder: Bool = false,
        beam: [Color],
        beamBlur: CGFloat,
        cornerRadius: CGFloat,
        duration: Double = 2.5,
        isEnabled: Bool = true
    ) -> some View {
        modifier(
            BorderBeamEffectModifier(
                border: border,
                showsBaseBorder: showsBaseBorder,
                beam: beam,
                beamBlur: beamBlur,
                cornerRadius: cornerRadius,
                duration: duration,
                isEnabled: isEnabled
            )
        )
    }
}
