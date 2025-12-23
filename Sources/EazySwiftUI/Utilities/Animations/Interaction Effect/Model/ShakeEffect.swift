//
//  ShakeEffectViewModifier.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 23.12.2025.
//

import SwiftUI

// MARK: - Shake Effect View Modifier

struct ShakeEffectViewModifier<T: Equatable>: ViewModifier where T: Sendable {
    
    let trigger: T
    let intensity: CGFloat
    let frequency: CGFloat
    let duration: TimeInterval
    let axis: InteractionAxis

    @State private var animationTime: Float = 0.0
    @State private var isAnimating = false
    
    init(
        trigger: T,
        intensity: CGFloat = 10.0,
        frequency: CGFloat = 15.0,
        duration: TimeInterval = 0.5,
        axis: InteractionAxis = .horizontal
    ) {
        self.trigger = trigger
        self.intensity = intensity
        self.frequency = frequency
        self.duration = duration
        self.axis = axis
    }
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        EazyShaderLibrary.shake(
                            intensity: Float(intensity / 100.0), // Convert to 0-1 range
                            frequency: Float(frequency),
                            time: animationTime,
                            axis: axis
                        ),
                        maxSampleOffset: .init(
                            width: intensity * 2,
                            height: intensity * 2
                        )
                    )
            }
            .onChange(of: trigger) { oldValue, newValue in
                startShakeAnimation()
            }
            .onAppear {
                // Optional: auto-shake on appear for preview/testing
                #if DEBUG
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        startShakeAnimation()
                    }
                }
                #endif
            }
    }
    
    private func startShakeAnimation() {
        guard !isAnimating else { return }
        
        isAnimating = true
        animationTime = 0.0
        
        // Animate the time value
        withAnimation(.easeOut(duration: duration)) {
            animationTime = Float(duration)
        } completion: {
            // Reset after animation completes
            withAnimation(.easeIn(duration: 0.1)) {
                animationTime = 0.0
            } completion: {
                isAnimating = false
            }
        }
    }
}

// MARK: - Preview

#Preview("Metal Shake Effect") {
    struct ShakePreview: View {
        @State private var shakeTrigger = 0
        @State private var intensity: CGFloat = 15.0
        @State private var frequency: CGFloat = 20.0
        @State private var duration: TimeInterval = 0.6
        @State private var selectedAxis: InteractionAxis = .horizontal

        var body: some View {
            VStack(spacing: 30) {
                // Preview card
                VStack(spacing: 15) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.orange.gradient)

                    Text("Shake Me!")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Intensity: \(intensity, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 200, height: 150)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shakeEffect(
                    shakeTrigger,
                    intensity: intensity,
                    frequency: frequency,
                    duration: duration,
                    axis: selectedAxis
                )
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)

                // Controls
                VStack(spacing: 20) {
                    Button("Trigger Shake") {
                        shakeTrigger += 1
                    }
                    .buttonStyle(.borderedProminent)

                    // Axis picker
                    Picker("Axis", selection: $selectedAxis) {
                        Text("Horizontal").tag(InteractionAxis.horizontal)
                        Text("Vertical").tag(InteractionAxis.vertical)
                        Text("Both").tag(InteractionAxis.both)
                    }
                    .pickerStyle(.segmented)

                    // Intensity slider
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Intensity: \(intensity, specifier: "%.1f")")
                            .font(.caption)

                        Slider(value: $intensity, in: 1...30, step: 0.5)
                    }

                    // Frequency slider
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Frequency: \(frequency, specifier: "%.1f")")
                            .font(.caption)

                        Slider(value: $frequency, in: 5...50, step: 1)
                    }

                    // Duration slider
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration: \(duration, specifier: "%.2f")s")
                            .font(.caption)

                        Slider(value: $duration, in: 0.1...2.0, step: 0.1)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Example use cases
                VStack(alignment: .leading, spacing: 10) {
                    Text("Use Cases:")
                        .font(.headline)

                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .springShakeEffect(shakeTrigger, axis: .horizontal)

                        Text("Invalid input feedback")
                            .font(.caption)
                    }

                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .shakeEffect(shakeTrigger, axis: .vertical)

                        Text("Warning notification")
                            .font(.caption)
                    }

                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.blue)
                            .springShakeEffect(shakeTrigger, oscillations: 2)

                        Text("Button press feedback")
                            .font(.caption)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    return ShakePreview()
}

#Preview("Simple Spring Shake Effect") {

    @Previewable @State var isActive = false

     VStack(spacing: 20) {
        Button("Shake Button") {
            isActive.toggle()
        }
        .buttonStyle(.borderedProminent)
        .springShakeEffect(isActive)

        TextField("Shake on error", text: .constant(""))
            .textFieldStyle(.roundedBorder)
            .springShakeEffect(isActive, intensity: 5)

        Toggle("Shake Toggle", isOn: $isActive)
            .springShakeEffect(isActive, axis: .vertical)
    }
    .padding()
}

public enum InteractionAxis {
    case horizontal
    case vertical
    case both
}
