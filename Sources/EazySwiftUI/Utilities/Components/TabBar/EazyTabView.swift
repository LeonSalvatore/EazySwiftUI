//
//  EazyTabView.swift
//  EazySwiftUI
//

import SwiftUI

/// A tab view built on ``EazyMorphingTabBar``, with the bottom furniture laid
/// out for you.
///
/// ```swift
/// EazyTabView(selection: $selection) {
///     EazyTab("Home", systemImage: "house.fill", value: "home") {
///         HomeScreen()
///     }
///     EazyTab("Library", systemImage: "books.vertical.fill", value: "library") {
///         LibraryScreen()
///     }
/// }
/// .eazyTabBarMinimizeBehavior(.onScrollDown)
/// .eazyTabViewBottomAccessory { NowPlayingBar() }
/// ```
///
/// That is the whole wiring. Scrolling down collapses the bar into a circle and
/// takes the accessory inline beside it; scrolling back up, or tapping the
/// circle, restores both. Tapping the tab already showing takes its scroll view
/// back to the top. Nothing is held by the caller.
///
/// Where the tabs are already a value — loaded, filtered, ordered elsewhere —
/// ``init(tabs:selection:tint:metrics:shortScreenMetrics:style:actions:content:)``
/// takes the array and a closure instead.
///
/// ## Why a container rather than modifiers on your own bar
///
/// The accessory has to sit eight points above the bar, and go and sit *beside*
/// it when it collapses. Placing the bar yourself with a `safeAreaInset` leaves
/// the accessory inferring where the bar is from modifier ordering, and its
/// `spacing:` parameter — which defaults to eight points, not zero — silently
/// doubles the gap. Here one view owns the content, the bar and the accessory,
/// so all three are laid out against each other in one coordinate space and
/// none of that can be got wrong.
///
/// Every tab's content is built and kept alive, the way a `TabView`'s is, so a
/// tab returned to is the tab that was left — scroll position and all.
public struct EazyTabView<Content: View>: View {
    private let tabs: [EazyTab]
    @Binding private var selection: EazyTab.ID
    private let tint: Color
    private let metrics: EazyMorphingTabBarMetrics
    private let shortScreenMetrics: EazyMorphingTabBarMetrics?
    private let style: EazyLiquidGlassStyle
    private let actions: [EazyTabBarAction]
    private let content: (EazyTab) -> Content

    @State private var isExpanded = false
    /// How many times each tab has been tapped while it was already showing.
    ///
    /// Per tab rather than one counter, so that a reselection reaches only the
    /// screen it happened on. One shared counter would take every other tab
    /// back to the top as well, quietly, off screen.
    @State private var reselections: [EazyTab.ID: Int] = [:]
    @Environment(\.eazyTabViewBottomAccessory) private var accessory
    @Environment(\.eazyTabBarMinimize) private var minimize
    #if os(iOS) || os(tvOS) || os(visionOS)
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif

    /// Creates a tab view from tabs you already have.
    ///
    /// - Parameters:
    ///   - tabs: The items in the bar, in leading-to-trailing order.
    ///   - selection: The identifier of the selected tab.
    ///   - tint: The color of the selected tab's symbol.
    ///   - metrics: The measurements the bar lays itself out with.
    ///   - shortScreenMetrics: The measurements to use where the screen is too
    ///     short for `metrics` — an iPhone in landscape.
    ///   - style: How the bar's glass is lit and blurred.
    ///   - actions: The actions the bar expands into. With none, the bar shows
    ///     no toggle and the strip takes the whole width, which is the
    ///     arrangement that matches the system bar.
    ///   - content: The view for a tab. Called once per tab, and the result
    ///     kept alive for as long as the tab view is.
    public init(
        tabs: [EazyTab],
        selection: Binding<EazyTab.ID>,
        tint: Color = .accentColor,
        metrics: EazyMorphingTabBarMetrics = .standard,
        shortScreenMetrics: EazyMorphingTabBarMetrics? = .shortScreen,
        style: EazyLiquidGlassStyle = .tabBar,
        actions: [EazyTabBarAction] = [],
        @ViewBuilder content: @escaping (EazyTab) -> Content
    ) {
        self.tabs = tabs
        self._selection = selection
        self.tint = tint
        self.metrics = metrics
        self.shortScreenMetrics = shortScreenMetrics
        self.style = style
        self.actions = actions
        self.content = content
    }

    public var body: some View {
        EazyTabViewContent(
            tabs: tabs,
            selection: selection,
            reselections: reselections,
            content: content
        )
        .safeAreaInset(edge: .bottom, spacing: 0) {
            furniture
        }
        .ignoresSafeArea(edges: .bottom)
        .environment(\.eazyTabViewBottomAccessoryPlacement, resolvedPlacement)
        .environment(\.eazyTabReselectionHandler, .init { reselections[$0, default: 0] += 1 })
    }

    /// The bar, and the accessory's room above it.
    ///
    /// The accessory's room is an empty spacer with the accessory drawn into it
    /// by an overlay rather than placed in the stack, because inline the
    /// accessory leaves that room entirely and drops onto the bar's row. Its
    /// bottom edge is the bar's top edge either way, which is the one thing
    /// every accessory frame is measured from.
    private var furniture: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: accessoryReserve)
                .overlay(alignment: .bottom) {
                    EazyTabViewBottomAccessoryHost(
                        accessory: accessory,
                        placement: resolvedPlacement
                    )
                }
                // Lifted above the bar, so an inline accessory that has dropped
                // onto the bar's row is drawn over its glass and not under it.
                .zIndex(1)

            EazyMorphingTabBar(
                tabs: tabs,
                selection: $selection,
                isExpanded: $isExpanded,
                actions: actions,
                tint: tint,
                metrics: metrics,
                shortScreenMetrics: shortScreenMetrics,
                style: style
            )
        }
        // The bar insets its own sides; only the bottom is the container's to
        // place, and the system puts its bar 21 points above the screen's edge
        // rather than above the home indicator.
        .padding(.bottom, activeMetrics.screenInset)
    }

    /// The arrangement for the screen the bar is on, which is what sets the
    /// bottom inset and the bar's height.
    private var activeMetrics: EazyMorphingTabBarMetrics {
        #if os(iOS) || os(tvOS) || os(visionOS)
        if verticalSizeClass == .compact, let shortScreenMetrics {
            return shortScreenMetrics
        }
        #endif
        return metrics
    }

    /// Where the accessory sits: what it was told, or — and this is the usual
    /// case — whatever the bar is doing.
    private var resolvedPlacement: EazyTabViewBottomAccessoryPlacement? {
        guard let accessory, accessory.isEnabled else { return nil }
        if let placement = accessory.placement { return placement }
        return minimize.isMinimized && !isExpanded ? .inline : .expanded
    }

    /// The room the accessory claims above the bar: itself, and the gap.
    ///
    /// Kept claimed while the accessory is inline, so that collapsing the bar
    /// part way through a scroll does not also reflow the content the reader is
    /// looking at. The system agrees, near enough: its container gives back the
    /// seven points the collapsed bar is inset by, and keeps the rest.
    private var accessoryReserve: CGFloat {
        guard let accessory, accessory.isEnabled else { return 0 }
        return accessory.metrics.reservedHeight
    }
}

// MARK: - The tab builder

public extension EazyTabView where Content == AnyView {

    /// Creates a tab view from tabs declared in its body.
    ///
    /// This is `TabView`'s arrangement, and reads the same:
    ///
    /// ```swift
    /// EazyTabView(selection: $selection) {
    ///     EazyTab("Home", systemImage: "house.fill", value: "home") {
    ///         HomeScreen()
    ///     }
    ///
    ///     if account.isSignedIn {
    ///         EazyTab("You", systemImage: "person.fill", value: "you") {
    ///             ProfileScreen()
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// A tab declared without content shows nothing, the way `Tab` without a
    /// content closure is only ever a bar item.
    ///
    /// - Parameters:
    ///   - selection: The identifier of the selected tab — the `value` of one
    ///     of the tabs declared below.
    ///   - tint: The color of the selected tab's symbol.
    ///   - metrics: The measurements the bar lays itself out with.
    ///   - shortScreenMetrics: The measurements to use where the screen is too
    ///     short for `metrics` — an iPhone in landscape.
    ///   - style: How the bar's glass is lit and blurred.
    ///   - actions: The actions the bar expands into. With none, the bar shows
    ///     no toggle and the strip takes the whole width, which is the
    ///     arrangement that matches the system bar.
    ///   - tabs: The tabs, and the screen behind each.
    init(
        selection: Binding<EazyTab.ID>,
        tint: Color = .accentColor,
        metrics: EazyMorphingTabBarMetrics = .standard,
        shortScreenMetrics: EazyMorphingTabBarMetrics? = .shortScreen,
        style: EazyLiquidGlassStyle = .tabBar,
        actions: [EazyTabBarAction] = [],
        @EazyTabContentBuilder tabs: () -> [EazyTab]
    ) {
        self.init(
            tabs: tabs(),
            selection: selection,
            tint: tint,
            metrics: metrics,
            shortScreenMetrics: shortScreenMetrics,
            style: style,
            actions: actions
        ) { tab in
            // The tab is carrying its own screen, so the closure the array
            // form asks for is just a call. Type-erased because the tabs in one
            // body are all different types and an array is not.
            tab.screen?() ?? AnyView(EmptyView())
        }
    }
}

// MARK: - Content

/// Every tab that has been visited, with the selected one showing.
///
/// Two behaviours of `TabView` that are easy to lose and immediately noticed:
///
/// - A tab is built the first time it is selected, not at launch. Building all
///   of them up front runs every tab's `task` and `onAppear` before the reader
///   has been anywhere, fires every network call at once, and — with a
///   scroll-driven tab bar above — puts several scroll views in the subtree
///   where `onScrollGeometryChange` can see them.
/// - A tab that has been built stays built. Rebuilding on each switch loses the
///   scroll position, which is the first thing anyone notices.
///
/// So tabs arrive lazily and then stay.
private struct EazyTabViewContent<Content: View>: View {
    let tabs: [EazyTab]
    let selection: EazyTab.ID
    let reselections: [EazyTab.ID: Int]
    @ViewBuilder let content: (EazyTab) -> Content

    /// Which tabs have ever been selected. The selected one is always in it,
    /// including the one showing at launch.
    @State private var visited: Set<EazyTab.ID> = []

    var body: some View {
        ZStack {
            ForEach(tabs) { tab in
                if visited.contains(tab.id) {
                    EazyTabViewSlot(
                        isSelected: tab.id == selection,
                        reselections: reselections[tab.id] ?? 0
                    ) {
                        content(tab)
                    }
                }
            }
        }
        .onChange(of: selection, initial: true) { _, current in
            visited.insert(current)
        }
    }
}

/// One tab's screen, and its way back to the top.
///
/// A view of its own rather than a modifier chain in the loop above, so that
/// each tab is its own invalidation boundary: a reselection is a change to one
/// slot's input, and only that slot is re-evaluated. It also gives each tab its
/// own `ScrollPosition`, which is the point — one shared between them would
/// send every tab to the top at once.
private struct EazyTabViewSlot<Content: View>: View {
    let isSelected: Bool
    let reselections: Int
    @ViewBuilder let content: Content

    /// This tab's scroll view, as far as the container can reach it.
    ///
    /// `scrollPosition(_:)` binds to a scroll view *within* the view it is
    /// attached to, not to the view itself — the same reach that lets
    /// ``SwiftUICore/View/eazyTabBarMinimizeBehavior(_:)`` watch a scroll from
    /// above it. That reach is the whole mechanism here: the container never
    /// sees the caller's `ScrollView`, and does not need to.
    @State private var position = ScrollPosition(idType: Never.self)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        content
            .environment(\.eazyTabReselection, EazyTabReselection(count: reselections))
            .scrollPosition($position)
            .onChange(of: reselections) { _, _ in
                withAnimation(reduceMotion ? nil : Self.scrollToTop) {
                    position.scrollTo(edge: .top)
                }
            }
            .opacity(isSelected ? 1 : 0)
            .allowsHitTesting(isSelected)
            .accessibilityHidden(!isSelected)
    }

    /// How the screen travels back to the top.
    ///
    /// Chosen rather than measured, unlike the bar's own animations: a fixed
    /// short ease, so that a screen forty rows down and a screen four rows down
    /// both arrive in about the same time. A spring would make the first of
    /// those overshoot the top and bounce off it.
    private static var scrollToTop: Animation { .easeOut(duration: 0.35) }
}

// MARK: - Previews

private struct EazyTabViewDSLPreview: View {
    @State private var selection = "home"
    @State private var showsProfile = true

    var body: some View {
        EazyTabView(selection: $selection) {
            EazyTab("Home", systemImage: "house.fill", value: "home") {
                EazyTabViewSampleScreen(title: "Home", tint: .indigo)
            }

            EazyTab("Browse", systemImage: "square.grid.2x2.fill", value: "browse") {
                EazyTabViewSampleScreen(title: "Browse", tint: .teal)
            }

            // `if` inside the builder, which is what the result builder is for.
            if showsProfile {
                EazyTab("You", systemImage: "person.fill", value: "you") {
                    EazyTabViewSampleScreen(title: "You", tint: .orange)
                }
            }
        }
        .eazyTabBarMinimizeBehavior(.onScrollDown)
    }
}

/// Scrollable, and loud about where it is, so that tapping the selected tab is
/// visibly a trip back to the top.
private struct EazyTabViewSampleScreen: View {
    let title: String
    let tint: Color

    @Environment(\.eazyTabReselection) private var reselection

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                Text("Scroll down, then tap \(title) again")
                    .font(.headline)
                    .padding(.top, 8)

                Text("reselected \(reselection.count)×")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)

                ForEach(1..<40) { index in
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(0.18))
                        .frame(height: 72)
                        .overlay {
                            Text("\(title) \(index)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .padding()
        }
    }
}

#Preview("Tab DSL — tap the selected tab") {
    EazyTabViewDSLPreview()
}

#Preview("Tab DSL — with an accessory") {
    EazyTabViewDSLPreview()
        .eazyTabViewBottomAccessory {
            HStack {
                Image(systemName: "music.note")
                Text("Sonnet for Glass").font(.subheadline)
                Spacer()
                Image(systemName: "play.fill")
            }
            .padding(.horizontal, 16)
        }
}
