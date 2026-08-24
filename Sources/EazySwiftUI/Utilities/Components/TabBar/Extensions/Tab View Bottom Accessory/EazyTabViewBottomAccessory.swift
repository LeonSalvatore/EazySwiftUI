//
//  EazyTabViewBottomAccessory.swift
//  EazySwiftUI
//

import SwiftUI

// MARK: - The accessory, on its way to the tab view

/// An accessory handed to an ``EazyTabView`` to lay out.
///
/// The accessory is declared *outside* the tab view — `EazyTabView { … }
/// .eazyTabViewBottomAccessory { … }` — but has to be drawn *inside* it, in the
/// same coordinate space as the bar it sits above. Environment is the only
/// thing that travels that way, so the modifier puts the accessory in the
/// environment and the tab view takes it out again.
///
/// This is the system's contract too: `tabViewBottomAccessory` draws nothing
/// without a `TabView` to draw it in.
public struct EazyTabViewBottomAccessoryConfiguration {
    /// Whether the accessory is showing.
    public var isEnabled: Bool
    /// The placement asked for, or `nil` to follow the tab bar — which is what
    /// almost every accessory wants.
    public var placement: EazyTabViewBottomAccessoryPlacement?
    /// The measurements the accessory lays itself out with.
    public var metrics: EazyTabViewBottomAccessoryMetrics
    /// How the accessory's glass is lit and blurred.
    public var style: EazyLiquidGlassStyle
    /// How the accessory moves between placements, and arrives and leaves.
    public var animation: Animation
    /// The caller's content.
    public var content: AnyView

    public init(
        isEnabled: Bool,
        placement: EazyTabViewBottomAccessoryPlacement?,
        metrics: EazyTabViewBottomAccessoryMetrics,
        style: EazyLiquidGlassStyle,
        animation: Animation,
        content: AnyView
    ) {
        self.isEnabled = isEnabled
        self.placement = placement
        self.metrics = metrics
        self.style = style
        self.animation = animation
        self.content = content
    }
}

// MARK: - Environment

public extension EnvironmentValues {
    /// Where the enclosing bottom accessory is placed, and `nil` where there is
    /// no accessory at all.
    ///
    /// Published into the accessory's own content, which is the only place it
    /// has anything to say. Read it to give the accessory two arrangements the
    /// way the system's does — a full transport above the bar, a title and a
    /// play button beside it.
    ///
    /// Mirrors `EnvironmentValues.tabViewBottomAccessoryPlacement`, including
    /// its optionality.
    @Entry var eazyTabViewBottomAccessoryPlacement: EazyTabViewBottomAccessoryPlacement?

    /// The accessory the enclosing ``EazyTabView`` should draw, on its way down
    /// to it. `nil` where no accessory has been declared.
    @Entry var eazyTabViewBottomAccessory: EazyTabViewBottomAccessoryConfiguration?
}

// MARK: - Modifier

public extension View {

    /// Places a view as the bottom accessory of the tab view. Use
    /// this modifier to dynamically show and hide the accessory view.
    ///
    /// On iPhone, the placement of the bottom accessory depends on the tab bar
    /// size: when the tab bar is normal size, the accessory appears above
    /// it; when the tab bar is collapsed, the accessory displays inline.
    /// Use the ``SwiftUICore/EnvironmentValues/eazyTabViewBottomAccessoryPlacement``
    /// environment value to adjust the accessory's content based on its
    /// placement.
    ///
    /// ```swift
    /// EazyTabView(tabs: tabs, selection: $selection) { tab in
    ///     content(for: tab)
    /// }
    /// .eazyTabBarMinimizeBehavior(.onScrollDown)
    /// .eazyTabViewBottomAccessory { NowPlayingBar() }
    /// ```
    ///
    /// Apply it to an ``EazyTabView``, which is what draws it — as
    /// `tabViewBottomAccessory` needs a `TabView`. The accessory is declared
    /// out here and drawn in there, so that it can be laid out in the same
    /// coordinate space as the bar it sits eight points above, and can go and
    /// sit beside that bar when it collapses.
    ///
    /// With ``SwiftUICore/View/eazyTabBarMinimizeBehavior(_:)`` in play the
    /// placement looks after itself: the accessory goes
    /// ``EazyTabViewBottomAccessoryPlacement/inline`` when the bar collapses
    /// and back to ``EazyTabViewBottomAccessoryPlacement/expanded`` when it
    /// returns. Pass `placement` only to override that.
    ///
    /// - Parameters:
    ///   - isEnabled: If true, the bottom accessory is shown; otherwise,
    ///     the bottom accessory is hidden.
    ///   - placement: Where the accessory sits, or `nil` to follow the tab bar.
    ///   - metrics: The measurements the accessory lays itself out with.
    ///   - style: How the accessory's glass is lit and blurred. Defaults to the
    ///     tab bar's, so the two surfaces read as one material.
    ///   - animation: How the accessory moves between placements, and how it
    ///     arrives and leaves. Ignored when Reduce Motion is on.
    ///   - content: The content view of the tab view accessory.
    func eazyTabViewBottomAccessory<Content: View>(
        isEnabled: Bool = true,
        placement: EazyTabViewBottomAccessoryPlacement? = nil,
        metrics: EazyTabViewBottomAccessoryMetrics = .standard,
        style: EazyLiquidGlassStyle = .tabBar,
        animation: Animation = .spring(duration: 0.4, bounce: 0.15),
        @ViewBuilder content: () -> Content
    ) -> some View {
        environment(
            \.eazyTabViewBottomAccessory,
            EazyTabViewBottomAccessoryConfiguration(
                isEnabled: isEnabled,
                placement: placement,
                metrics: metrics,
                style: style,
                animation: animation,
                content: AnyView(content())
            )
        )
    }
}

// MARK: - Host

/// Draws the accessory in the room the tab view has kept for it.
///
/// Bottom-aligned against that room, whose bottom edge is the tab bar's top
/// edge: expanded, the accessory clears the bar by the gap; inline, it drops
/// out of the room entirely and onto the bar's own row. Nothing clips it on the
/// way, so the drop needs no room reserved for it.
struct EazyTabViewBottomAccessoryHost: View {
    let accessory: EazyTabViewBottomAccessoryConfiguration?
    let placement: EazyTabViewBottomAccessoryPlacement?

    /// What the accessory's content actually measures, which is the metric
    /// height until a text size larger than the accessory grows it.
    @State private var measuredHeight: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if let accessory, accessory.isEnabled, let placement {
                EazyTabViewBottomAccessorySurface(
                    placement: placement,
                    metrics: resolved(accessory.metrics),
                    style: accessory.style,
                    measuredHeight: $measuredHeight,
                    accessory: accessory.content
                )
                .transition(
                    .opacity.combined(
                        with: .offset(y: resolved(accessory.metrics).reservedHeight)
                    )
                )
            }
        }
        .animation(animation, value: placement)
        .animation(animation, value: accessory?.isEnabled ?? false)
    }

    private var animation: Animation? {
        guard !reduceMotion else { return nil }
        return accessory?.animation
    }

    /// The metrics with the accessory's height replaced by what its content
    /// measures, once that is the larger of the two.
    ///
    /// Everything the layout needs is derived from the height, so resolving it
    /// here is enough to keep an accessory grown by Dynamic Type landing on the
    /// bar's centre inline.
    private func resolved(
        _ metrics: EazyTabViewBottomAccessoryMetrics
    ) -> EazyTabViewBottomAccessoryMetrics {
        var resolved = metrics
        resolved.height = max(measuredHeight, metrics.height)
        return resolved
    }
}

/// The accessory itself: a capsule of glass, and the caller's content in it.
private struct EazyTabViewBottomAccessorySurface<Accessory: View>: View {
    let placement: EazyTabViewBottomAccessoryPlacement
    let metrics: EazyTabViewBottomAccessoryMetrics
    let style: EazyLiquidGlassStyle
    @Binding var measuredHeight: CGFloat
    let accessory: Accessory

    var body: some View {
        placed
            // An exact height, not a minimum. The height the accessory takes is
            // settled by the measurement below, from what the content *wants*;
            // letting the visible copy set it too would hand the height to
            // content that merely accepts whatever it is offered, and a single
            // `Spacer` or `maxHeight: .infinity` would grow the accessory over
            // the whole screen.
            .frame(maxWidth: .infinity)
            .frame(height: metrics.height)
            .background { EazyTabViewBottomAccessoryGlass(style: style) }
            .contentShape(.capsule)
            .background(alignment: .bottom) {
                EazyTabViewBottomAccessoryMeasure(height: $measuredHeight) {
                    placed
                }
            }
            .padding(.leading, metrics.leadingInset(for: placement))
            .padding(.trailing, metrics.trailingInset(for: placement))
            // The gap to the tab bar. The bar's top edge is this view's bottom
            // edge, so the gap is simply padding — see the note on the modifier
            // about the caller's own `safeAreaInset` spacing, which is the one
            // thing that can put a second gap here.
            .padding(.bottom, metrics.spacing)
            // Expanded this is nothing; inline it carries the accessory down
            // out of its own row and onto the bar's.
            .offset(y: metrics.drop(for: placement))
            .accessibilityElement(children: .contain)
    }

    /// The caller's content, told where it is.
    ///
    /// Both the visible accessory and the hidden measurement render it, and
    /// they have to render the *same* thing: content that shows a subtitle only
    /// when expanded is a different height in each placement, and measuring the
    /// wrong one would size the accessory for the arrangement it is not in.
    private var placed: some View {
        accessory
            .environment(\.eazyTabViewBottomAccessoryPlacement, placement)
    }
}

/// Lays the accessory's content out at the height it actually wants, out of
/// sight, and reports it.
///
/// This is what lets the accessory stay 48 points tall for ordinary content and
/// grow for content set at an accessibility text size, without letting content
/// that simply expands to fill whatever it is offered decide the height.
/// `fixedSize(horizontal:vertical:)` is the whole trick: the width stays the
/// accessory's, so text is measured where it will actually wrap, while the
/// height becomes the ideal one rather than the offered one.
private struct EazyTabViewBottomAccessoryMeasure<Content: View>: View {
    @Binding var height: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .hidden()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { newValue in
                height = newValue
            }
    }
}

/// The glass the accessory is drawn on.
///
/// The same body of glass the tab bar is drawn on — same shader, same style —
/// because the two sit eight points apart and any difference between them reads
/// as a mistake. It is a capsule: the system's accessory reports the same
/// `NaN` corner radius as its tab bar platter, which is how a view whose corners
/// are configured as a capsule rather than as a radius reports itself, and the
/// platter is a capsule.
///
/// Sized by a `GeometryReader` in a background rather than by a measurement read
/// back into state, because the shader needs the rectangle in the accessory's
/// own coordinate space and a background has that for nothing.
private struct EazyTabViewBottomAccessoryGlass: View {
    let style: EazyLiquidGlassStyle

    var body: some View {
        GeometryReader { proxy in
            let frame = CGRect(origin: .zero, size: proxy.size)

            Color.clear
                .eazyLiquidGlass(.capsule(frame), style: style)
                .overlay(alignment: .topLeading) {
                    EazyTabViewBottomAccessoryRim(frame: frame)
                }
        }
    }
}

/// An even hairline along the edge.
///
/// The same rim ``EazyMorphingTabBar`` draws, and for the same reason: the
/// shader's highlight is a directional specular, so one light can only catch one
/// edge, while the system's glass is lit top *and* bottom. The evenness has to
/// be drawn rather than lit.
private struct EazyTabViewBottomAccessoryRim: View {
    let frame: CGRect

    var body: some View {
        Capsule(style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(0.33),
                        .white.opacity(0.10),
                        .white.opacity(0.40)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1
            )
            .frame(width: frame.width, height: frame.height)
            .allowsHitTesting(false)
    }
}
