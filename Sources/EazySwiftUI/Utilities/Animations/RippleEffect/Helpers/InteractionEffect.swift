//
//  InteractionEffect.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI
// MARK: - Interaction Effect Types

/// Defines visual effects that respond to user interaction.
public enum InteractionEffect<T: Equatable> where T: Sendable {

    case triggered(TriggeredEffect<T>)

    case `static`(StaticEffect)

}

// Triggered effects (need T parameter)
public enum TriggeredEffect<T: Equatable> where T: Sendable {

    /// A press effect that scales content on interaction.
    /// - Parameter trigger: A value that triggers the animation when it changes.
    case press(trigger: T)

    /// A ripple distortion effect emanating from a specific point.
    /// - Parameters:
    ///   - origin: The center point of the ripple in normalized coordinates (0-1).
    ///   - trigger: A value that triggers the animation when it changes.
    case ripple(origin: CGPoint, trigger: T)
}


// Static effects (no T parameter)
public enum StaticEffect {

    /// A pixelation effect that creates a retro, blocky appearance.
    /// - Parameter pixelSize: The size of each pixel block in points.
    case pixellate(pixelSize: CGFloat)

    /// A chroma key (green screen) effect that removes a specific color.
    /// - Parameters:
    ///   - keyColor: The color to make transparent.
    ///   - threshold: The color matching sensitivity (0.0-1.0).
    case chromaKey(keyColor: Color, threshold: CGFloat = 0.1)

    /// A blur effect that softens the content.
    /// - Parameter intensity: The blur strength (0.0-10.0).
    case blur(intensity: CGFloat)
}
