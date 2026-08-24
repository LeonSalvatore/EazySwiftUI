//
//  EazyTabBarMinimizeBehavior.swift
//  EazySwiftUI
//

import SwiftUI

/// When the tab bar collapses into a circle as the reader scrolls.
///
/// Mirrors `TabBarMinimizeBehavior`, which is iOS 26 only. This one works from
/// iOS 18 and macOS 15, because the bar it minimises is the package's own.
///
/// Apply it with
/// ``SwiftUICore/View/eazyTabBarMinimizeBehavior(_:)``, outside both the
/// accessory and the bar:
///
/// ```swift
/// tabContent
///     .eazyTabViewBottomAccessory { NowPlayingBar() }
///     .safeAreaInset(edge: .bottom, spacing: 0) { EazyMorphingTabBar(…) }
///     .eazyTabBarMinimizeBehavior(.onScrollDown)
/// ```
public struct EazyTabBarMinimizeBehavior: Hashable, Sendable {
    private enum Kind: Hashable, Sendable {
        case never
        case onScrollDown
        case onScrollUp
    }

    private let kind: Kind

    private init(_ kind: Kind) { self.kind = kind }

    /// The default: collapse as the reader scrolls down, on the platforms that
    /// have a scroll direction worth reacting to.
    ///
    /// The system resolves this per-platform and leaves it unresolved in its
    /// public surface; here it is `onScrollDown` on iOS and `never` everywhere
    /// else, because a bar that collapses under a trackpad scroll on macOS is
    /// a bar that flickers.
    public static let automatic: EazyTabBarMinimizeBehavior = {
        #if os(iOS)
        EazyTabBarMinimizeBehavior(.onScrollDown)
        #else
        EazyTabBarMinimizeBehavior(.never)
        #endif
    }()

    /// Collapse when the reader scrolls down, and restore when they scroll up.
    public static let onScrollDown = EazyTabBarMinimizeBehavior(.onScrollDown)

    /// Collapse when the reader scrolls up, and restore when they scroll down.
    public static let onScrollUp = EazyTabBarMinimizeBehavior(.onScrollUp)

    /// Never collapse.
    public static let never = EazyTabBarMinimizeBehavior(.never)

    /// Whether scrolling drives the bar at all.
    var tracksScrolling: Bool { kind != .never }

    /// Whether a scroll of `delta` points is the direction that collapses.
    ///
    /// A positive delta is the content offset growing, which is the reader
    /// scrolling *down* — the content moves up the screen.
    func minimizes(forScrollDelta delta: CGFloat) -> Bool {
        switch kind {
        case .never: false
        case .onScrollDown: delta > 0
        case .onScrollUp: delta < 0
        }
    }
}
