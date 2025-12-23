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
        case let .shake(trigger, config: config):
            self.modifier(ShakeEffectViewModifier(trigger: trigger, config: config))
        case let .spring(trigger, config: config):
            self.modifier(SpringShakeEffectViewModifier(trigger: trigger, config: config))

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
}
