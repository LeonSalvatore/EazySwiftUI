//
//  ArcProgressView.swift
//  EazySwiftUI
//

import SwiftUI

/// A configurable indeterminate progress ring.
public struct ArcProgressView: View {
    private let tint: Color
    private let size: CGFloat
    private let lineWidth: CGFloat
    private let trim: ClosedRange<CGFloat>
    private let duration: TimeInterval
    private let label: LocalizedStringResource?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotation: Double = 0

    public init(
        tint: Color = .accentColor,
        size: CGFloat = 18,
        lineWidth: CGFloat = 2,
        trim: ClosedRange<CGFloat> = 0...0.72,
        duration: TimeInterval = 1.1,
        label: LocalizedStringResource? = nil
    ) {
        self.tint = tint
        self.size = max(size, 0)
        self.lineWidth = max(lineWidth, 0)
        self.trim = min(max(trim.lowerBound, 0), 1)...min(max(trim.upperBound, 0), 1)
        self.duration = max(duration, 0.01)
        self.label = label
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.14), lineWidth: lineWidth)

            Circle()
                .trim(from: trim.lowerBound, to: trim.upperBound)
                .stroke(
                    AngularGradient(
                        colors: [tint, tint.opacity(0.72), tint.opacity(0)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(rotation - 90))
        }
        .frame(width: size, height: size)
        .accessibilityElement()
        .accessibilityLabel(label.map(Text.init) ?? Text("Loading"))
        .accessibilityAddTraits(.updatesFrequently)
        .onAppear(perform: updateAnimation)
        .onChange(of: reduceMotion) { _, _ in updateAnimation() }
        .onDisappear {
            withAnimation(.none) {
                rotation = 0
            }
        }
    }

    private func updateAnimation() {
        rotation = 0
        guard !reduceMotion else { return }
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
}

public extension View {
    /// Presents an application-defined blocking view above the entire app when
    /// installed below an `EazyOverlayHost`.
    func eazyBlockingOverlay<Overlay: View>(
        isPresented: Bool,
        scrim: Color = .black.opacity(0.45),
        @ViewBuilder overlay: @escaping () -> Overlay
    ) -> some View {
        modifier(
            EazyBlockingOverlayModifier(
                isPresented: isPresented,
                scrim: scrim,
                overlay: overlay
            )
        )
    }
}

private struct EazyBlockingOverlayModifier<Overlay: View>: ViewModifier {
    let isPresented: Bool
    let scrim: Color
    let overlay: () -> Overlay

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.eazyOverlay(
            animation: reduceMotion ? .linear(duration: 0) : .easeInOut(duration: 0.22),
            alignment: .center,
            isPresented: Binding(get: { isPresented }, set: { _ in })
        ) {
            if isPresented {
                ZStack {
                    scrim
                    overlay()
                        .transition(
                            reduceMotion
                                ? .opacity
                                : .scale(scale: 0.88).combined(with: .opacity)
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
    }
}
