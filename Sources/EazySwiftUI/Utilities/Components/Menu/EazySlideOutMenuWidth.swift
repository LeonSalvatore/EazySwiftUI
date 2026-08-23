import SwiftUI

/// A width used by ``EazySlideOutMenu`` for its revealed menu.
public enum EazySlideOutMenuWidth: Hashable, Sendable {
    /// A fraction of the container width, clamped to preserve visible content.
    case fraction(CGFloat)
    /// A fixed width, clamped to preserve the configured visible content strip.
    case fixed(CGFloat)
}
