import SwiftUI

/// The shape used to clip ``EazySlideOutMenu`` primary content.
public enum EazySlideOutMenuContentShape: Hashable, Sendable {
    /// Matches concentric display corners on iOS and macOS 26 or later, with a
    /// 55-point rounded-rectangle fallback on earlier supported releases.
    case automatic
    /// Uses a continuous rounded rectangle with a caller-supplied corner radius.
    case roundedRectangle(cornerRadius: CGFloat)
}
