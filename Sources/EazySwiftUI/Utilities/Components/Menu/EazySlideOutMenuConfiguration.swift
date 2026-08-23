import SwiftUI

/// Appearance and interaction settings for ``EazySlideOutMenu``.
public struct EazySlideOutMenuConfiguration {
    /// The logical edge that owns the menu.
    public var edge: HorizontalEdge
    /// The width of the revealed menu.
    public var menuWidth: EazySlideOutMenuWidth
    /// The primary-content width that remains visible as a dismiss target.
    public var minimumVisibleContentWidth: CGFloat
    /// The width of the overlay strip used to open a closed menu.
    ///
    /// Keep this narrow so ordinary controls near the menu edge remain usable.
    public var openingEdgeWidth: CGFloat
    /// The menu's scale at zero reveal progress.
    public var menuMinimumScale: CGFloat
    /// The shape applied to the primary content.
    public var contentShape: EazySlideOutMenuContentShape
    /// An optional primary-content background. `nil` uses the system background style.
    public var contentBackground: Color?
    /// An optional menu-canvas background. `nil` uses the system background style.
    public var menuBackground: Color?
    /// The scrim color drawn over primary content while the menu is revealed.
    public var scrimColor: Color
    /// The scrim opacity at full reveal.
    public var maximumScrimOpacity: Double
    /// The border color drawn around the shifted primary content.
    public var borderColor: Color
    /// The width of the shifted content's border.
    public var borderWidth: CGFloat
    /// The shadow color behind the shifted primary content.
    public var shadowColor: Color
    /// The blur radius of the shifted content's shadow.
    public var shadowRadius: CGFloat
    /// The horizontal distance of the shadow toward the revealed menu.
    public var shadowOffset: CGFloat
    /// The animation used for external state changes and gesture settling.
    public var settleAnimation: Animation
    /// Whether a light impact is emitted when this component changes state.
    public var hapticsEnabled: Bool

    /// Creates slide-out menu appearance and interaction settings.
    public init(
        edge: HorizontalEdge = .leading,
        menuWidth: EazySlideOutMenuWidth = .fraction(0.6),
        minimumVisibleContentWidth: CGFloat = 44,
        openingEdgeWidth: CGFloat = 24,
        menuMinimumScale: CGFloat = 0.95,
        contentShape: EazySlideOutMenuContentShape = .automatic,
        contentBackground: Color? = nil,
        menuBackground: Color? = nil,
        scrimColor: Color = .black,
        maximumScrimOpacity: Double = 0.22,
        borderColor: Color = .primary.opacity(0.12),
        borderWidth: CGFloat = 1,
        shadowColor: Color = .black.opacity(0.08),
        shadowRadius: CGFloat = 5,
        shadowOffset: CGFloat = 10,
        settleAnimation: Animation = .interactiveSpring(
            duration: 0.3,
            extraBounce: 0.02
        ),
        hapticsEnabled: Bool = true
    ) {
        self.edge = edge
        self.menuWidth = menuWidth
        self.minimumVisibleContentWidth = minimumVisibleContentWidth
        self.openingEdgeWidth = openingEdgeWidth
        self.menuMinimumScale = menuMinimumScale
        self.contentShape = contentShape
        self.contentBackground = contentBackground
        self.menuBackground = menuBackground
        self.scrimColor = scrimColor
        self.maximumScrimOpacity = maximumScrimOpacity
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.settleAnimation = settleAnimation
        self.hapticsEnabled = hapticsEnabled
    }
}
