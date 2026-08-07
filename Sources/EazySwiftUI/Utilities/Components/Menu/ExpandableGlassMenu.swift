//
//  ExpandableGlassMenu.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 07.08.2026.
//


import SwiftUI

/// A compact Liquid Glass control that morphs between a label and custom menu content.
///
/// Drive `progress` from `0` for the collapsed label to `1` for the expanded
/// content. Values between the two states are supported, which makes the menu
/// suitable for interactive controls as well as animation.
///
/// ```swift
/// @State private var isExpanded = false
///
/// ExpandableGlassMenu(
///     alignment: .topLeading,
///     progress: isExpanded ? 1 : 0
/// ) {
///     VStack(alignment: .leading) {
///         Button("Send", systemImage: "paperplane") { }
///         Button("Receive", systemImage: "arrow.down") { }
///     }
///     .padding()
/// } label: {
///     Button("Open menu", systemImage: "plus") {
///         withAnimation(.bouncy(duration: 0.75, extraBounce: 0.02)) {
///             isExpanded.toggle()
///         }
///     }
///     .labelStyle(.iconOnly)
/// }
/// ```
public struct ExpandableGlassMenu<Content: View, Label: View>: View, @preconcurrency Animatable {
    private var alignment: Alignment
    private var progress: CGFloat
    private var labelSize: CGSize
    private var cornerRadius: CGFloat
    private var content: Content
    private var label: Label

    @State private var contentSize: CGSize = .zero

    /// Creates an expandable Liquid Glass menu.
    ///
    /// - Parameters:
    ///   - alignment: The shared edge from which the label grows into the menu.
    ///   - progress: The expansion progress, where `0` shows the label and `1`
    ///     shows the content.
    ///   - labelSize: The collapsed size of the control.
    ///   - cornerRadius: The corner radius of the glass surface.
    ///   - content: The content shown in the expanded state.
    ///   - label: The content shown in the collapsed state.
    public init(
        alignment: Alignment,
        progress: CGFloat,
        labelSize: CGSize = CGSize(width: 55, height: 55),
        cornerRadius: CGFloat = 30,
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Label
    ) {
        self.alignment = alignment
        self.progress = progress
        self.labelSize = labelSize
        self.cornerRadius = cornerRadius
        self.content = content()
        self.label = label()
    }

    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    public var body: some View {
        ZStack(alignment: alignment) {
            let widthDifference = contentSize.width - labelSize.width
            let heightDifference = contentSize.height - labelSize.height

            content
                .compositingGroup()
                .scaleEffect(contentScale)
                .blur(radius: 14 * blurProgress)
                .opacity(contentOpacity)
                .allowsHitTesting(progress >= 1)
                .accessibilityHidden(progress < 1)
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newValue in
                    contentSize = newValue
                }
                .fixedSize()
                .frame(
                    width: labelSize.width + widthDifference * contentOpacity,
                    height: labelSize.height + heightDifference * contentOpacity
                )

            label
                .compositingGroup()
                .blur(radius: 14 * blurProgress)
                .opacity(1 - labelOpacity)
                .frame(width: labelSize.width, height: labelSize.height)
                .allowsHitTesting(progress <= 0)
                .accessibilityHidden(progress > 0)
        }
        .compositingGroup()
        .clipShape(.rect(cornerRadius: cornerRadius))
        .eazyGlassSurface(
            in: .rect(cornerRadius: cornerRadius),
            isInteractive: true
        )
        .scaleEffect(
            x: 1 - blurProgress * 0.35,
            y: 1 + blurProgress * 0.45,
            anchor: scaleAnchor
        )
        .offset(y: offset * blurProgress)
    }

    private var labelOpacity: CGFloat {
        min(progress / 0.35, 1)
    }

    private var contentOpacity: CGFloat {
        max(progress - 0.35, 0) / 0.65
    }

    private var blurProgress: CGFloat {
        progress > 0.5 ? (1 - progress) / 0.5 : progress / 0.5
    }

    private var contentScale: CGFloat {
        guard contentSize.width > 0, contentSize.height > 0 else { return 1 }
        let minimumScale = min(
            labelSize.width / contentSize.width,
            labelSize.height / contentSize.height
        )
        return minimumScale + (1 - minimumScale) * progress
    }

    /// Converts the menu alignment into the anchor used while morphing.
    private var scaleAnchor: UnitPoint {
        switch alignment {
        case .bottomLeading: .bottomLeading
        case .bottom: .bottom
        case .bottomTrailing: .bottomTrailing
        case .topLeading: .topLeading
        case .top: .top
        case .topTrailing: .topTrailing
        case .leading: .leading
        case .trailing: .trailing
        default: .center
        }
    }

    private var offset: CGFloat {
        switch alignment {
        case .bottom, .bottomLeading, .bottomTrailing: -75
        case .top, .topLeading, .topTrailing: 75
        default: 0
        }
    }
}
