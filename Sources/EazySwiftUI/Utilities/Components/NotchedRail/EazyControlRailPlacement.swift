import SwiftUI

/// Docking position shared by ``EazyControlRail`` and its notched container.
///
/// Containers use ``center(in:notchDepth:verticalBounds:)`` to position the
/// rail without changing its intrinsic size or its scrolling direction. The
/// raw values are stable, so a placement can be persisted with `@AppStorage`.
public enum EazyControlRailPlacement: String, CaseIterable, Hashable, Sendable {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing

    /// Whether the rail docks on the trailing edge.
    public var isTrailing: Bool {
        self == .topTrailing || self == .bottomTrailing
    }

    /// Whether the rail docks in the lower part of its container.
    public var isBottom: Bool {
        self == .bottomLeading || self == .bottomTrailing
    }

    /// The rail's center in a container of `size`.
    ///
    /// The rail sits inside the notch horizontally and at roughly 30% from the
    /// docked vertical edge, clamped to `verticalBounds` when provided.
    public func center(
        in size: CGSize,
        notchDepth: CGFloat,
        verticalBounds: ClosedRange<CGFloat>? = nil
    ) -> CGPoint {
        let bounds = verticalBounds ?? 0...max(0, size.height)
        let preferredY = size.height * (isBottom ? 1 - 0.298 : 0.298)
        return CGPoint(
            x: isTrailing ? size.width - notchDepth / 2 : notchDepth / 2,
            y: min(max(preferredY, bounds.lowerBound), bounds.upperBound)
        )
    }
}
