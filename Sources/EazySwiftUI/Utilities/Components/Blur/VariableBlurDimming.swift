//
//  VariableBlurDimming.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 04.09.2026.
//


#if canImport(UIKit)
import SwiftUI
import UIKit

/// A color gradient placed over a variable blur to improve contrast.
///
/// Blur preserves luminance, so it cannot make every foreground legible on its
/// own. Dimming adds a tint that is strongest at the blur's anchored edge and
/// fades with the blur.
public struct VariableBlurDimming: Sendable, Equatable {
    /// The gradient tint. Usually this matches the surrounding surface.
    public var color: Color

    /// Peak opacity in light appearance.
    public var lightAlpha: CGFloat

    /// Peak opacity in dark appearance.
    public var darkAlpha: CGFloat

    /// The gradient length as a multiple of the blur view's height.
    ///
    /// Values above `1` let the tint continue after the blur has resolved,
    /// helping conceal the end of the effect.
    public var overshoot: CGFloat

    /// Creates a contrast gradient for a variable blur.
    ///
    /// Alpha values are clamped to `0...1` when rendered. Negative overshoot
    /// values render as zero.
    public init(
        color: Color,
        lightAlpha: CGFloat,
        darkAlpha: CGFloat,
        overshoot: CGFloat = 1.25
    ) {
        self.color = color
        self.lightAlpha = lightAlpha
        self.darkAlpha = darkAlpha
        self.overshoot = overshoot
    }

    /// System-background dimming suitable for navigation and action bars.
    public static let bar = VariableBlurDimming(
        color: Color(uiColor: .systemBackground),
        lightAlpha: 0.35,
        darkAlpha: 0.2
    )
}
#endif
