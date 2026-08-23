import SwiftUI

struct EazySlideOutMenuGestureIdentity: Hashable {
    let edge: HorizontalEdge
    let layoutDirection: LayoutDirection
    let menuWidth: CGFloat
    let openingEdgeWidth: CGFloat
    let hapticsEnabled: Bool
}
