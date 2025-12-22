//
//  RippleModifier.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI

/// A low-level modifier that applies a shader-driven ripple distortion to a view.
///
/// `RippleModifier` uses a custom Metal shader to simulate a wave distortion
/// that expands from a given origin point and decays over time.
struct RippleModifier: ViewModifier {

    /// Origin point of the ripple in local coordinates.
    var origin: CGPoint

    /// Elapsed time since the animation started.
    var elapsedTime: TimeInterval

    /// Total duration of the ripple animation.
    var duration: TimeInterval

    /// Controls the height of the ripple waves.
    var amplitude: Double = 12

    /// Controls the density of the ripple waves.
    var frequency: Double = 15

    /// Controls how quickly the ripple dissipates.
    var decay: Double = 8

    /// Controls the speed at which the ripple propagates.
    var speed: Double = 1200

    func body(content: Content) -> some View {

        let shader = EazyShaderLibrary
            .ripple(
            origin: origin,
            time: Float(elapsedTime),
            amplitude: Float(amplitude),
            frequency: Float(frequency),
            decay: Float(decay),
            speed: Float(speed)
        )

//        let shader = ShaderLibrary.Ripple(
//            .float2(origin),
//            .float(elapsedTime),
//            .float(amplitude),
//            .float(frequency),
//            .float(decay),
//            .float(speed)
//        )

        let maxSampleOffset = maxSampleOffset
        let elapsedTime = elapsedTime
        let duration = duration

        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset: maxSampleOffset,
                isEnabled: 0 < elapsedTime && elapsedTime < duration
            )
        }
    }

    /// Maximum sampling offset required by the shader.
    var maxSampleOffset: CGSize {
        CGSize(width: amplitude, height: amplitude)
    }
}

public extension View {

    /// Registers a spatial pressing gesture and reports the press location as it changes.
    ///
    /// The provided closure receives the current press location when the gesture begins
    /// and `nil` when the gesture ends or is cancelled.
    ///
    /// - Parameter action: A closure receiving the current press location or `nil`.
    func onPressingChanged(_ action: @escaping (CGPoint?) -> Void) -> some View {
        modifier(SpatialPressingGestureModifier(action: action))
    }
}

