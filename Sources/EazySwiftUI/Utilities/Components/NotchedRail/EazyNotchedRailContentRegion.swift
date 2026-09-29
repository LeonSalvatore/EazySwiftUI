import SwiftUI

/// The notch's live vertical interval in ``EazyNotchedRailCard``'s coordinate space.
///
/// The card publishes it to its content through the environment. Content uses
/// it per row, through ``SwiftUICore/View/eazyNotchedRailAdaptiveInset(_:)``,
/// so rows beside the rail clear the cutout while rows above and below it keep
/// the card's natural margins.
public struct EazyNotchedRailContentRegion: Equatable, Sendable {
    /// The name of the card's coordinate space.
    public static let coordinateSpace = "eazy-notched-rail-card"

    public var top: CGFloat
    public var bottom: CGFloat
    /// The horizontal depth of the cutout.
    public var depth: CGFloat
    /// Whether the cutout is on the trailing edge.
    public var isTrailing: Bool

    /// Creates a content region.
    public init(top: CGFloat, bottom: CGFloat, depth: CGFloat, isTrailing: Bool) {
        self.top = top
        self.bottom = bottom
        self.depth = depth
        self.isTrailing = isTrailing
    }

    /// Whether `frame`, in the card's coordinate space, overlaps the notch vertically.
    public func intersects(_ frame: CGRect) -> Bool {
        bottom > top && frame.maxY > top && frame.minY < bottom
    }
}

extension EnvironmentValues {
    /// The enclosing ``EazyNotchedRailCard``'s notch, or `nil` outside one.
    @Entry public var eazyNotchedRailContentRegion: EazyNotchedRailContentRegion? = nil
}

private struct EazyNotchedRailAdaptiveInset: ViewModifier {
    @Environment(\.eazyNotchedRailContentRegion) private var region
    @State private var intersectsNotch = false
    let base: CGFloat

    func body(content: Content) -> some View {
        let region = region
        let clearance = intersectsNotch ? (region?.depth ?? 0) : 0
        return content
            .padding(.leading, base + (region?.isTrailing == false ? clearance : 0))
            .padding(.trailing, base + (region?.isTrailing == true ? clearance : 0))
            .onGeometryChange(for: Bool.self) { geometry in
                guard let region else { return false }
                return region.intersects(
                    geometry.frame(in: .named(EazyNotchedRailContentRegion.coordinateSpace))
                )
            } action: { intersectsNotch = $0 }
    }
}

extension View {
    /// Pads horizontally by `base`, adding the notch's depth on its side only
    /// while this view sits beside an ``EazyNotchedRailCard``'s cutout.
    ///
    /// Apply it per row rather than to a whole list, so rows scrolled above or
    /// below the rail reclaim the space.
    public func eazyNotchedRailAdaptiveInset(_ base: CGFloat = 16) -> some View {
        modifier(EazyNotchedRailAdaptiveInset(base: base))
    }
}
