//
//  ViewExtensions.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI

public extension View {
    /// Applies an interactive visual effect to the view.
    ///
    /// Use this modifier to add dynamic, interactive effects that respond to
    /// user input or state changes. Each effect type has its own parameters
    /// and behavior.
    ///
    /// - Parameter effect: The interaction effect to apply.
    /// - Returns: A view modified with the specified effect.
    ///
    /// ## Usage Examples
    /// ```swift
    /// // Ripple effect triggered by a tap
    /// Button("Tap me") { isTapped.toggle() }
    ///     .interactionEffect(.ripple(origin: .init(x: 0.5, y: 0.5),
    ///                                trigger: isTapped))
    ///
    /// // Static pixelation effect
    /// Image("secret")
    ///     .interactionEffect(.pixellate(pixelSize: 8))
    ///
    /// // Chroma key for green screen removal
    /// VideoPlayer(player: player)
    ///     .interactionEffect(.chromaKey(keyColor: .green, threshold: 0.15))
    /// ```

    // For triggered effects
    @ViewBuilder
    func interactionEffect<T: Equatable>(
        _ effect: TriggeredEffect<T>
    ) -> some View where T: Sendable {
        switch effect {
        case let .press(trigger):
            self.modifier(PushEffect(trigger: trigger))
        case let .ripple(origin, trigger):
            self.modifier(RippleEffect(at: origin, trigger: trigger))
        }
    }

    // For static effects
    @ViewBuilder
    func interactionEffect(
        _ effect: StaticEffect
    ) -> some View {
        switch effect {
        case let .pixellate(pixelSize):
            self.modifier(PixellateEffect(pixelSize: pixelSize))
        case let .chromaKey(keyColor, threshold):
            self.modifier(ChromaKeyEffect(keyColor: keyColor, threshold: threshold))
        case let .blur(intensity):
            self.modifier(BlurEffect(intensity: intensity))
        }
    }

    /// Applies a shake effect using Metal shaders for high-performance animation.
        ///
        /// - Parameters:
        ///   - trigger: A value that triggers the shake animation when it changes.
        ///   - intensity: The strength of the shake (default: 10.0).
        ///   - frequency: How rapidly the shaking occurs (default: 15.0).
        ///   - duration: Total animation duration in seconds (default: 0.5).
        ///   - axis: The axis along which to shake (default: .horizontal).
        /// - Returns: A view with the shake effect applied.
        @ViewBuilder
        func shakeEffect<T: Equatable>(
            _ trigger: T,
            intensity: CGFloat = 10.0,
            frequency: CGFloat = 15.0,
            duration: TimeInterval = 0.5,
            axis: InteractionAxis = .horizontal
        ) -> some View where T: Sendable {

            modifier(ShakeEffectViewModifier(
                trigger: trigger,
                intensity: intensity,
                frequency: frequency,
                duration: duration,
                axis: axis
            ))

        }

        /// Applies a spring-based shake effect (works on all iOS versions).
        @ViewBuilder
        func springShakeEffect<T: Equatable>(
            _ trigger: T,
            intensity: CGFloat = 10.0,
            oscillations: Int = 3,
            axis: InteractionAxis = .horizontal
        ) -> some View  where T: Sendable {
            modifier(SpringShakeEffectViewModifier(
                trigger: trigger,
                intensity: intensity,
                oscillations: oscillations,
                axis: axis
            ))
        } 

}
