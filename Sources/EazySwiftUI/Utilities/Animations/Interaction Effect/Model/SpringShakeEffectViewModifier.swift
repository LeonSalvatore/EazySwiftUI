//
//  SpringShakeEffectViewModifier.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 23.12.2025.
//

import SwiftUI

struct SpringShakeEffectViewModifier<T: Equatable>: ViewModifier where T: Sendable {
    
    let trigger: T
    let config: SpringEffectConfig

    @State private var shakeOffset: CGFloat = 0
    @State private var isAnimating = false
    
    init(trigger: T,config: SpringEffectConfig = .default) {
        self.trigger = trigger
        self.config = config
    }
    
    func body(content: Content) -> some View {
        content
            .sensoryFeedback(config.sensoryFeedback ?? .warning, trigger: trigger)
            .offset(
                x: config.axis == .horizontal || config.axis == .both ? shakeOffset : 0,
                y: config.axis == .vertical || config.axis == .both ? shakeOffset : 0
            )
            .onChange(of: trigger) { oldValue, newValue in
                performSpringShake()
            }
    }
    
    private func performSpringShake() {
        guard !isAnimating else { return }
        
        isAnimating = true
        
        // Spring-based shake animation
        withAnimation(.interpolatingSpring(
            mass: 0.5,
            stiffness: 200,
            damping: 5,
            initialVelocity: 10
        )) {
            shakeOffset = config.intensity
        }
        
        // Oscillations
        for i in 1...config.oscillations {
            let delay = Double(i) * 0.1
            let direction = i % 2 == 0 ? config.intensity : -config.intensity

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.interpolatingSpring(
                    mass: 0.5,
                    stiffness: 200,
                    damping: 5,
                    initialVelocity: 5
                )) {
                    shakeOffset = direction * (1.0 - CGFloat(i) / CGFloat(config.oscillations))
                }
            }
        }
        
        // Return to original position
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(config.oscillations + 1) * 0.1) {
            withAnimation(.easeOut(duration: 0.2)) {
                shakeOffset = 0
            } completion: {
                isAnimating = false
            }
        }
    }
}

public struct SpringEffectConfig: Sendable {

    public var intensity: CGFloat
    public var oscillations: Int
    public var axis: InteractionAxis
    public var sensoryFeedback: SensoryFeedback?

    init(intensity: CGFloat = 10.0,
         oscillations: Int = 3,
         axis: InteractionAxis = .horizontal,
         sensoryFeedback: SensoryFeedback? = nil) {
        self.intensity = intensity
        self.oscillations = oscillations
        self.axis = axis
    }

    public static var `default`: SpringEffectConfig {
        return .init()
    }
}

#Preview("Simple Spring Shake Effect") {

    @Previewable @State var isActive = false

     VStack(spacing: 20) {
        Button("Shake Button") {
            isActive.toggle()
        }
        .buttonStyle(.borderedProminent)
        .interactionEffect(.spring(isActive))

        TextField("Shake on error", text: .constant(""))
            .textFieldStyle(.roundedBorder)
            .interactionEffect(.spring(isActive, config: .init(axis: .vertical)))

        Toggle("Shake Toggle", isOn: $isActive)
             .interactionEffect(.spring(isActive))
    }
    .padding()
}
