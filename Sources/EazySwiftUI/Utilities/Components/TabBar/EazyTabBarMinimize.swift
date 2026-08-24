//
//  EazyTabBarMinimize.swift
//  EazySwiftUI
//

import SwiftUI

// MARK: - Environment

/// The bar's collapsed state, and the way back out of it.
///
/// Both halves travel together because the state has two owners: the scroll
/// that drives it, and the collapsed bar itself, which is a button that
/// restores the strip when it is tapped. An environment value alone carries the
/// first and not the second, so the setter rides along with the value.
public struct EazyTabBarMinimizeProxy: Sendable {
    /// Whether the tab bar is currently collapsed.
    public var isMinimized: Bool
    /// Asks for the bar to collapse or restore. Nothing at all when no
    /// ``SwiftUICore/View/eazyTabBarMinimizeBehavior(_:)`` is in play, so a bar
    /// with no behavior attached cannot minimise itself by accident.
    public var setMinimized: @MainActor @Sendable (Bool) -> Void

    public init(
        isMinimized: Bool = false,
        setMinimized: @escaping @MainActor @Sendable (Bool) -> Void = { _ in }
    ) {
        self.isMinimized = isMinimized
        self.setMinimized = setMinimized
    }

    /// Whether anything is driving the bar. A bar with no behavior attached
    /// never draws its collapsed form, and never offers the button that leaves
    /// it.
    public var isTracking: Bool = false
}

public extension EnvironmentValues {
    /// Whether the enclosing tab bar has collapsed, and how to change that.
    ///
    /// Published by ``SwiftUICore/View/eazyTabBarMinimizeBehavior(_:)`` to
    /// everything inside it — which is both the content and the bar, since the
    /// bar is placed by a `safeAreaInset` on that same content. That is what
    /// lets the accessory and the bar agree on a single state without the
    /// caller holding it.
    @Entry var eazyTabBarMinimize = EazyTabBarMinimizeProxy()
}

// MARK: - Modifier

public extension View {

    /// Collapses the tab bar into a circle as the reader scrolls, and restores
    /// it when they scroll back.
    ///
    /// Mirrors `tabBarMinimizeBehavior`. Apply it **outside** both the
    /// accessory and the bar — it is the one modifier that has to see all of
    /// them:
    ///
    /// ```swift
    /// tabContent
    ///     .eazyTabViewBottomAccessory { NowPlayingBar() }
    ///     .safeAreaInset(edge: .bottom, spacing: 0) {
    ///         EazyMorphingTabBar(tabs: tabs, selection: $selection, isExpanded: $isExpanded, actions: [])
    ///             .padding(.bottom, EazyMorphingTabBarMetrics.screenInset)
    ///     }
    ///     .ignoresSafeArea(edges: .bottom)
    ///     .eazyTabBarMinimizeBehavior(.onScrollDown)
    /// ```
    ///
    /// Outside is both possible and necessary. Possible because
    /// `onScrollGeometryChange` reports scroll views anywhere in the subtree,
    /// not only the view it is attached to, so a modifier above a
    /// `safeAreaInset` still sees the scroll view below it. Necessary because
    /// the state has to reach two subtrees that are siblings — the content with
    /// the accessory in it, and the bar in the inset — and only a common
    /// ancestor can put a value in front of both.
    ///
    /// With this in place nothing else needs wiring: the bar collapses, the
    /// accessory goes ``EazyTabViewBottomAccessoryPlacement/inline`` beside it,
    /// and tapping the collapsed bar brings both back.
    ///
    /// - Parameter behavior: When the bar collapses. ``EazyTabBarMinimizeBehavior/never``
    ///   leaves it alone, which is also what happens with no modifier at all.
    func eazyTabBarMinimizeBehavior(
        _ behavior: EazyTabBarMinimizeBehavior
    ) -> some View {
        modifier(EazyTabBarMinimizeModifier(behavior: behavior))
    }
}

/// Watches the scroll, decides whether the bar should be collapsed, and puts
/// that decision in front of everything below.
private struct EazyTabBarMinimizeModifier: ViewModifier {
    let behavior: EazyTabBarMinimizeBehavior

    @State private var isMinimized = false
    /// How far the reader has travelled in one direction since the last time
    /// the bar changed its mind.
    @State private var travel: CGFloat = 0

    /// How far the reader has to travel in one direction before the bar acts.
    ///
    /// A bar that reacted to every frame of a scroll would flicker on the small
    /// reversals a finger makes on the way. Twenty-four points is about a
    /// thumb's worth of deliberate movement, and short enough that the collapse
    /// still feels like a response to the scroll rather than to a gesture.
    private static let threshold: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .environment(\.eazyTabBarMinimize, proxy)
            .onScrollGeometryChange(for: EazyTabBarScrollSample.self) { geometry in
                let offset = geometry.contentOffset.y + geometry.contentInsets.top
                return EazyTabBarScrollSample(
                    offset: offset
                )
            } action: { previous, current in
                react(from: previous, to: current)
            }
    }

    private var proxy: EazyTabBarMinimizeProxy {
        var proxy = EazyTabBarMinimizeProxy(isMinimized: isMinimized) { minimized in
            guard behavior.tracksScrolling else { return }
            travel = 0
            isMinimized = minimized
        }
        proxy.isTracking = behavior.tracksScrolling
        return proxy
    }

    private func react(
        from previous: EazyTabBarScrollSample,
        to current: EazyTabBarScrollSample
    ) {
        guard behavior.tracksScrolling else { return }

        // The top of the content always shows the whole bar. Otherwise a list
        // that is scrolled back to the top can sit there with the bar still
        // collapsed, which reads as a bar that has got stuck.
        guard !current.isAtTop else {
            travel = 0
            if isMinimized { isMinimized = false }
            return
        }

        let delta = current.offset - previous.offset
        guard delta != 0 else { return }

        // Travel accumulates only while the direction holds; a reversal starts
        // the count again from this step rather than unwinding the old one.
        travel = (travel > 0) == (delta > 0) ? travel + delta : delta
        guard abs(travel) >= Self.threshold else { return }

        let minimizes = behavior.minimizes(forScrollDelta: travel)
        travel = 0
        guard minimizes != isMinimized else { return }
        isMinimized = minimizes
    }
}

/// One reading of the scroll, reduced to the two things the decision needs.
private struct EazyTabBarScrollSample: Equatable {
    /// How far the content has travelled from its resting position, so that
    /// zero is the top whatever inset the content carries.
    var offset: CGFloat

    /// Whether the content is at or above its resting position, which covers
    /// the rubber band past the top as well as the top itself.
    var isAtTop: Bool { offset <= 0 }
}

