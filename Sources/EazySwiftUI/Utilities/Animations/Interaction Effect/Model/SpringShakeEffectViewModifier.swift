//
//  SpringShakeEffectViewModifier.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 23.12.2025.
//

import SwiftUI

struct SpringShakeEffectViewModifier<T: Equatable>: ViewModifier where T: Sendable {
    
    let trigger: T
    let intensity: CGFloat
    let oscillations: Int
    let axis: InteractionAxis

    @State private var shakeOffset: CGFloat = 0
    @State private var isAnimating = false
    
    init(
        trigger: T,
        intensity: CGFloat = 10.0,
        oscillations: Int = 3,
        axis: InteractionAxis = .horizontal
    ) {
        self.trigger = trigger
        self.intensity = intensity
        self.oscillations = oscillations
        self.axis = axis
    }
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: axis == .horizontal || axis == .both ? shakeOffset : 0,
                y: axis == .vertical || axis == .both ? shakeOffset : 0
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
            shakeOffset = intensity
        }
        
        // Oscillations
        for i in 1...oscillations {
            let delay = Double(i) * 0.1
            let direction = i % 2 == 0 ? intensity : -intensity
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.interpolatingSpring(
                    mass: 0.5,
                    stiffness: 200,
                    damping: 5,
                    initialVelocity: 5
                )) {
                    shakeOffset = direction * (1.0 - CGFloat(i) / CGFloat(oscillations))
                }
            }
        }
        
        // Return to original position
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(oscillations + 1) * 0.1) {
            withAnimation(.easeOut(duration: 0.2)) {
                shakeOffset = 0
            } completion: {
                isAnimating = false
            }
        }
    }
}
