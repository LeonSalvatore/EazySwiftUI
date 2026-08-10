import Foundation
import SwiftUI
import Testing
@testable import EazySwiftUI

@Suite("Morphing tab bar layout")
struct MorphingTabBarLayoutTests {
    private let metrics = EazyMorphingTabBarMetrics.standard

    private func layout(
        tabs: Int = 4,
        expandedContent: CGSize = CGSize(width: 288, height: 234)
    ) -> EazyMorphingTabBarLayout {
        EazyMorphingTabBarLayout(
            metrics: metrics,
            tabCount: tabs,
            expandedContentSize: expandedContent
        )
    }

    @Test
    func dragPicksTheTabUnderTheFinger() {
        let layout = layout()

        #expect(layout.tabIndex(at: metrics.barPadding + 1) == 0)
        #expect(layout.tabIndex(at: layout.lensCenter(at: 1)) == 1)
        #expect(layout.tabIndex(at: layout.lensCenter(at: 3)) == 3)
    }

    @Test
    func theBoundaryBetweenTwoTabsSitsHalfwayBetweenTheirCentres() {
        let layout = layout()
        let midpoint = (layout.lensCenter(at: 1) + layout.lensCenter(at: 2)) / 2

        // Boxes overlap, so a point can fall inside two of them; the nearer
        // centre has to win, or the overlap would silently belong to one side.
        #expect(layout.tabIndex(at: midpoint - 1) == 1)
        #expect(layout.tabIndex(at: midpoint + 1) == 2)
    }

    @Test
    func dragBeyondEitherEndKeepsTheLastTab() {
        let layout = layout()

        #expect(layout.tabIndex(at: -400) == 0)
        #expect(layout.tabIndex(at: 4_000) == 3)
    }

    @Test
    func theLensStaysInsideTheStripWhileDragged() {
        let layout = layout()
        let first = layout.lensCenter(at: 0)
        let last = layout.lensCenter(at: 3)

        #expect(layout.lensCenter(draggedTo: -100) == first)
        #expect(layout.lensCenter(draggedTo: 10_000) == last)
        #expect(layout.lensCenter(draggedTo: last - 20) == last - 20)
    }

    @Test
    func theLensRestsOnTheSelectedTab() {
        let layout = layout()
        let lens = layout.lens(at: 2)

        #expect(lens.frame.midX == layout.lensCenter(at: 2))
        #expect(lens.frame.width == metrics.tabWidth)
        #expect(lens.frame.height == metrics.tabHeight)
        #expect(lens.cornerRadius == lens.frame.height / 2)
    }

    @Test
    func aDraggedLensLeavesTheSelectedTab() {
        let layout = layout()
        let position = layout.lensPosition(draggedTo: layout.lensCenter(at: 2))
        let dragged = layout.lens(.init(resting: position))

        #expect(abs(dragged.frame.midX - layout.lensCenter(at: 2)) < 0.0001)
        // A lens under a finger is where it was put, so it is never stretched.
        #expect(abs(dragged.frame.width - metrics.tabWidth) < 0.0001)
    }

    @Test
    func anEmptyBarHasNoLens() {
        #expect(layout(tabs: 0).lens(at: 0) == .none)
    }

    @Test
    func expandingNeverChangesTheFootprint() {
        let layout = layout()

        // The panel is drawn outside the bar's own frame, so the surrounding
        // layout must not move when the bar expands.
        #expect(layout.collapsedSize.height == metrics.barHeight)
        #expect(layout.panelSize.height > layout.collapsedSize.height)
        #expect(layout.collapsedSize.width == layout.canvasSize.width)
    }

    @Test
    func theStripAndThePanelShareTheirBottomLeadingCorner() {
        let layout = layout()

        #expect(layout.barRect.minX == layout.panelRect.minX)
        #expect(layout.barRect.maxY == layout.panelRect.maxY)
        #expect(layout.toggleRect.maxY == layout.barRect.maxY)
    }

    @Test
    func theToggleClearsTheWiderOfTheStripAndThePanel() {
        let wide = layout(expandedContent: CGSize(width: 600, height: 234))

        #expect(wide.panelSize.width > wide.barSize.width)
        #expect(wide.toggleRect.minX == wide.panelSize.width + metrics.spacing)
    }

    @Test
    func aPanelSmallerThanTheStripStillMatchesItsWidth() {
        let narrow = layout(expandedContent: CGSize(width: 40, height: 40))

        #expect(narrow.panelSize.width == narrow.barSize.width)
        #expect(narrow.panelSize.height == metrics.barHeight)
    }
}

/// The numbers in this suite were read off a live `UITabBarController` on
/// iOS 26 at 402×874 points, not chosen. They are here so that a later change to
/// the metrics has to be a deliberate departure from the system's layout rather
/// than an accidental one.
@Suite("Parity with the system tab bar")
struct MorphingTabBarNativeParityTests {
    private let metrics = EazyMorphingTabBarMetrics.standard

    private func layout(tabs: Int) -> EazyMorphingTabBarLayout {
        EazyMorphingTabBarLayout(
            metrics: metrics,
            tabCount: tabs,
            expandedContentSize: .zero
        )
    }

    @Test
    func theBarIsTheHeightOfTheSystemPlatter() {
        // _UITabBarPlatterView: 62 points tall, drawn as a capsule.
        #expect(metrics.barHeight == 62)
        #expect(layout(tabs: 4).barRect.height == 62)
    }

    @Test
    func fourTabsMeasureWhatTheSystemMeasures() {
        // The system bar on a 402-point screen is 360 wide: 402 less a 21-point
        // inset on each side. Four tabs have to arrive at that width on their
        // own, or the bar only matches by coincidence of screen size.
        #expect(layout(tabs: 4).naturalWidth == 360)
        #expect(402 - EazyMorphingTabBarMetrics.screenInset * 2 == 360)
    }

    @Test
    func twoAndThreeTabsMeasureWhatTheSystemMeasures() {
        // Measured: 188 and 274, which the system keeps at any screen width.
        #expect(layout(tabs: 2).naturalWidth == 188)
        #expect(layout(tabs: 3).naturalWidth == 274)
    }

    @Test
    func tabCentresLandWhereTheSystemPutsThem() {
        // _UITabButton centres, relative to the platter: 51, 137, 223, 309.
        let layout = layout(tabs: 4)

        #expect((0..<4).map(layout.lensCenter(at:)) == [51, 137, 223, 309])
    }

    @Test
    func theSelectionCapsuleIsTheTabBox() {
        // The system's lens is exactly its _UITabButton frame: 94x54 at y = 4.
        let lens = layout(tabs: 4).lens(at: 0)

        #expect(lens.frame == CGRect(x: 4, y: 4, width: 94, height: 54))
        #expect(lens.cornerRadius == 27)
    }

    @Test
    func tabBoxesOverlapTheWayTheSystemsDo() {
        // 94-wide boxes on an 86-point stride: 8 points of overlap. Without it
        // the capsule is a rounded square rather than the system's long capsule.
        let layout = layout(tabs: 4)

        #expect(layout.tabOverlap == 8)
        #expect(abs(layout.tabWidth / metrics.tabHeight - 94.0 / 54.0) < 0.0001)
    }

    @Test
    func aBarGivenItsNaturalWidthLandsOnTheSystemsStride() {
        // Resolving the width has to be a no-op at natural size, for any number
        // of tabs, or the responsive layout quietly stops matching the system.
        for count in 2...6 {
            let natural = layout(tabs: count).naturalWidth
            let fitted = EazyMorphingTabBarLayout(
                metrics: metrics,
                tabCount: count,
                expandedContentSize: .zero,
                hasToggle: false
            )
            .fitted(to: natural)

            #expect(fitted.barSize.width == natural)
            #expect(abs(fitted.tabStride - 86) < 0.0001)
            #expect(abs(fitted.tabWidth - 94) < 0.0001)
        }
    }

    @Test
    func aNarrowerBarCompressesTheTabsInsteadOfClippingThem() {
        // An iPhone SE offers 375 - 42 = 333 points, less than four tabs would
        // naturally take.
        let fitted = EazyMorphingTabBarLayout(
            metrics: metrics,
            tabCount: 4,
            expandedContentSize: .zero,
            hasToggle: false
        )
        .fitted(to: 333)

        #expect(fitted.barSize.width == 333)
        #expect(fitted.tabStride < 86)
        // The last tab still has to land inside the bar.
        #expect(fitted.lensCenter(at: 3) + fitted.tabWidth / 2 <= 333 - metrics.barPadding + 0.0001)
    }

    @Test
    func theToggleTakesItsRoomFromTheStripRatherThanTheScreen() {
        let width: CGFloat = 360
        let withToggle = EazyMorphingTabBarLayout(
            metrics: metrics,
            tabCount: 4,
            expandedContentSize: .zero,
            hasToggle: true
        )
        .fitted(to: width)

        // Strip plus gap plus toggle spans exactly what was offered, so the
        // assembly never overflows the screen it was given.
        #expect(withToggle.canvasSize.width == width)
        #expect(withToggle.barSize.width == width - metrics.spacing - metrics.barHeight)
    }

    @Test
    func theSymbolSitsAboveTheCentreToLeaveRoomForTheTitle() {
        // _UITabButton sits at y = 4 in the bar, so its symbol boxes - at y = 10,
        // 12, 10 and 8.67 with heights 28, 23.67, 27.67 and 32.33 - centre on
        // 20, 19.83, 19.83 and 20.83 within the box. Title box 35..47.
        #expect(metrics.symbolCenterY == 20)
        #expect(metrics.symbolCenterY < metrics.tabHeight / 2)
        #expect(metrics.labelTop + metrics.labelHeight == 47)
        #expect(metrics.tabHeight - (metrics.labelTop + metrics.labelHeight) == 7)
    }

    @Test
    func theTitleIsTheSizeTheSystemSetsIt() {
        // stackedLayoutAppearance: .SFUI-Medium 10pt normal, Semibold selected,
        // in a 12-point box.
        #expect(metrics.labelSize == 10)
        #expect(metrics.labelHeight == 12)
        #expect(metrics.showsLabels)
    }

    @Test
    func suppressingTitlesKeepsTheSystemHeight() {
        // Dropping the titles must not turn the bar into a toolbar.
        #expect(EazyMorphingTabBarMetrics.symbolsOnly.barHeight == metrics.barHeight)
        #expect(EazyMorphingTabBarMetrics.symbolsOnly.showsLabels == false)
        #expect(EazyMorphingTabBarMetrics.symbolsOnly.titlePlacement == .hidden)
    }

    @Test
    func theBarKeepsTheSystemsDistanceFromTheScreenEdge() {
        // Measured on a live UITabBarController at ten window sizes from
        // 375×667 to 1366×1024: the platter sits 21 points inside the leading,
        // trailing and bottom edges every time, in both orientations. It is a
        // constant, not a safe area inset.
        #expect(metrics.screenInset == 21)
        #expect(EazyMorphingTabBarMetrics.screenInset == 21)
    }

    /// Three tabs measure 274 points whether the screen is 375, 402, 440 or 744
    /// points wide, so a short bar takes its natural width and lets itself be
    /// centred rather than spreading to the corners.
    @Test(arguments: [2, 3])
    func aShortBarKeepsItsNaturalWidthHoweverWideTheScreen(count: Int) {
        let natural = layout(tabs: count).naturalWidth

        for available in [333.0, 360.0, 398.0, 702.0] as [CGFloat] {
            let fitted = EazyMorphingTabBarLayout(
                metrics: metrics,
                tabCount: count,
                expandedContentSize: .zero,
                hasToggle: false
            )
            .fitted(to: available)

            #expect(fitted.barSize.width == natural)
        }
        #expect(natural == (count == 2 ? 188 : 274))
    }

    /// Four tabs measure 333, 360, 398 and 702 on those same four screens, so
    /// from four upwards the bar spreads instead.
    @Test(arguments: [4, 5])
    func aLongerBarSpreadsToFillTheWidth(count: Int) {
        for available in [333.0, 360.0, 398.0, 702.0] as [CGFloat] {
            let fitted = EazyMorphingTabBarLayout(
                metrics: metrics,
                tabCount: count,
                expandedContentSize: .zero,
                hasToggle: false
            )
            .fitted(to: available)

            #expect(fitted.barSize.width == available)
        }
    }
}

@Suite("The bar on a short screen")
struct MorphingTabBarShortScreenTests {
    private let metrics = EazyMorphingTabBarMetrics.shortScreen

    private func layout(tabs: Int, tabWidth: CGFloat = 84) -> EazyMorphingTabBarLayout {
        var metrics = metrics
        let gap = metrics.tabStride - metrics.tabWidth
        metrics.tabWidth = tabWidth
        metrics.tabStride = tabWidth + gap
        return EazyMorphingTabBarLayout(
            metrics: metrics,
            tabCount: tabs,
            expandedContentSize: .zero,
            hasToggle: false
        )
    }

    @Test
    func theBarIsTheHeightTheSystemMakesItOnAShortScreen() {
        // Read off an 874×402 window: the platter is 44 points tall with its
        // buttons 36 inside it, so the padding is the same 4 as on a tall
        // screen and only the box has changed.
        #expect(metrics.barHeight == 44)
        #expect(metrics.tabHeight == 36)
        #expect(metrics.barPadding == 4)
    }

    @Test
    func theTitleMovesBesideTheSymbolAndGrows() {
        // The short arrangement is not the tall one scaled down: the title
        // leaves the space under the symbol, gains two points, and the symbol
        // gives up six.
        #expect(metrics.titlePlacement == .trailing)
        #expect(metrics.labelSize == 12)
        #expect(metrics.labelSize > EazyMorphingTabBarMetrics.standard.labelSize)
        #expect(metrics.symbolSize < EazyMorphingTabBarMetrics.standard.symbolSize)
        // Every tab measured put the title's box exactly eight points past the
        // symbol's.
        #expect(metrics.titleSpacing == 8)
    }

    @Test
    func theTabBoxesStopOverlappingAndTakeAGapInstead() {
        // Tall: 94-point boxes on an 86-point stride, overlapping by 8. Short:
        // boxes four points apart, measured as a stride 4 longer than the box
        // at every tab count from two to five.
        #expect(metrics.tabStride - metrics.tabWidth == 4)
        #expect(EazyMorphingTabBarMetrics.standard.tabStride < EazyMorphingTabBarMetrics.standard.tabWidth)
    }

    /// The system centres its short bar at every count from two tabs to five -
    /// 176.67, 268.33, 357 and 454.33 points in an 874-point window, all of them
    /// well inside it - where the tall bar spreads from four.
    @Test(arguments: [2, 3, 4, 5])
    func theShortBarNeverSpreads(count: Int) {
        let natural = layout(tabs: count).naturalWidth

        for available in [402.0, 874.0, 1366.0] as [CGFloat] {
            // Its natural width wherever it fits, and never wider - a screen
            // with room to spare must not pull the tabs apart. Somewhere too
            // narrow for it is the one case where it gives ground.
            #expect(layout(tabs: count).fitted(to: available).barSize.width == min(natural, available))
        }
    }

    @Test
    func theBarSitsAPointCloserToTheBottomOfAShortScreen() {
        // Twenty points rather than twenty-one, at every tab count measured.
        #expect(metrics.screenInset == 20)
        #expect(EazyMorphingTabBarMetrics.shortScreenInset == 20)
        #expect(metrics.screenInset < EazyMorphingTabBarMetrics.standard.screenInset)
    }

    /// A bar of four tabs 84 points wide measures 4 + 84 × 4 + 4 × 3 + 4 = 356,
    /// against the 357 the system draws for the same four titles.
    @Test
    func theBarIsTheWidthOfItsTabsAndTheGapsBetweenThem() {
        let bar = layout(tabs: 4, tabWidth: 84)
        let padding: CGFloat = 4
        let boxes: CGFloat = 84 * 4
        let gaps: CGFloat = 4 * 3
        #expect(bar.naturalWidth == padding + boxes + gaps + padding)
        #expect(abs(bar.naturalWidth - 357) <= 1)
    }
}

@Suite("The surface in morph")
struct MorphingTabBarMorphTests {
    private let metrics = EazyMorphingTabBarMetrics.standard

    private func layout(
        expandedContent: CGSize = CGSize(width: 288, height: 234)
    ) -> EazyMorphingTabBarLayout {
        EazyMorphingTabBarLayout(
            metrics: metrics,
            tabCount: 4,
            expandedContentSize: expandedContent,
            hasToggle: true
        )
        .fitted(to: 360)
    }

    @Test
    func aSurfaceAtRestIsExactlyTheStripOrExactlyThePanel() {
        let layout = layout()

        let collapsed = layout.surface(expandedBy: 0)
        #expect(collapsed.frame == layout.barRect)
        #expect(collapsed.cornerRadius == min(layout.barSize.width, layout.barSize.height) / 2)

        let expanded = layout.surface(expandedBy: 1)
        #expect(expanded.frame == layout.panelRect)
        #expect(expanded.cornerRadius == metrics.panelCornerRadius)
    }

    @Test
    func theSurfaceOvershootsTheShapeItIsGrowingInto() {
        let layout = layout()
        let panel = layout.panelSize

        // Somewhere on the way it is taller than the panel it is heading for:
        // the edge it is growing towards leads and the rest catches up, which is
        // the lens's behaviour applied to a shape that changes size.
        let tallest = stride(from: 0.0, through: 1.0, by: 0.01)
            .map { layout.surface(expandedBy: $0).frame.height }
            .max() ?? 0
        #expect(tallest > panel.height)
    }

    @Test
    func collapseKeepsShrinkingAfterItsSmallInitialAnticipation() {
        let layout = layout()
        let heights = stride(from: 0.90, through: 0.0, by: -0.01)
            .map { layout.surface(expandedBy: $0).frame.height }

        for (earlier, later) in zip(heights, heights.dropFirst()) {
            #expect(later <= earlier)
        }

        // The old direction-dependent stretch held the surface near 60% of the
        // panel from progress 0.5 down to 0.2, and even grew it along the way.
        let halfway = layout.surface(expandedBy: 0.5).frame.height
        let late = layout.surface(expandedBy: 0.2).frame.height
        #expect(late < halfway)
    }

    @Test
    func closingContentRespondsImmediatelyAndReversesContinuously() {
        let panelAtRest = EazyMorphingTabBarStretch.panelVisibility(at: 1)
        let panelAfterCloseStarts = EazyMorphingTabBarStretch.panelVisibility(at: 0.95)

        #expect(panelAtRest == 1)
        #expect(panelAfterCloseStarts < panelAtRest)
        #expect(EazyMorphingTabBarStretch.panelVisibility(at: 0.25) == 0)
        #expect(EazyMorphingTabBarStretch.stripVisibility(at: 0.45) == 0)
        #expect(EazyMorphingTabBarStretch.stripVisibility(at: 0.40) > 0)
        #expect(EazyMorphingTabBarStretch.stripVisibility(at: 0) == 1)
    }

    @Test
    func theOvershootIsSpentOnTheEdgesThatMove() {
        let layout = layout()
        // The strip and the panel share the bottom leading corner, so those two
        // edges must not move at any point in between.
        for step in stride(from: 0.0, through: 1.0, by: 0.05) {
            let surface = layout.surface(expandedBy: step)
            #expect(surface.frame.minX == 0)
            #expect(surface.frame.maxY == layout.canvasSize.height)
        }
    }

    @Test
    func theStretchIsGreatestLateInTheMorph() {
        let layout = layout()
        let bar = layout.barSize.height
        let panel = layout.panelSize.height

        // The excess over the height the surface is nominally at, which is what
        // the stretch is. The height itself goes on climbing after the stretch
        // has crested, because the surface is still growing underneath it.
        let steps = stride(from: 0.0, through: 1.0, by: 0.01).map { step -> (Double, CGFloat) in
            let nominal = bar + (panel - bar) * CGFloat(step)
            return (step, layout.surface(expandedBy: step).frame.height - nominal)
        }
        let peak = steps.max { $0.1 < $1.1 }?.0 ?? 0

        // The lens's crest, measured at 0.83 and 0.87 of the way across, not
        // halfway. The surface borrows it.
        #expect(peak > 0.7)
        #expect(abs(peak - metrics.morphStretchPeak) < 0.02)
    }

    @Test
    func aSurfaceWithNowhereToGrowDoesNotStretch() {
        // A panel no bigger than the strip is not a morph, and must not wobble.
        let layout = EazyMorphingTabBarLayout(
            metrics: metrics,
            tabCount: 4,
            expandedContentSize: .zero,
            hasToggle: false
        )
        .fitted(to: 360)

        for step in stride(from: 0.0, through: 1.0, by: 0.05) {
            #expect(layout.surface(expandedBy: step).frame.height == metrics.barHeight)
        }
    }

    @Test
    func theStretchLawIsTheOneTheLensUses() {
        // One curve, two users: it has to start and end at nothing wherever its
        // crest is put, or a shape at rest would not be its own size.
        for peak in [0.5, 0.83, 0.95] {
            #expect(EazyMorphingTabBarStretch.hump(0, peak: peak) == 0)
            #expect(abs(EazyMorphingTabBarStretch.hump(1, peak: peak)) < 1e-9)
            #expect(abs(EazyMorphingTabBarStretch.hump(peak, peak: peak) - 1) < 1e-9)
        }
    }
}

@Suite("The lens in flight")
struct MorphingTabBarLensFlightTests {
    private let metrics = EazyMorphingTabBarMetrics.standard

    private func layout(tabs: Int = 4) -> EazyMorphingTabBarLayout {
        EazyMorphingTabBarLayout(
            metrics: metrics,
            tabCount: tabs,
            expandedContentSize: .zero,
            hasToggle: false
        )
    }

    @Test
    func aLensAtRestIsExactlyOneTabWide() {
        let layout = layout()

        for index in 0..<4 {
            let lens = layout.lens(.init(resting: Double(index)))
            #expect(abs(lens.frame.width - metrics.tabWidth) < 0.0001)
            #expect(abs(lens.frame.midX - layout.lensCenter(at: index)) < 0.0001)
        }
    }

    @Test
    func aLensStretchesOnTheWayAndArrivesItsOwnLengthAgain() {
        let layout = layout()
        let journey = { (position: Double) in
            layout.lens(.init(position: position, origin: 0, destination: 3))
        }

        // Nothing at either end, so the lens is only ever elongated in transit.
        #expect(abs(journey(0).frame.width - metrics.tabWidth) < 0.0001)
        #expect(abs(journey(3).frame.width - metrics.tabWidth) < 0.0001)
        #expect(journey(1.5).frame.width > metrics.tabWidth)
    }

    @Test
    func theStretchMatchesTheSystemsAtItsPeak() {
        let layout = layout()
        // Filmed against a flat backdrop, the system's lens grows 23 points on a
        // three-tab move - 0.09 of the 254 points it covers.
        let peak = layout.lens(
            .init(position: 3 * metrics.lensStretchPeak, origin: 0, destination: 3)
        )
        let excess = peak.frame.width - metrics.tabWidth

        #expect(abs(excess - 3 * layout.tabStride * 0.09) < 0.5)
        #expect(abs(excess - 23) < 1.5)
    }

    @Test
    func theLensIsLongestLateInTheJourney() {
        let layout = layout()
        let widths = stride(from: 0.0, through: 3.0, by: 0.02).map { position in
            (position, layout.lens(.init(position: position, origin: 0, destination: 3)).frame.width)
        }
        let longest = widths.max { $0.1 < $1.1 }!

        // Not halfway: the leading edge has all but arrived before the trailing
        // edge stops gaining on it.
        #expect(abs(longest.0 / 3 - metrics.lensStretchPeak) < 0.02)
        #expect(longest.0 / 3 > 0.6)
    }

    @Test
    func theStretchIsSpentBehindTheLens() {
        let layout = layout()
        // Whichever way it is going, the leading edge stays on the lens's
        // nominal position and the trailing edge is the one that lags.
        let forward = layout.lens(.init(position: 1.5, origin: 0, destination: 3))
        let nominalForward = layout.lensCenter(at: 1.5) + layout.tabWidth / 2
        #expect(abs(forward.frame.maxX - nominalForward) < 0.0001)

        let backward = layout.lens(.init(position: 1.5, origin: 3, destination: 0))
        let nominalBackward = layout.lensCenter(at: 1.5) - layout.tabWidth / 2
        #expect(abs(backward.frame.minX - nominalBackward) < 0.0001)
    }

    @Test
    func aLongerMoveStretchesFurther() {
        let layout = layout()
        func peak(_ travel: Double) -> CGFloat {
            layout.lens(
                .init(position: travel * metrics.lensStretchPeak, origin: 0, destination: travel)
            )
            .frame.width - metrics.tabWidth
        }

        // The stretch is a fraction of the distance covered, so a hop stretches
        // less than a dash across the bar.
        #expect(peak(1) < peak(2))
        #expect(peak(2) < peak(3))
        #expect(abs(peak(3) / peak(1) - 3) < 0.01)
    }

    @Test
    func aLensThatIsNotTravellingIsNotStretched() {
        // A drag pins origin and destination together, so nothing is in flight
        // and the lens stays the width of one tab under the finger.
        let flight = EazyMorphingTabBarLensFlight(resting: 1.4)

        #expect(flight.elongation(scaledBy: metrics) == 0)
        #expect(abs(layout().lens(flight).frame.width - metrics.tabWidth) < 0.0001)
    }
}

@Suite("Liquid glass shapes")
struct LiquidGlassShapeTests {
    @Test
    func aCapsuleRoundsToHalfItsShorterSide() {
        let wide = EazyLiquidGlassShape.capsule(CGRect(x: 0, y: 0, width: 200, height: 56))

        #expect(wide.cornerRadius == 28)
    }

    @Test
    func shapesInterpolateSoTheSurfaceCanMorph() {
        var shape = EazyLiquidGlassShape.capsule(CGRect(x: 0, y: 0, width: 100, height: 50))
        let target = EazyLiquidGlassShape(
            frame: CGRect(x: 0, y: 0, width: 300, height: 200),
            cornerRadius: 32
        )

        var data = shape.animatableData
        data.scale(by: 0)
        data += {
            var half = target.animatableData
            half.scale(by: 0.5)
            return half
        }()
        var start = shape.animatableData
        start.scale(by: 0.5)
        data += start
        shape.animatableData = data

        // Halfway between the two shapes on every axis.
        #expect(shape.frame.width == 200)
        #expect(shape.frame.height == 125)
        #expect(shape.cornerRadius == 28.5)
    }
}
