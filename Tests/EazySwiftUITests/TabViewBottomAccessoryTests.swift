import Foundation
import SwiftUI
import Testing
@testable import EazySwiftUI

/// The accessory's layout is derived from five measured numbers rather than
/// stored per-placement, so these tests check the derivations against the
/// frames the system actually draws.
///
/// The reference is a live `TabView` running `tabViewBottomAccessory` and
/// `tabBarMinimizeBehavior(.onScrollDown)` on iOS 26, in a 402×874 window:
///
/// | | x | y | width | height |
/// | --- | --- | --- | --- | --- |
/// | accessory, expanded | 21 | 735 | 360 | 48 |
/// | tab bar | 21 | 791 | 360 | 62 |
/// | accessory, inline | 84 | 798 | 290 | 48 |
/// | tab bar, collapsed | 28 | 798 | 48 | 48 |
@Suite("Tab view bottom accessory geometry")
struct TabViewBottomAccessoryGeometryTests {
    private let metrics = EazyTabViewBottomAccessoryMetrics.standard

    /// The width of the window everything below was measured in.
    private let screenWidth: CGFloat = 402
    /// The height of the window everything below was measured in.
    private let screenHeight: CGFloat = 874

    @Test
    func theExpandedAccessoryIsAsWideAsTheBarItSitsOver() {
        let leading = metrics.leadingInset(for: .expanded)
        let trailing = metrics.trailingInset(for: .expanded)

        #expect(leading == 21)
        #expect(trailing == 21)
        #expect(screenWidth - leading - trailing == 360)
    }

    @Test
    func theExpandedAccessorySitsEightPointsAboveTheBar() {
        // The bar's top edge is the accessory's own bottom edge, so the whole
        // of the vertical arrangement is the gap plus the accessory.
        let barTop = screenHeight - metrics.screenInset - metrics.barHeight
        let accessoryBottom = barTop - metrics.spacing

        #expect(barTop == 791)
        #expect(accessoryBottom == 783)
        #expect(accessoryBottom - metrics.height == 735)
    }

    @Test
    func theInlineAccessoryLandsOnTheBarsRow() {
        let barTop = screenHeight - metrics.screenInset - metrics.barHeight
        let expandedTop = barTop - metrics.spacing - metrics.height

        #expect(metrics.inlineDrop == 63)
        #expect(expandedTop + metrics.inlineDrop == 798)
        #expect(expandedTop + metrics.inlineDrop + metrics.height == 846)
    }

    @Test
    func theInlineAccessoryLeavesRoomForTheCollapsedBar() {
        let leading = metrics.leadingInset(for: .inline)
        let trailing = metrics.trailingInset(for: .inline)

        #expect(trailing == 28)
        #expect(leading == 84)
        #expect(screenWidth - leading - trailing == 290)
    }

    @Test
    func theCollapsedBarAndTheInlineAccessoryShareACentreLine() {
        // Both are 48 points tall and both sit 28 points off the bottom, which
        // is what makes the inline arrangement read as one row rather than two
        // controls that happen to be near each other.
        let barCentre = screenHeight - metrics.screenInset - metrics.barHeight / 2
        let collapsedBarTop = barCentre - metrics.collapsedBarDiameter / 2
        let barTop = screenHeight - metrics.screenInset - metrics.barHeight
        let inlineTop = barTop - metrics.spacing - metrics.height + metrics.inlineDrop

        #expect(collapsedBarTop == 798)
        #expect(inlineTop == collapsedBarTop)
        #expect(screenHeight - (collapsedBarTop + metrics.collapsedBarDiameter) == 28)
    }

    @Test
    func theAccessoryClaimsItselfAndTheGapAboveTheBar() {
        #expect(metrics.reservedHeight == 56)
    }

    @Test
    func theExpandedPlacementNeitherDropsNorInsets() {
        #expect(metrics.drop(for: .expanded) == 0)
        #expect(metrics.drop(for: .inline) == metrics.inlineDrop)
    }

    /// The drop is a distance between two centres, so an accessory grown by an
    /// accessibility text size still lands on the bar's centre line rather than
    /// hanging below it.
    @Test
    func aGrownAccessoryStillLandsOnTheBarsCentre() {
        var grown = metrics
        grown.height = 72

        let barCentre = screenHeight - grown.screenInset - grown.barHeight / 2
        let barTop = screenHeight - grown.screenInset - grown.barHeight
        let inlineTop = barTop - grown.spacing - grown.height + grown.inlineDrop

        #expect(inlineTop + grown.height / 2 == barCentre)
    }

    /// The short-screen arrangement changes the bar, not the accessory: the
    /// system lays out a 44-point bar in landscape and leaves its accessory at
    /// 48, so only the drop and the insets move.
    @Test
    func theShortScreenArrangementOnlyFollowsTheShorterBar() {
        let short = EazyTabViewBottomAccessoryMetrics.shortScreen

        #expect(short.height == metrics.height)
        #expect(short.spacing == metrics.spacing)
        #expect(short.barHeight == 44)
        #expect(short.screenInset == EazyMorphingTabBarMetrics.shortScreenInset)
        // 24 + 8 + 22: half the accessory, the gap, half the shorter bar.
        #expect(short.inlineDrop == CGFloat(54))
    }

    @Test
    func degenerateMeasurementsAreClampedRatherThanDrawn() {
        let degenerate = EazyTabViewBottomAccessoryMetrics(
            height: -10,
            spacing: -4,
            screenInset: -1,
            barHeight: 0,
            collapsedBarDiameter: -8
        )

        #expect(degenerate.height >= 1)
        #expect(degenerate.spacing == 0)
        #expect(degenerate.screenInset == 0)
        #expect(degenerate.barHeight >= 1)
        #expect(degenerate.collapsedBarDiameter == 0)
    }
}

@Suite("Tab view bottom accessory public API")
struct TabViewBottomAccessoryPublicAPITests {

    /// Mirrors `TabViewBottomAccessoryPlacement`, which has exactly these two.
    @Test
    func thePlacementHasTheSameTwoCasesTheSystemHas() {
        #expect(EazyTabViewBottomAccessoryPlacement.allCases.count == 2)
        #expect(EazyTabViewBottomAccessoryPlacement.allCases.contains(.inline))
        #expect(EazyTabViewBottomAccessoryPlacement.allCases.contains(.expanded))
    }

    /// The system's environment value is optional, and reads `nil` where there
    /// is no accessory. So does this one.
    @Test
    @MainActor
    func thePlacementEnvironmentValueDefaultsToNil() {
        let values = EnvironmentValues()

        #expect(values.eazyTabViewBottomAccessoryPlacement == nil)
    }

    @Test
    @MainActor
    func theModifierIsReachableFromOutsideTheModule() {
        // Compilation is the assertion: the modifier, the metrics, the style
        // and the placement all have to be public for this to build.
        _ = Color.clear.eazyTabViewBottomAccessory(
            isEnabled: true,
            placement: .inline,
            metrics: .standard,
            style: .tabBar
        ) {
            Text("Now Playing")
        }
    }
}

/// The bar's collapse, and the one invariant that ties it to the accessory: the
/// circle and the inline accessory have to sit on the same centre line, or the
/// two read as two controls that happen to be near each other rather than as
/// one row.
///
/// Measured on the same live iOS 26 `TabView` at 402×874: the collapsed bar is
/// a 48-point circle at x 28, y 798, and the inline accessory is 48 points tall
/// at x 84, y 798.
@Suite("Tab bar collapse geometry")
struct TabBarCollapseGeometryTests {
    private let metrics = EazyMorphingTabBarMetrics.standard
    private let accessory = EazyTabViewBottomAccessoryMetrics.standard

    private func layout(tabs: Int = 3) -> EazyMorphingTabBarLayout {
        EazyMorphingTabBarLayout(
            metrics: metrics,
            tabCount: tabs,
            expandedContentSize: .zero,
            hasToggle: false
        )
    }

    @Test
    func theCircleIsCentredInTheBandTheBarOccupied() {
        let rect = layout().collapsedRect

        // Seven points inside the 62-point bar on every side, which is what
        // puts it 28 points off the screen once the bar's own 21-point inset is
        // counted.
        #expect(rect.width == 48)
        #expect(rect.height == 48)
        #expect(rect.minX == 7)
        #expect(rect.minY == 7)
        #expect(metrics.screenInset + rect.minX == 28)
    }

    /// The regression this suite exists for. Deriving the collapsed top edge
    /// from the height rather than interpolating onto the circle's own top put
    /// the glass on the bar's floor instead of centred in its band — fourteen
    /// points down rather than seven — so the circle hung below the accessory
    /// beside it.
    @Test
    func aFullyCollapsedSurfaceIsExactlyTheCircle() {
        let layout = layout()
        let surface = layout.surface(expandedBy: 0, collapsedBy: 1)

        #expect(surface.frame == layout.collapsedRect)
        #expect(surface.cornerRadius == metrics.collapsedDiameter / 2)
    }

    @Test
    func anUncollapsedSurfaceIsExactlyTheStrip() {
        let layout = layout()

        #expect(layout.surface(expandedBy: 0, collapsedBy: 0).frame == layout.barRect)
    }

    @Test
    func theSurfaceOnlyEverShrinksTowardsTheCircle() {
        let layout = layout()

        // Nothing on the way may be taller than the bar or shorter than the
        // circle: the height decays onto 48 without dipping below it, which is
        // what the recordings show and what keeps the stretch off that axis.
        for step in 0...20 {
            let frame = layout.surface(
                expandedBy: 0,
                collapsedBy: Double(step) / 20
            ).frame

            #expect(frame.height <= metrics.barHeight + 0.001)
            #expect(frame.height >= metrics.collapsedDiameter - 0.001)
        }
    }

    @Test
    func theCircleAndTheInlineAccessoryShareACentreLine() {
        let screenHeight: CGFloat = 874
        let layout = layout()

        // The bar's band, in screen terms.
        let barTop = screenHeight - metrics.screenInset - metrics.barHeight
        let circleTop = barTop + layout.collapsedRect.minY
        let circleCentre = circleTop + layout.collapsedRect.height / 2

        // The accessory's inline row, derived entirely separately.
        let accessoryTop = barTop - accessory.spacing - accessory.height
            + accessory.inlineDrop
        let accessoryCentre = accessoryTop + accessory.height / 2

        #expect(circleTop == 798)
        #expect(accessoryCentre == circleCentre)
    }

    /// The accessory reserves the room beside the collapsed bar from its own
    /// metrics, and the bar draws the circle from its. They are separate types,
    /// so the two 48s have to agree or the inline row has a gap or an overlap.
    @Test
    func theAccessoryLeavesExactlyTheRoomTheCircleTakes() {
        #expect(accessory.collapsedBarDiameter == metrics.collapsedDiameter)
        #expect(accessory.inlineLeadingInset
            == accessory.inlineTrailingInset + metrics.collapsedDiameter + accessory.spacing)
    }

    @Test
    func theShortScreenBarKeepsTheSameSevenPointInset() {
        let short = EazyMorphingTabBarMetrics.shortScreen
        let inset = (short.barHeight - short.collapsedDiameter) / 2

        #expect(inset == 7)
    }

    @Test
    func aCollapsedDiameterLargerThanTheBarIsClamped() {
        let odd = EazyMorphingTabBarMetrics(barHeight: 40, collapsedDiameter: 96)

        #expect(odd.collapsedDiameter == 40)
    }
}

@Suite("Tab bar minimize behavior")
struct TabBarMinimizeBehaviorTests {

    @Test
    func onScrollDownMinimizesOnAGrowingOffset() {
        #expect(EazyTabBarMinimizeBehavior.onScrollDown.minimizes(forScrollDelta: 30))
        #expect(!EazyTabBarMinimizeBehavior.onScrollDown.minimizes(forScrollDelta: -30))
    }

    @Test
    func onScrollUpIsTheOtherWayRound() {
        #expect(EazyTabBarMinimizeBehavior.onScrollUp.minimizes(forScrollDelta: -30))
        #expect(!EazyTabBarMinimizeBehavior.onScrollUp.minimizes(forScrollDelta: 30))
    }

    @Test
    func neverTracksNothingAndMinimizesForNothing() {
        #expect(!EazyTabBarMinimizeBehavior.never.tracksScrolling)
        #expect(!EazyTabBarMinimizeBehavior.never.minimizes(forScrollDelta: 500))
        #expect(EazyTabBarMinimizeBehavior.onScrollDown.tracksScrolling)
    }

    /// A bar with no behavior attached must never collapse: the default proxy
    /// tracks nothing, so the collapsed circle is never drawn and the accessory
    /// stays expanded.
    @Test
    @MainActor
    func theDefaultProxyTracksNothing() {
        let values = EnvironmentValues()

        #expect(!values.eazyTabBarMinimize.isTracking)
        #expect(!values.eazyTabBarMinimize.isMinimized)
    }
}
