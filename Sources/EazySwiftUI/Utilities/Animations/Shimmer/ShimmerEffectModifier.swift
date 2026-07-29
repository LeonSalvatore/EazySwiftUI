//
//  ShimmerEffectModifier.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 29.07.2026.
//

import SwiftUI

/// The direction in which a shimmer highlight moves across a view.
public enum ShimmerDirection: Sendable {
    case leadingToTrailing
    case trailingToLeading
    case topToBottom
    case bottomToTop
}

public extension View {
    /// Adds an animated shimmer effect to the view.
    ///
    /// - Parameters:
    ///   - isActive: Whether the shimmer animation is active.
    ///   - color: The base color used to fill the view shape.
    ///   - highlight: The moving highlight color.
    ///   - blur: The blur applied to the moving highlight.
    ///   - duration: The time it takes the highlight to cross the view once.
    ///   - direction: The direction of the moving highlight.
    ///   - blendMode: The blend mode used by the highlight.
    /// - Returns: A view modified with an animated shimmer effect.
    @ViewBuilder
    func shimmer(
        isActive: Bool = true,
        color: Color = .gray.opacity(0.35),
        highlight: Color = .white.opacity(0.75),
        blur: CGFloat = 0,
        duration: TimeInterval = 1.5,
        direction: ShimmerDirection = .leadingToTrailing,
        blendMode: BlendMode = .normal
    ) -> some View {
        modifier(
            ShimmerEffectModifier(
                isActive: isActive,
                color: color,
                highlight: highlight,
                blur: blur,
                duration: duration,
                direction: direction,
                blendMode: blendMode
            )
        )
    }
}

/// A view modifier that adds an animated shimmer effect to a view.
struct ShimmerEffectModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: CGFloat = -1

    var isActive: Bool
    var color: Color
    var highlight: Color
    var blur: CGFloat
    var duration: TimeInterval
    var direction: ShimmerDirection
    var blendMode: BlendMode

    func body(content: Content) -> some View {
        if isActive, !reduceMotion {
            content
                .hidden()
                .overlay {
                    shimmerContent(mask: content)
                }
                .onAppear(perform: startAnimation)
                .onChange(of: isActive, initial: false) { _, isActive in
                    if isActive {
                        startAnimation()
                    }
                }
        } else if isActive {
            content
                .hidden()
                .overlay {
                    Rectangle()
                        .fill(color)
                        .mask { content }
                }
        } else {
            content
        }
    }

    private func shimmerContent(mask content: Content) -> some View {
        Rectangle()
            .fill(color)
            .mask { content }
            .overlay {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(highlight)
                        .mask {
                            highlightMask(in: proxy.size)
                        }
                        .blendMode(blendMode)
                }
                .mask { content }
            }
    }

    private func highlightMask(in size: CGSize) -> some View {
        Rectangle()
            .fill(
                .linearGradient(
                    colors: [
                        .white.opacity(0),
                        .white,
                        .white.opacity(0)
                    ],
                    startPoint: gradientStartPoint,
                    endPoint: gradientEndPoint
                )
            )
            .blur(radius: blur)
            .scaleEffect(x: direction.isHorizontal ? 0.35 : 1, y: direction.isHorizontal ? 1 : 0.35)
            .offset(offset(for: size))
    }

    private func startAnimation() {
        progress = -1

        withAnimation(.linear(duration: max(duration, 0.01)).repeatForever(autoreverses: false)) {
            progress = 1
        }
    }

    private func offset(for size: CGSize) -> CGSize {
        let horizontalDistance = size.width + blur * 2
        let verticalDistance = size.height + blur * 2

        switch direction {
        case .leadingToTrailing:
            return CGSize(width: horizontalDistance * progress, height: 0)
        case .trailingToLeading:
            return CGSize(width: -horizontalDistance * progress, height: 0)
        case .topToBottom:
            return CGSize(width: 0, height: verticalDistance * progress)
        case .bottomToTop:
            return CGSize(width: 0, height: -verticalDistance * progress)
        }
    }

    private var gradientStartPoint: UnitPoint {
        direction.isHorizontal ? .leading : .top
    }

    private var gradientEndPoint: UnitPoint {
        direction.isHorizontal ? .trailing : .bottom
    }
}

private extension ShimmerDirection {
    var isHorizontal: Bool {
        switch self {
        case .leadingToTrailing, .trailingToLeading:
            return true
        case .topToBottom, .bottomToTop:
            return false
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Shimmer Effect")
                    .font(.title)
                    .shimmer(color: .blue, highlight: .cyan)

                ForEach(0..<3) { _ in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))

                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 50)
                    }
                    .shimmer()
                }
            }
            .padding()
            .navigationTitle("Shimmer Effect")
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .preferredColorScheme(.dark)
        }
    }
}
