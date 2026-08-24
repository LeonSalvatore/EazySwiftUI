//
//  EazyTabViewBottomAccessoryMetrics.swift
//  EazySwiftUI
//

import SwiftUI

/// The measurements ``SwiftUICore/View/eazyTabViewBottomAccessory(isEnabled:placement:metrics:style:animation:content:)``
/// lays the accessory out with.
///
/// Every stored value is read off a live `TabView` running
/// `tabViewBottomAccessory` and `tabBarMinimizeBehavior(.onScrollDown)` on iOS
/// 26, in a 402×874 window, in both placements. Nothing here is estimated, and
/// nothing else is stored: the two arrangements the accessory takes are both
/// derived from these five numbers, and the derivations reproduce the measured
/// frames exactly.
///
/// The measured frames, for reference:
///
/// | | x | y | width | height |
/// | --- | --- | --- | --- | --- |
/// | accessory, expanded | 21 | 735 | 360 | 48 |
/// | tab bar | 21 | 791 | 360 | 62 |
/// | accessory, inline | 84 | 798 | 290 | 48 |
/// | tab bar, collapsed | 28 | 798 | 48 | 48 |
public struct EazyTabViewBottomAccessoryMetrics: Equatable, Sendable {
    /// The height of the accessory, in both placements.
    ///
    /// Forty-eight points, and the same in each: the system does not shrink the
    /// accessory on its way inline, it moves it.
    ///
    /// The accessory treats it as a floor rather than as a fixed height, and
    /// replaces it with whatever its content actually measures once that is
    /// larger — content set at an accessibility text size has to grow the
    /// accessory rather than be clipped by it. Every derived value below is
    /// written in terms of this property, so a grown accessory still lands on
    /// the bar's centre when it goes inline.
    public var height: CGFloat

    /// The gap between the accessory and the tab bar.
    ///
    /// Eight points, and it is the same gap in both directions: 791 − 783
    /// vertically while the accessory is expanded, and 84 − 76 horizontally
    /// once it is inline. It is also the gap the system leaves between its tab
    /// strip and a detached search tab, which is the arrangement
    /// ``EazyMorphingTabBar`` takes when it shows its toggle.
    public var spacing: CGFloat

    /// How far the accessory sits from the leading and trailing edges of the
    /// screen while expanded.
    ///
    /// The tab bar's own inset, because the accessory is exactly as wide as the
    /// bar it sits over.
    public var screenInset: CGFloat

    /// The height of the tab bar the accessory sits above.
    ///
    /// The only thing the accessory needs to know about the bar. It is what
    /// sets ``inlineDrop``: going inline, the accessory falls from its own row
    /// onto the bar's, and how far that is depends on how tall the bar is.
    public var barHeight: CGFloat

    /// The diameter of the collapsed tab bar the accessory shares a row with.
    ///
    /// Forty-eight points — the same as the accessory's height, which is what
    /// lets the two sit level. It is stored separately rather than derived
    /// from ``height`` because the accessory may outgrow 48 points at an
    /// accessibility text size while the bar beside it does not.
    public var collapsedBarDiameter: CGFloat

    public init(
        height: CGFloat = 48,
        spacing: CGFloat = 8,
        screenInset: CGFloat = EazyMorphingTabBarMetrics.screenInset,
        barHeight: CGFloat = 62,
        collapsedBarDiameter: CGFloat = 48
    ) {
        self.height = max(height, 1)
        self.spacing = max(spacing, 0)
        self.screenInset = max(screenInset, 0)
        self.barHeight = max(barHeight, 1)
        self.collapsedBarDiameter = max(collapsedBarDiameter, 0)
    }

    /// The default measurements: those of the system accessory.
    public static let standard = EazyTabViewBottomAccessoryMetrics()

    /// The arrangement for a short screen — an iPhone in landscape — where the
    /// system lays out a 44-point tab bar rather than a 62-point one.
    ///
    /// Only the bar height is different, and only because the drop onto the
    /// bar's row is shorter when the row is. The accessory itself is left at
    /// its measured height, since the system does not shrink it either.
    public static let shortScreen = EazyTabViewBottomAccessoryMetrics(
        screenInset: EazyMorphingTabBarMetrics.shortScreenInset,
        barHeight: 44
    )

    // MARK: Derived geometry

    /// The room the accessory claims above the tab bar: itself, and the gap.
    ///
    /// Fifty-six points at the measured height, which is what the system's
    /// content is inset by over and above the bar.
    public var reservedHeight: CGFloat { height + spacing }

    /// How far the accessory falls when it goes inline.
    ///
    /// Expanded, the accessory's centre sits half its own height, plus the gap,
    /// plus half the bar, above the bar's centre. Inline, the two centres are
    /// the same point. So the drop is the distance between those centres and
    /// nothing else: 24 + 8 + 31 = 63 points, which is exactly the 798 − 735
    /// measured.
    ///
    /// Writing it as a distance between centres rather than as an offset from
    /// the screen's bottom edge is what keeps it right when the accessory grows
    /// for an accessibility text size, and what keeps it independent of how far
    /// above the bottom edge the caller has placed the bar.
    public var inlineDrop: CGFloat { height / 2 + spacing + barHeight / 2 }

    /// How far the accessory sits from the trailing edge while inline.
    ///
    /// Further in than while expanded, by half the difference between the bar
    /// and the collapsed bar: the collapsed bar is centred in the band the full
    /// one occupied, so the row it leaves the accessory is inset with it.
    /// 21 + (62 − 48)/2 = 28, which is the measured 402 − 374.
    public var inlineTrailingInset: CGFloat {
        screenInset + (barHeight - collapsedBarDiameter) / 2
    }

    /// How far the accessory sits from the leading edge while inline.
    ///
    /// The trailing inset, plus the collapsed bar, plus the gap beside it:
    /// 28 + 48 + 8 = 84, the measured leading edge exactly.
    public var inlineLeadingInset: CGFloat {
        inlineTrailingInset + collapsedBarDiameter + spacing
    }

    /// The leading inset for a placement.
    public func leadingInset(
        for placement: EazyTabViewBottomAccessoryPlacement
    ) -> CGFloat {
        placement == .inline ? inlineLeadingInset : screenInset
    }

    /// The trailing inset for a placement.
    public func trailingInset(
        for placement: EazyTabViewBottomAccessoryPlacement
    ) -> CGFloat {
        placement == .inline ? inlineTrailingInset : screenInset
    }

    /// How far below its expanded row the accessory is drawn, for a placement.
    public func drop(
        for placement: EazyTabViewBottomAccessoryPlacement
    ) -> CGFloat {
        placement == .inline ? inlineDrop : 0
    }
}
