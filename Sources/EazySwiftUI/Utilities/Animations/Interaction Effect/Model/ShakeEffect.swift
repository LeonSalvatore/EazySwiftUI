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
    let config: ShakeEffectConfig

    @State private var animationTime: Float = 0.0
    @State private var isAnimating = false
    
    init(
        trigger: T,
        config: ShakeEffectConfig = .secondary) {
        self.trigger = trigger
        self.config = config
    }
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        EazyShaderLibrary.shake(
                            intensity: Float(config.intensity / 100.0), // Convert to 0-1 range
                            frequency: Float(config.frequency),
                            time: animationTime,
                            axis: config.axis
                        ),
                        maxSampleOffset: .init(
                            width: config.intensity * 2,
                            height: config.intensity * 2
                        )
                    )
            }
            .sensoryFeedback(config.sensoryFeedback ?? .warning, trigger: trigger)
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
        withAnimation(.easeOut(duration: config.duration)) {
            animationTime = Float(config.duration)
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

public struct ShakeEffectConfig: Sendable {

    public var intensity: CGFloat
    public var frequency: CGFloat
    public var duration: TimeInterval
    public var axis: InteractionAxis
    public var sensoryFeedback: SensoryFeedback?

    public init(
        intensity: CGFloat = .zero,
        frequency: CGFloat = .zero,
        duration: TimeInterval = .zero,
        axis: InteractionAxis = .horizontal,
        sensoryFeedback: SensoryFeedback? = nil
    ) {

            self.intensity = intensity
            self.frequency = frequency
            self.duration = duration
            self.axis = axis
        }
    public static var `default`: ShakeEffectConfig {
        .init(intensity: 15.0, frequency: 20.0, duration: 0.6, axis: .horizontal)
    }

    public static var secondary: ShakeEffectConfig {
        .init(intensity: 10.0, frequency: 15.0, duration: 0.5, axis: .horizontal)
    }
}


// MARK: - Preview

#Preview("Metal Shake Effect") {
    struct ShakePreview: View {
        @State private var shakeTrigger = 0
        @State private var config: ShakeEffectConfig = .secondary

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

                    Text("Intensity: \(config.intensity, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 200, height: 150)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .interactionEffect(.shake(shakeTrigger, config: .default))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)

                // Controls
                VStack(spacing: 20) {
                    Button("Trigger Shake") {
                        shakeTrigger += 1
                    }
                    .buttonStyle(.borderedProminent)

                    // Axis picker
                    Picker("Axis", selection: $config.axis) {
                        Text("Horizontal").tag(InteractionAxis.horizontal)
                        Text("Vertical").tag(InteractionAxis.vertical)
                        Text("Both").tag(InteractionAxis.both)
                    }
                    .pickerStyle(.segmented)

                    // Intensity slider
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Intensity: \(config.intensity, specifier: "%.1f")")
                            .font(.caption)

                        Slider(value: $config.intensity, in: 1...30, step: 0.5)
                    }

                    // Frequency slider
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Frequency: \(config.frequency, specifier: "%.1f")")
                            .font(.caption)

                        Slider(value: $config.frequency, in: 5...50, step: 1)
                    }

                    // Duration slider
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration: \(config.duration, specifier: "%.2f")s")
                            .font(.caption)

                        Slider(value: $config.duration, in: 0.1...2.0, step: 0.1)
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
                            .interactionEffect(.spring(shakeTrigger))

                        Text("Invalid input feedback")
                            .font(.caption)
                    }

                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.orange)
                            .interactionEffect(.shake(shakeTrigger, config: .init(axis: .vertical)))

                        Text("Warning notification")
                            .font(.caption)
                    }

                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.blue)
                            .interactionEffect(.spring(shakeTrigger, config: .init(oscillations:2)))

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

public enum InteractionAxis: Sendable {
    case horizontal
    case vertical
    case both
}
