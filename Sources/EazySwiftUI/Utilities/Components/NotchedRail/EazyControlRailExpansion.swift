import SwiftUI

/// Expansion state published by ``EazyControlRail``.
///
/// `progress` is `0` when the selection pill is collapsed and `1` when it is
/// fully expanded. Containers can use this to grow an accompanying shape, such
/// as ``EazyNotchedCardShape``'s cutout, in lockstep with the pill, because the
/// rail writes to it inside the same `withAnimation` blocks that drive it.
public struct EazyControlRailExpansion: Equatable, Sendable {
    public var progress: CGFloat
    /// The distance the rail's visible content reaches above its center.
    public var topExtent: CGFloat
    /// The distance the rail's visible content reaches below its center.
    public var bottomExtent: CGFloat
    /// The height of the notch's curved shoulders.
    public var shoulderHeight: CGFloat
    /// Half the height the rail needs for layout, including the expanded pill.
    public var layoutHalfExtent: CGFloat

    /// Creates rail expansion state.
    public init(
        progress: CGFloat = 0,
        topExtent: CGFloat = 0,
        bottomExtent: CGFloat = 0,
        shoulderHeight: CGFloat = 0,
        layoutHalfExtent: CGFloat = 0
    ) {
        self.progress = progress
        self.topExtent = topExtent
        self.bottomExtent = bottomExtent
        self.shoulderHeight = shoulderHeight
        self.layoutHalfExtent = layoutHalfExtent
    }

    public var isExpanded: Bool { progress > 0.5 }
    public var activeRailHeight: CGFloat { topExtent + bottomExtent }

    /// How far the notch's center sits below the rail's center.
    public var notchCenterOffset: CGFloat { (bottomExtent - topExtent) / 2 }

    /// The extents scaled down proportionally to fit within `maxHeight`.
    public func fittedExtents(maxHeight: CGFloat) -> (top: CGFloat, bottom: CGFloat) {
        let scale = min(1, max(0, maxHeight) / max(activeRailHeight, 1))
        return (topExtent * scale, bottomExtent * scale)
    }
}
