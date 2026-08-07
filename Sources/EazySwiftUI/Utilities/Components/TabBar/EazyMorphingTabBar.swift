//
//  EazyMorphingTabBar.swift
//  EazySwiftUI
//

import SwiftUI

// MARK: - Title placement

/// Where a tab's title sits relative to its symbol.
///
/// The system uses both arrangements: the title goes under the symbol where
/// there is height for it, and beside it where there is not — an iPhone in
/// landscape, where the bar drops from 62 points to 44 and the tab from a
/// 94×54 box to a content-sized one 36 points tall.
public enum EazyMorphingTabBarTitlePlacement: Sendable, Equatable, CaseIterable {
    /// Under the symbol, in a fixed box. The tall arrangement.
    case below
    /// Beside the symbol, on one line. The short arrangement.
    case trailing
    /// No title at all.
    case hidden
}

// MARK: - Metrics

/// The measurements ``EazyMorphingTabBar`` lays itself out with.
///
/// The defaults are the measured geometry of the system tab bar on iOS 26, read
/// off a live `UITabBarController` laid out at 402×874 points: the bar is the
/// 62-point capsule `_UITabBarPlatterView` draws, padded by 4 on every side, and
/// each `_UITabButton` inside it is 94×54 on an 86-point stride, which is why
/// adjacent tab boxes overlap by 8. A bar of four tabs therefore measures
/// 360×62, exactly what the system draws on that screen.
///
/// Everything here is a measurement rather than a guess, with three exceptions,
/// because the system has nothing to measure against: ``spacing``,
/// ``toggleSymbolSize`` and the panel values. The system tab bar has no detached
/// toggle and no panel to expand into.
public struct EazyMorphingTabBarMetrics: Equatable, Sendable {
    /// The width of one tab box, and so of the selection lens.
    ///
    /// Wider than ``tabStride``, so neighbouring boxes overlap the way the
    /// system's do. The lens is what the extra width is for: it needs to read as
    /// a capsule around the tab, not as a column divider.
    public var tabWidth: CGFloat
    /// The distance between the centres of two tabs.
    public var tabStride: CGFloat
    /// The height of the collapsed strip, and of the toggle.
    public var barHeight: CGFloat
    /// The inset between the bar edge and the tab boxes inside it.
    public var barPadding: CGFloat
    /// The point size of a tab symbol.
    public var symbolSize: CGFloat
    /// Where the centre of a tab symbol sits, measured down from the top of the
    /// tab box.
    ///
    /// The symbol is not centred in the box: it sits well above centre — a
    /// little over a third of the way down a 54-point box — to leave the lower
    /// half to the label.
    public var symbolCenterY: CGFloat
    /// Where a tab's title sits relative to its symbol.
    public var titlePlacement: EazyMorphingTabBarTitlePlacement
    /// The point size of a tab title.
    public var labelSize: CGFloat
    /// Where the top of the title box sits, measured down from the top of the
    /// tab box. Used only when the title sits below the symbol.
    public var labelTop: CGFloat
    /// The height of the title box.
    public var labelHeight: CGFloat
    /// The gap between a symbol and a title set beside it.
    ///
    /// Eight points, read off the compact bar: the title's box starts exactly
    /// eight points past the symbol's in every tab measured.
    public var titleSpacing: CGFloat
    /// What a tab pads its content by when the title sits beside the symbol,
    /// where the tab is sized to its content rather than to a fixed width.
    ///
    /// Sixteen points: the system leaves six before the symbol and ten after
    /// the title. They are added together rather than kept apart because these
    /// tabs are laid out at one width — see ``EazyMorphingTabBarLayout``.
    public var tabPadding: CGFloat
    /// The gap between the strip and the toggle.
    public var spacing: CGFloat
    /// The point size of the toggle symbol.
    public var toggleSymbolSize: CGFloat
    /// The inset between the panel edge and its content.
    public var panelPadding: CGFloat
    /// The corner radius of the expanded panel.
    public var panelCornerRadius: CGFloat
    /// The number of columns in the built-in action grid.
    public var columns: Int
    /// The size of one cell of the built-in action grid.
    public var cellSize: CGSize
    /// How much of the bar's glass the selection thins away, from none to all.
    ///
    /// The selection is clear glass set into frosted glass, not a second pane
    /// laid on top: taking material away is what lets the backdrop through and
    /// makes the capsule read as translucent.
    public var lensClearing: Double
    /// How far the rim of the selection lens pulls its sample, in points.
    public var lensRefraction: CGFloat
    /// How far into the selection lens the refraction reaches, in points.
    ///
    /// Kept shallow enough that the rim stops short of the symbol: the tab
    /// symbol's top sits about six points inside the lens, and a deeper reach
    /// bends the symbol itself rather than the glass around it.
    public var lensDepth: CGFloat
    /// How far apart the lens bends the color channels.
    ///
    /// Off here. Dispersion is what fringes an edge with colour, and a tab
    /// symbol is nothing but hard edges: the rim reaches the top of the tallest
    /// symbols — `square.stack` clears the lens by under four points — and any
    /// dispersion at all left a green line along the top of them. Refraction on
    /// its own displaces the symbol without tinting it, which is what glass over
    /// a solid shape actually does.
    public var lensDispersion: Double
    /// How far the lens stretches on its way between tabs, as a fraction of the
    /// distance it travels.
    ///
    /// The system's lens does not slide rigidly: it lengthens along its path and
    /// relaxes as it lands, because its trailing edge lags behind its leading
    /// one. Filmed against a flat backdrop and measured across the band above
    /// the symbols, a lens 98 points wide reaches 121 at the peak of a
    /// three-tab, 254-point move — 23 points, or 0.09 of the distance covered.
    /// Its height does not change, so this is a stretch and not a scale.
    public var lensStretch: Double
    /// Where in the journey the lens is at its longest, from start to finish.
    ///
    /// Not halfway: the leading edge has all but arrived before the trailing
    /// edge stops gaining on it, so the lens is longest at about five sixths of
    /// the way across. Measured at 0.83 and 0.87 in two recordings of the same
    /// move.
    public var lensStretchPeak: Double
    /// How far the bar sits from the leading, trailing and bottom edges of the
    /// screen.
    ///
    /// A flat 21 points, which is what the system uses at every width from a
    /// 320-point phone to a 1366-point iPad, in both orientations. It is not
    /// derived from the safe area, and the safe area never binds: there is no
    /// horizontal safe area in portrait, and in landscape the bar centres itself
    /// far inside one.
    public var screenInset: CGFloat
    /// The tab count from which the bar stops centring and spreads to fill the
    /// width it is given.
    ///
    /// Below it the bar takes its natural width and centres, so two or three
    /// tabs are not flung to the corners of a large screen; from it the bar
    /// fills. The system switches at four: three tabs measure 274 points on a
    /// 375, 402, 440 and 744-point screen alike, while four tabs measure 333,
    /// 360, 398 and 702 on those same screens.
    ///
    /// A bar that never spreads takes `Int.max`, which is what the short-screen
    /// arrangement uses: in landscape the system centres its bar at every count
    /// from two tabs to five.
    public var spreadsFrom: Int
    /// How far the surface overshoots the shape it is growing into, as a
    /// fraction of the distance the moving edge travels.
    ///
    /// The panel is one of the few things here with nothing to measure against,
    /// because the system tab bar has no panel to expand into. The *law* is
    /// measured, though: it is the lens's, so the surface leads with the edge it
    /// is growing towards and lets the rest catch up, and it is exactly its own
    /// size again at both ends. Only the size of the effect is a choice.
    ///
    /// The crest sits four fifths of the way along, by which point the surface
    /// has only a fifth of its journey left, so a fraction of the distance
    /// travelled spends most of itself catching up with the growth rather than
    /// leading it: at 0.45, the moving edge leads by 45 points in every hundred
    /// it has to cover, and about a tenth of the change is left over as visible
    /// overshoot past the shape it is settling into. Set it to zero for a
    /// surface that resizes rather than stretches.
    public var morphStretch: Double
    /// Where in the morph the surface is at its most stretched.
    ///
    /// The lens's, measured: a little over four fifths of the way, not halfway.
    public var morphStretchPeak: Double

    public init(
        tabWidth: CGFloat = 94,
        tabStride: CGFloat = 86,
        barHeight: CGFloat = 62,
        barPadding: CGFloat = 4,
        symbolSize: CGFloat = 24,
        symbolCenterY: CGFloat = 20,
        titlePlacement: EazyMorphingTabBarTitlePlacement = .below,
        labelSize: CGFloat = 10,
        labelTop: CGFloat = 35,
        labelHeight: CGFloat = 12,
        titleSpacing: CGFloat = 8,
        tabPadding: CGFloat = 16,
        spacing: CGFloat = 10,
        toggleSymbolSize: CGFloat = 20,
        panelPadding: CGFloat = 6,
        panelCornerRadius: CGFloat = 32,
        columns: Int = 4,
        cellSize: CGSize = CGSize(width: 72, height: 78),
        lensClearing: Double = 0.34,
        lensRefraction: CGFloat = 4,
        lensDepth: CGFloat = 5,
        lensDispersion: Double = 0,
        lensStretch: Double = 0.09,
        lensStretchPeak: Double = 0.83,
        screenInset: CGFloat = EazyMorphingTabBarMetrics.screenInset,
        spreadsFrom: Int = 4,
        morphStretch: Double = 0.45,
        morphStretchPeak: Double = 0.83
    ) {
        self.tabWidth = tabWidth
        self.tabStride = tabStride
        self.barHeight = barHeight
        self.barPadding = barPadding
        self.symbolSize = symbolSize
        self.symbolCenterY = symbolCenterY
        self.titlePlacement = titlePlacement
        self.labelSize = labelSize
        self.labelTop = labelTop
        self.labelHeight = labelHeight
        self.titleSpacing = titleSpacing
        self.tabPadding = tabPadding
        self.spacing = spacing
        self.toggleSymbolSize = toggleSymbolSize
        self.panelPadding = panelPadding
        self.panelCornerRadius = panelCornerRadius
        self.columns = max(columns, 1)
        self.cellSize = cellSize
        self.lensClearing = min(max(lensClearing, 0), 1)
        self.lensRefraction = lensRefraction
        self.lensDepth = lensDepth
        self.lensDispersion = lensDispersion
        self.lensStretch = max(lensStretch, 0)
        self.lensStretchPeak = min(max(lensStretchPeak, 0.01), 0.99)
        self.screenInset = screenInset
        self.spreadsFrom = max(spreadsFrom, 1)
        self.morphStretch = max(morphStretch, 0)
        self.morphStretchPeak = min(max(morphStretchPeak, 0.01), 0.99)
    }

    /// The height of a tab box: the bar, less its padding.
    public var tabHeight: CGFloat { barHeight - barPadding * 2 }

    /// Whether tabs show their title at all.
    public var showsLabels: Bool { titlePlacement != .hidden }

    /// How far the system insets its tab bar from the leading, trailing and
    /// bottom edges of the screen.
    ///
    /// A flat 21 points. Reading a live `UITabBarController` laid out at ten
    /// window sizes from 375×667 to 1366×1024 puts the platter 21 points inside
    /// the leading, trailing and bottom edges every time, whatever the width and
    /// whichever the orientation.
    ///
    /// The bar applies it to its own sides, so placing one needs only the bottom:
    /// the system bar is not laid out against the bottom safe area either, but
    /// stops 21 points above the screen's bottom edge, overlapping the home
    /// indicator.
    public static let screenInset: CGFloat = 21

    /// How far the system insets its tab bar from the bottom of a short screen.
    ///
    /// Twenty points rather than the twenty-one it uses on a tall one, measured
    /// on an 874×402 window at every tab count from two to five.
    public static let shortScreenInset: CGFloat = 20

    /// The default measurements: those of the system tab bar.
    public static let standard = EazyMorphingTabBarMetrics()

    /// Symbols only, with the labels suppressed.
    ///
    /// The bar keeps the system's height, so it still reads as a tab bar rather
    /// than as a toolbar; the symbols centre themselves in the space the labels
    /// leave behind.
    public static let symbolsOnly = EazyMorphingTabBarMetrics(titlePlacement: .hidden)

    /// The bar the system draws where the screen is too short for the standard
    /// one — an iPhone in landscape.
    ///
    /// Read off a live `UITabBarController` in an 874×402 window at every tab
    /// count from two to five. Nothing about this arrangement is a smaller copy
    /// of the tall one: the bar drops from 62 points to 44 and the tab box from
    /// 94×54 to 36 points tall, the title moves out from under the symbol to
    /// beside it and *grows* from 10 points to 12 while the symbol shrinks, the
    /// tab boxes stop overlapping and take a four-point gap instead, and the bar
    /// centres at its natural width however many tabs it has, where the tall one
    /// spreads from four.
    ///
    /// The symbol size is the one measurement here that had to be inferred
    /// rather than read: the system reports the same symbol image in both
    /// arrangements and resizes the view around it, so the point size was taken
    /// from the ink instead. The rendered `house.fill` measures 24.00 points
    /// tall on a tall screen and 17.67 on a short one, and `bell.fill` 23.67 and
    /// 17.67 — 0.736 and 0.747 of the tall size, which puts the short symbol at
    /// 17.7 to 17.9 points against the tall one's 24. Eighteen is the nearest
    /// whole point, and the two derivations are half a point apart, so a whole
    /// point is as fine as the measurement warrants.
    public static let shortScreen = EazyMorphingTabBarMetrics(
        // A placeholder pair, replaced by the width of the widest tab once the
        // bar has measured its own titles; the gap between them is what matters
        // and is held to the measured four points. The system's own tabs run
        // from 81 to 93 points wide over the titles measured.
        tabWidth: 84,
        tabStride: 88,
        barHeight: 44,
        symbolSize: 18,
        titlePlacement: .trailing,
        labelSize: 12,
        labelHeight: 14.33,
        screenInset: EazyMorphingTabBarMetrics.shortScreenInset,
        spreadsFrom: .max
    )
}

// MARK: - Layout

/// Every rectangle the bar draws, in the coordinate space of its canvas.
///
/// The canvas is anchored to the bottom leading corner: the strip and the panel
/// share that corner, so expanding grows the surface upwards and leaves the
/// toggle where the eye already found it.
struct EazyMorphingTabBarLayout {
    let metrics: EazyMorphingTabBarMetrics
    let tabCount: Int
    let expandedContentSize: CGSize
    /// The width the strip has to fill. Nil takes the natural width, which is
    /// what the strip measures when nothing constrains it.
    let barWidth: CGFloat?
    /// Whether a toggle sits beside the strip and has to be left room for.
    let hasToggle: Bool

    init(
        metrics: EazyMorphingTabBarMetrics,
        tabCount: Int,
        expandedContentSize: CGSize,
        barWidth: CGFloat? = nil,
        hasToggle: Bool = true
    ) {
        self.metrics = metrics
        self.tabCount = tabCount
        self.expandedContentSize = expandedContentSize
        self.barWidth = barWidth
        self.hasToggle = hasToggle
    }

    /// The layout for a canvas of `width`, with the strip taking what the toggle
    /// leaves it.
    ///
    /// A bar of few tabs keeps its natural width and lets the canvas centre it,
    /// rather than spreading two tabs across a large screen; from
    /// ``EazyMorphingTabBarMetrics/spreadsFrom`` tabs upwards it fills instead.
    /// That is the system's own rule: three tabs measure 274 points whether the
    /// screen is 375 or 744 points wide, while four tabs measure 333 on the
    /// first and 702 on the second.
    func fitted(to width: CGFloat) -> EazyMorphingTabBarLayout {
        let natural = EazyMorphingTabBarLayout(
            metrics: metrics,
            tabCount: tabCount,
            expandedContentSize: expandedContentSize,
            barWidth: nil,
            hasToggle: hasToggle
        )
        guard width > 0 else { return natural }

        let available = width - natural.toggleAllowance
        let spreads = tabCount >= metrics.spreadsFrom
        let resolved = spreads ? available : min(natural.naturalWidth, available)
        return EazyMorphingTabBarLayout(
            metrics: metrics,
            tabCount: tabCount,
            expandedContentSize: expandedContentSize,
            barWidth: max(resolved, metrics.barHeight),
            hasToggle: hasToggle
        )
    }

    private var tabs: CGFloat { CGFloat(max(tabCount, 1)) }

    /// How far a tab box hangs over its neighbour's.
    ///
    /// Held constant as the bar resizes: it is the one part of the tab geometry
    /// that is about the shape of the selection capsule rather than about how
    /// much room there is, so stretching the bar must not stretch it.
    var tabOverlap: CGFloat { metrics.tabWidth - metrics.tabStride }

    /// The width the strip takes when nothing constrains it.
    ///
    /// The tab boxes sit on a stride narrower than themselves, so the strip is
    /// one box wide plus a stride for every tab after the first — not one box
    /// per tab. This is what makes four tabs measure 360 points rather than 384.
    var naturalWidth: CGFloat {
        metrics.barPadding * 2 + metrics.tabWidth + (tabs - 1) * metrics.tabStride
    }

    var barSize: CGSize {
        CGSize(width: barWidth ?? naturalWidth, height: metrics.barHeight)
    }

    /// The box the tabs are laid out in: the bar, less its padding.
    var contentWidth: CGFloat { max(barSize.width - metrics.barPadding * 2, 0) }

    /// The distance between the centres of two tabs at the resolved width.
    ///
    /// From `content = width + (n - 1) · stride` and `width = stride + overlap`,
    /// so that a bar given exactly its natural width lands back on the system's
    /// 86-point stride for any number of tabs.
    var tabStride: CGFloat { max((contentWidth - tabOverlap) / tabs, 1) }

    /// The width of one tab box, and so of the selection capsule.
    var tabWidth: CGFloat { tabStride + tabOverlap }

    /// The inset from the bar edge to the first tab's hit area.
    ///
    /// Tab boxes overlap, so their hit areas are one stride wide and centred in
    /// the box; the leftover half-overlap pads the strip.
    var stripPadding: CGFloat { metrics.barPadding + tabOverlap / 2 }

    var panelSize: CGSize {
        CGSize(
            width: max(barSize.width, expandedContentSize.width + metrics.panelPadding * 2),
            height: max(metrics.barHeight, expandedContentSize.height + metrics.panelPadding * 2)
        )
    }

    /// What the toggle costs the strip: nothing at all when there is no toggle,
    /// which is the case that can match the system bar exactly, since the system
    /// has no second control beside its own.
    var toggleAllowance: CGFloat {
        hasToggle ? metrics.spacing + metrics.barHeight : 0
    }

    var canvasSize: CGSize {
        CGSize(
            width: max(barSize.width, panelSize.width) + toggleAllowance,
            height: max(barSize.height, panelSize.height)
        )
    }

    /// The footprint the bar occupies in its parent. The panel is drawn outside
    /// it, so expanding never reflows the surrounding layout.
    var collapsedSize: CGSize {
        CGSize(width: canvasSize.width, height: metrics.barHeight)
    }

    var barRect: CGRect {
        CGRect(
            x: 0,
            y: canvasSize.height - barSize.height,
            width: barSize.width,
            height: barSize.height
        )
    }

    var panelRect: CGRect {
        CGRect(
            x: 0,
            y: canvasSize.height - panelSize.height,
            width: panelSize.width,
            height: panelSize.height
        )
    }

    var toggleRect: CGRect {
        CGRect(
            x: max(barSize.width, panelSize.width) + metrics.spacing,
            y: canvasSize.height - metrics.barHeight,
            width: metrics.barHeight,
            height: metrics.barHeight
        )
    }

    // MARK: The surface in flight

    /// How far past the panel the surface can reach before it settles.
    ///
    /// The glass is drawn into a layer, and a layer only draws what fits in it:
    /// without this the surface was quietly clipped to the panel, so every part
    /// of the morph that went beyond it — the crest of the stretch, and the
    /// spring's own overshoot — was cut off, and the shape arrived dead against
    /// a hard stop instead of settling back.
    ///
    /// Two things can carry it past: the crest of the stretch, which sits at
    /// ``EazyMorphingTabBarMetrics/morphStretchPeak`` of the way with
    /// ``EazyMorphingTabBarMetrics/morphStretch`` of the distance added on top,
    /// and the spring, which carries the progress a little past one on its own.
    /// The larger of the two, less the journey itself, is the room needed.
    var stretchHeadroom: CGSize {
        let reach = max(metrics.morphStretchPeak + metrics.morphStretch, 1.25) - 1
        return CGSize(
            width: abs(panelSize.width - barSize.width) * CGFloat(reach),
            height: abs(panelSize.height - barSize.height) * CGFloat(reach)
        )
    }

    /// The bar's outline part way between the strip and the panel, stretched by
    /// however much of the change is behind it.
    ///
    /// The strip and the panel share the bottom leading corner, so the only
    /// edges that move are the top and the trailing one — the surface grows
    /// upwards and to the right and leaves the toggle where the eye found it.
    ///
    /// Those moving edges lead. The extra length is spent on them and on nothing
    /// else, exactly as the lens spends its own on the edge it is chasing, so
    /// the surface arrives fractionally over-grown and settles back rather than
    /// sliding between two rectangles. Both ends are clean: the hump starts and
    /// finishes at nothing, so a collapsed bar is exactly the strip and an
    /// expanded one exactly the panel.
    ///
    /// The crest belongs to the journey rather than to the coordinate, which is
    /// why the direction has to be passed in. A lens is longest four fifths of
    /// the way to wherever it is going; so is this, whether that is the panel or
    /// the strip. Reading the crest off the progress alone would put it four
    /// fifths of the way *open* in both directions — a fifth of the way into a
    /// collapse, which is far too early to be a lag.
    func surface(expandedBy progress: Double, expanding: Bool) -> EazyLiquidGlassShape {
        // The progress is deliberately not clamped where it is interpolated.
        // The morph is a spring, and a spring's overshoot past its destination
        // and back is the bounce; clamping it to one threw the bounce away and
        // left the surface arriving dead against a hard stop.
        //
        // The stretch is clamped, because it is a single hump over a journey and
        // has to be nothing at both ends whatever the spring does around them.
        let journey = min(max(expanding ? progress : 1 - progress, 0), 1)
        let stretch = CGFloat(
            EazyMorphingTabBarStretch.hump(journey, peak: metrics.morphStretchPeak)
                * metrics.morphStretch
        )
        let bar = barSize
        let panel = panelSize
        let grown = { (from: CGFloat, to: CGFloat) -> CGFloat in
            from + (to - from) * CGFloat(progress) + abs(to - from) * stretch
        }
        let width = max(grown(bar.width, panel.width), 0)
        let height = max(grown(bar.height, panel.height), 0)
        let capsuleRadius = min(bar.width, bar.height) / 2
        return EazyLiquidGlassShape(
            frame: CGRect(
                x: 0,
                y: canvasSize.height - height,
                width: width,
                height: height
            ),
            cornerRadius: capsuleRadius
                + (metrics.panelCornerRadius - capsuleRadius) * CGFloat(min(max(progress, 0), 1))
        )
    }

    // MARK: Strip geometry

    /// The index of the tab under a point in the strip, clamped to the strip so
    /// a drag that runs past either end keeps the last tab it reached.
    ///
    /// Boxes overlap, so a point can fall inside two of them; the nearer centre
    /// wins, which puts the boundary exactly halfway between two tabs.
    func tabIndex(at x: CGFloat) -> Int {
        let offset = (x - lensCenter(at: 0)) / tabStride
        return min(max(Int(offset.rounded()), 0), max(tabCount - 1, 0))
    }

    /// The centre of the lens when it rests on a tab.
    func lensCenter(at index: Int) -> CGFloat {
        lensCenter(at: Double(index))
    }

    /// The centre of the lens at a fractional position between tabs, which is
    /// where it sits for all but the two instants at either end of a move.
    func lensCenter(at position: Double) -> CGFloat {
        let clamped = min(max(position, 0), Double(max(tabCount - 1, 0)))
        return metrics.barPadding
            + tabWidth / 2
            + CGFloat(clamped) * tabStride
    }

    /// The centre of the lens while a drag carries it, never leaving the strip.
    func lensCenter(draggedTo x: CGFloat) -> CGFloat {
        min(max(x, lensCenter(at: 0)), lensCenter(at: tabCount - 1))
    }

    /// Where a point in the strip falls, as a fractional tab position.
    func lensPosition(draggedTo x: CGFloat) -> Double {
        guard tabStride > 0 else { return 0 }
        let offset = (lensCenter(draggedTo: x) - lensCenter(at: 0)) / tabStride
        return min(max(Double(offset), 0), Double(max(tabCount - 1, 0)))
    }

    /// The lens itself, resting on `index`.
    ///
    /// The lens is the tab box, not an inset of it: the system's selection
    /// capsule is exactly its `_UITabButton` frame, which is what gives it its
    /// long, flat shape instead of the rounded square an inset would produce.
    func lens(at index: Int) -> EazyLiquidGlassShape {
        lens(EazyMorphingTabBarLensFlight(resting: Double(index)))
    }

    /// The lens part way through a move, stretched by however much of the
    /// journey is behind it.
    ///
    /// The stretch is spent backwards, along the path already travelled: the
    /// leading edge stays on the lens's nominal position and the trailing edge
    /// trails it, which is what the system's does. Read off a recording, its
    /// leading edge is within a point and a half of home while its trailing edge
    /// is still eleven points short.
    func lens(_ flight: EazyMorphingTabBarLensFlight) -> EazyLiquidGlassShape {
        guard tabCount > 0 else { return .none }
        let center = lensCenter(at: flight.position)
        let stretch = CGFloat(flight.elongation(scaledBy: metrics)) * tabStride
        let leading = center + flight.direction * tabWidth / 2
        let trailing = center - flight.direction * (tabWidth / 2 + stretch)
        return .capsule(
            CGRect(
                x: min(leading, trailing),
                y: metrics.barPadding,
                width: abs(leading - trailing),
                height: metrics.tabHeight
            )
        )
    }
}

// MARK: - Stretch

/// The shape of a stretch, shared by everything here that changes shape.
///
/// The system's glass does not travel rigidly between two states: it leads with
/// the edge it is heading for and lets the far edge catch up, so it is longer
/// part way than at either end. One curve describes that, and both the selection
/// lens and the panel are drawn with it.
enum EazyMorphingTabBarStretch {
    /// A single hump over a journey, from nothing at the start to nothing at the
    /// end, cresting at `peak`.
    ///
    /// Raising the progress to an exponent before taking the sine moves the
    /// crest without disturbing either end. The exponent is whatever sends
    /// `peak` to the half-way point of the sine, which is where its maximum is.
    static func hump(_ progress: Double, peak: Double) -> Double {
        let travelled = min(max(progress, 0), 1)
        let crest = min(max(peak, 0.01), 0.99)
        return sin(.pi * pow(travelled, log(0.5) / log(crest)))
    }

    /// A fade that runs over one stretch of the morph and is flat either side.
    ///
    /// What the bar's two sets of contents need is not a crossfade. Fading one
    /// out while the other fades in leaves both at half strength through the
    /// middle, and two rows of labels at half strength on top of each other read
    /// as a smear rather than as one thing becoming another. So the strip is
    /// given the opening of the morph to leave in, and the panel's contents the
    /// rest to arrive in, and they never share the glass.
    ///
    /// Smoothstepped, so neither end of a fade is a corner.
    static func ramp(_ progress: Double, from start: Double, to end: Double) -> Double {
        guard end > start else { return progress >= end ? 1 : 0 }
        let travelled = min(max((progress - start) / (end - start), 0), 1)
        return travelled * travelled * (3 - 2 * travelled)
    }
}

// MARK: - Lens flight

/// The lens part way between two tabs.
///
/// Only ``position`` is animated. The two ends of the journey ride along
/// unanimated, because they are not a place the lens passes through — they are
/// what tells it how far it has come, and so how far it should be stretched.
///
/// The stretch is the whole point of the type. The system's lens does not slide
/// rigidly from one tab to the next: it lengthens along its path and relaxes as
/// it lands, because its trailing edge lags behind its leading one. Filmed
/// against a flat backdrop, a lens 98 points wide reaches 121 at the peak of a
/// three-tab move and returns to 98 on arrival, with its height unchanged
/// throughout — a stretch, not a scale, and one that neither `bounds` nor
/// `transform` on the system's own view ever reports, because it is drawn in the
/// shader.
struct EazyMorphingTabBarLensFlight: Equatable {
    /// Where the lens is now, as a fractional tab position.
    var position: Double
    /// Where this journey began, and where it ends.
    var origin: Double
    var destination: Double

    init(position: Double, origin: Double, destination: Double) {
        self.position = position
        self.origin = origin
        self.destination = destination
    }

    /// A lens sitting still on a tab, which is every moment but a move.
    init(resting position: Double) {
        self.init(position: position, origin: position, destination: position)
    }

    /// Which way the lens is heading. A lens at rest points forwards, so that a
    /// zero stretch is spent in a well-defined direction.
    var direction: CGFloat { destination < origin ? -1 : 1 }

    /// Whether the lens was thrown at a tab rather than put where it is.
    ///
    /// A dragged lens has both ends of its journey pinned to where the finger
    /// is, so it neither stretches nor eases: it goes exactly where it is put,
    /// the moment it is put there.
    var isTravelling: Bool { origin != destination }

    /// How far through the journey the lens is, from nothing to all of it.
    var progress: Double {
        let travel = destination - origin
        guard travel != 0 else { return 1 }
        return min(max((position - origin) / travel, 0), 1)
    }

    /// How much longer than one tab the lens is right now, in tabs.
    ///
    /// A single hump that starts and ends at nothing, so the lens is exactly one
    /// tab wide whenever it is at rest. The exponent places the peak: raising
    /// the progress to it before taking the sine moves the crest late without
    /// disturbing either end, which is what the recordings show — the lens is
    /// longest at about five sixths of the way across, not halfway, because the
    /// leading edge has all but arrived before the trailing edge stops gaining.
    func elongation(scaledBy metrics: EazyMorphingTabBarMetrics) -> Double {
        let travel = abs(destination - origin)
        guard travel > 0, metrics.lensStretch > 0 else { return 0 }
        return EazyMorphingTabBarStretch.hump(progress, peak: metrics.lensStretchPeak)
            * travel
            * metrics.lensStretch
    }
}

// MARK: - Tab bar

/// A floating tab bar that morphs into a panel of actions.
///
/// Collapsed, it is a strip of tabs and a round toggle beside it. Tapping the
/// toggle grows the strip upwards into a panel and turns the toggle into a close
/// button; the two shapes are one body of glass that merges and separates as
/// they move.
///
/// ```swift
/// @State private var selection = "house"
/// @State private var isExpanded = false
///
/// var body: some View {
///     ContentView()
///         .safeAreaInset(edge: .bottom) {
///             EazyMorphingTabBar(
///                 tabs: [
///                     EazyTab(systemImage: "house", title: "Home"),
///                     EazyTab(systemImage: "tray", title: "Inbox"),
///                     EazyTab(systemImage: "bell", title: "Activity"),
///                     EazyTab(systemImage: "square.stack", title: "Library")
///                 ],
///                 selection: $selection,
///                 isExpanded: $isExpanded,
///                 actions: [
///                     EazyTabBarAction(systemImage: "scissors", title: "Trim") { trim() },
///                     EazyTabBarAction(systemImage: "crop", title: "Crop") { crop() }
///                 ]
///             )
///         }
/// }
/// ```
///
/// The glass is drawn by ``EazyLiquidGlassShape`` and a Metal shader rather than
/// by the system material, so the bar looks and behaves the same from iOS 18 and
/// macOS 15 onwards.
public struct EazyMorphingTabBar<Expanded: View>: View {
    private let tabs: [EazyTab]
    @Binding private var selection: EazyTab.ID
    @Binding private var isExpanded: Bool
    private let tint: Color
    private let metrics: EazyMorphingTabBarMetrics
    private let shortScreenMetrics: EazyMorphingTabBarMetrics?
    private let style: EazyLiquidGlassStyle
    private let expandSymbol: String
    private let collapseSymbol: String
    private let expandLabel: LocalizedStringResource
    private let collapseLabel: LocalizedStringResource
    private let morphAnimation: Animation
    private let selectionAnimation: Animation
    private let showsToggle: Bool
    private let expandedContent: () -> Expanded

    @State private var expandedContentSize: CGSize = .zero
    @State private var availableWidth: CGFloat = 0
    /// Where the lens is, and how far through a move.
    ///
    /// Held here rather than in the strip because the lens is cut out of the
    /// bar's glass, which is drawn at this level.
    @State private var flight = EazyMorphingTabBarLensFlight(resting: 0)
    /// The width of the widest tab laid out at its ideal size, for the short
    /// arrangement, where a tab is as wide as its title rather than a fixed box.
    @State private var widestTab: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    #if os(iOS) || os(tvOS) || os(visionOS)
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif
    /// Titles are set in a fixed 10-point font, but their box has to grow with
    /// the reader's text size, and the bar with it.
    @ScaledMetric(relativeTo: .caption2) private var labelHeightScale: CGFloat = 1

    /// Creates a bar that expands into a view of your own.
    ///
    /// - Parameters:
    ///   - tabs: The items in the strip, in leading-to-trailing order.
    ///   - selection: The identifier of the selected tab.
    ///   - isExpanded: Whether the panel is showing.
    ///   - tint: The color of the selected tab symbol and the toggle symbol.
    ///   - metrics: The measurements the bar lays itself out with.
    ///   - shortScreenMetrics: The measurements to use where the screen is too
    ///     short for `metrics` — an iPhone in landscape. The system swaps
    ///     arrangements there rather than shrinking the one it has, so the bar
    ///     does too. Nil keeps `metrics` at every size.
    ///   - style: How the glass is lit and blurred.
    ///   - expandSymbol: The toggle symbol while collapsed.
    ///   - collapseSymbol: The toggle symbol while expanded.
    ///   - expandLabel: The toggle accessibility label while collapsed.
    ///   - collapseLabel: The toggle accessibility label while expanded.
    ///   - morphAnimation: How the surface travels between its two shapes.
    ///     Ignored when Reduce Motion is on.
    ///   - selectionAnimation: How the lens travels between tabs. Ignored when
    ///     Reduce Motion is on.
    ///   - showsToggle: Whether the round button that opens the panel sits beside
    ///     the strip. Without it the strip takes the whole width, which is what
    ///     lets the bar match the system's exactly.
    ///   - expandedContent: The content of the panel. It is measured at its
    ///     ideal size, which the panel then takes.
    public init(
        tabs: [EazyTab],
        selection: Binding<EazyTab.ID>,
        isExpanded: Binding<Bool>,
        tint: Color = .accentColor,
        metrics: EazyMorphingTabBarMetrics = .standard,
        shortScreenMetrics: EazyMorphingTabBarMetrics? = .shortScreen,
        style: EazyLiquidGlassStyle = .tabBar,
        expandSymbol: String = "plus",
        collapseSymbol: String = "xmark",
        expandLabel: LocalizedStringResource = "More",
        collapseLabel: LocalizedStringResource = "Close",
        morphAnimation: Animation = .bouncy(duration: 0.75, extraBounce: 0.02),
        selectionAnimation: Animation = .spring(duration: 0.4, bounce: 0.15),
        showsToggle: Bool = true,
        @ViewBuilder expandedContent: @escaping () -> Expanded
    ) {
        self.tabs = tabs
        self._selection = selection
        self._isExpanded = isExpanded
        self.tint = tint
        self.metrics = metrics
        self.shortScreenMetrics = shortScreenMetrics
        self.style = style
        self.expandSymbol = expandSymbol
        self.collapseSymbol = collapseSymbol
        self.expandLabel = expandLabel
        self.collapseLabel = collapseLabel
        self.morphAnimation = morphAnimation
        self.selectionAnimation = selectionAnimation
        self.showsToggle = showsToggle
        self.expandedContent = expandedContent
    }

    public var body: some View {
        let layout = self.layout

        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: layout.collapsedSize.height)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.width
            } action: { newValue in
                availableWidth = newValue
            }
            // Centred, not pinned to the leading edge: a bar narrower than the
            // room it is given sits in the middle, which is where the system
            // puts one that does not spread.
            .overlay(alignment: .bottom) {
                canvas(layout)
            }
            // The bar insets itself, so placing one needs nothing but the edge
            // it goes against. The measurement is the system's: 21 points off
            // the leading and trailing edges at every screen width.
            .padding(.horizontal, activeMetrics.screenInset)
            .onChange(of: selectedIndex, initial: true) { previous, current in
                travel(from: previous, to: current)
            }
    }

    /// The arrangement for the screen the bar is on.
    ///
    /// The system does not shrink its tall bar to fit a short screen; it lays
    /// out a different one, 44 points instead of 62 with the title beside the
    /// symbol rather than under it. So neither does this.
    private var activeMetrics: EazyMorphingTabBarMetrics {
        #if os(iOS) || os(tvOS) || os(visionOS)
        if verticalSizeClass == .compact, let shortScreenMetrics {
            return shortScreenMetrics
        }
        #endif
        return metrics
    }

    /// Where the selection sits in the strip.
    private var selectedIndex: Int {
        tabs.firstIndex { $0.id == selection } ?? 0
    }

    /// Sends the lens off to a new tab, stretching on the way.
    ///
    /// The journey's two ends are recorded alongside the position because the
    /// stretch is a function of how far along the lens is, and neither end can
    /// be recovered from the position alone once it is moving.
    ///
    /// The move is not wrapped in `withAnimation`. The animation is attached
    /// where the flight is read instead, by ``lensAnimation``, so that the two
    /// views that draw the lens interpolate it identically; handing it over
    /// imperatively left them free to disagree, and the lens crossed the bar in
    /// a couple of frames.
    private func travel(from previous: Int, to current: Int) {
        guard !reduceMotion, previous != current else {
            flight = .init(resting: Double(current))
            return
        }
        flight = .init(
            position: flight.position,
            origin: flight.position,
            destination: Double(current)
        )
        flight.position = Double(current)
    }

    /// How the lens crosses the bar, and nothing at all when a finger is
    /// carrying it: a dragged lens is already where it was put.
    private var lensAnimation: Animation? {
        guard !reduceMotion, flight.isTravelling else { return nil }
        return selectionAnimation
    }

    /// The bar sized to whatever width it was handed, so it tracks the device
    /// rather than a screen it was measured on. Before the first layout pass has
    /// reported a width, it falls back to its natural size.
    private var layout: EazyMorphingTabBarLayout {
        EazyMorphingTabBarLayout(
            metrics: scaledMetrics,
            tabCount: tabs.count,
            expandedContentSize: expandedContentSize,
            hasToggle: showsToggle
        )
        .fitted(to: availableWidth)
    }

    /// The lens, in the canvas's coordinate space, where the glass is drawn.
    private func lens(_ layout: EazyMorphingTabBarLayout, _ flight: EazyMorphingTabBarLensFlight) -> EazyLiquidGlassShape {
        var shape = layout.lens(flight)
        // The strip's own space starts at the bar's origin inside the canvas.
        shape.frame.origin.y += layout.barRect.minY
        return shape
    }

    /// The metrics with the title box grown to the reader's text size, and the
    /// bar grown by the same amount so the title keeps its footing — and, where
    /// tabs are as wide as their titles, with the width the titles turned out to
    /// need.
    ///
    /// The measured width only ever comes from the tabs' own ideal sizes, never
    /// from the bar's, so reading it back here cannot feed on itself.
    private var scaledMetrics: EazyMorphingTabBarMetrics {
        var scaled = activeMetrics

        if scaled.titlePlacement == .trailing, widestTab > 0 {
            // Boxes here sit apart rather than overlapping, and that gap is the
            // measurement worth keeping while the width itself is whatever the
            // titles came to.
            let gap = scaled.tabStride - scaled.tabWidth
            scaled.tabWidth = widestTab
            scaled.tabStride = widestTab + gap
        }

        guard scaled.showsLabels, labelHeightScale > 1 else { return scaled }
        let growth = scaled.labelHeight * (labelHeightScale - 1)
        scaled.labelHeight += growth
        // A title beside the symbol grows into the bar's height, not past it:
        // the box is already taller than the line it holds.
        if scaled.titlePlacement == .below {
            scaled.barHeight += growth
        }
        return scaled
    }

    private func canvas(_ layout: EazyMorphingTabBarLayout) -> some View {
        ZStack(alignment: .bottomLeading) {
            EazyMorphingTabBarStrip(
                tabs: tabs,
                selection: $selection,
                flight: $flight,
                tint: tint,
                layout: layout,
                selectionAnimation: reduceMotion ? nil : selectionAnimation
            )
            .frame(width: layout.barSize.width, height: layout.barSize.height)
            // Fades on the surface's own clock rather than on the boolean, so
            // the strip is gone by the time there is a panel where it was.
            .modifier(EazyMorphingTabBarStripFade())
            .allowsHitTesting(!isExpanded)
            .accessibilityHidden(isExpanded)

            EazyMorphingTabBarPanel(layout: layout) {
                expandedContent()
            }
            .allowsHitTesting(isExpanded)
            .accessibilityHidden(!isExpanded)

            if showsToggle {
                EazyMorphingTabBarToggle(
                    isExpanded: $isExpanded,
                    tint: tint,
                    diameter: layout.metrics.barHeight,
                    symbolSize: layout.metrics.toggleSymbolSize,
                    expandSymbol: expandSymbol,
                    collapseSymbol: collapseSymbol,
                    expandLabel: expandLabel,
                    collapseLabel: collapseLabel
                )
                .offset(x: layout.toggleRect.minX)
            }
        }
        .frame(
            width: layout.canvasSize.width,
            height: layout.canvasSize.height,
            alignment: .bottomLeading
        )
        .background(alignment: .bottomLeading) {
            EazyMorphingTabBarContentMeasure(size: $expandedContentSize) {
                expandedContent()
            }
        }
        .background(alignment: .bottomLeading) {
            if layout.metrics.titlePlacement == .trailing {
                EazyMorphingTabBarTabMeasure(
                    tabs: tabs,
                    metrics: layout.metrics,
                    width: $widestTab
                )
            }
        }
        // Bottom leading, and larger than the canvas by however far the surface
        // can reach past the panel: the glass has to have somewhere to go when
        // it overshoots, or it is clipped exactly where the bounce would show.
        .background(alignment: .bottomLeading) {
            Color.clear
                .frame(
                    width: layout.canvasSize.width + layout.stretchHeadroom.width,
                    height: layout.canvasSize.height + layout.stretchHeadroom.height
                )
                .modifier(
                    EazyMorphingTabBarSurface(
                        layout: layout,
                        toggle: showsToggle ? .capsule(layout.toggleRect) : .none,
                        flight: flight,
                        lens: { lens(layout, $0) },
                        style: style
                    )
                )
                // The lens keeps a clock of its own: it crosses the bar on a
                // tap, which has nothing to do with the panel opening, and one
                // animatable value cannot be driven by two springs at once.
                .animation(lensAnimation, value: flight.position)
        }
        .environment(\.eazyMorphingTabBarIsExpanded, isExpanded)
        // The morph's clock. Everything that has to keep step with the surface —
        // the strip fading out, the panel being uncovered, the lens dissolving —
        // reads the progress this publishes rather than animating on its own
        // schedule, which is what let the panel's contents arrive ahead of the
        // glass they belong in.
        .modifier(EazyMorphingTabBarMorph(progress: isExpanded ? 1 : 0))
        .animation(reduceMotion ? nil : morphAnimation, value: isExpanded)
    }
}

public extension EazyMorphingTabBar {
    /// Creates a bar that expands into a grid of labelled actions.
    ///
    /// Running an action closes the panel. With no actions there is nothing to
    /// expand into, so the toggle is left off and the strip takes the whole
    /// width — which is the arrangement that matches the system tab bar.
    init(
        tabs: [EazyTab],
        selection: Binding<EazyTab.ID>,
        isExpanded: Binding<Bool>,
        actions: [EazyTabBarAction],
        tint: Color = .accentColor,
        metrics: EazyMorphingTabBarMetrics = .standard,
        shortScreenMetrics: EazyMorphingTabBarMetrics? = .shortScreen,
        style: EazyLiquidGlassStyle = .tabBar,
        expandSymbol: String = "plus",
        collapseSymbol: String = "xmark",
        expandLabel: LocalizedStringResource = "More",
        collapseLabel: LocalizedStringResource = "Close",
        morphAnimation: Animation = .bouncy(duration: 0.75, extraBounce: 0.02),
        selectionAnimation: Animation = .spring(duration: 0.4, bounce: 0.15)
    ) where Expanded == EazyTabBarActionGrid {
        self.init(
            tabs: tabs,
            selection: selection,
            isExpanded: isExpanded,
            tint: tint,
            metrics: metrics,
            shortScreenMetrics: shortScreenMetrics,
            style: style,
            expandSymbol: expandSymbol,
            collapseSymbol: collapseSymbol,
            expandLabel: expandLabel,
            collapseLabel: collapseLabel,
            morphAnimation: morphAnimation,
            selectionAnimation: selectionAnimation,
            showsToggle: !actions.isEmpty
        ) {
            EazyTabBarActionGrid(
                actions: actions,
                columns: metrics.columns,
                cellSize: metrics.cellSize
            ) {
                isExpanded.wrappedValue = false
            }
        }
    }
}

// MARK: - Surface

/// The bar's glass, with the selection thinned out of it.
///
/// The system's selection is not a second body of glass laid on the bar. Shot
/// against the same backdrop with the tab selected and not, the system's
/// capsule takes 23 levels of luminance *off* the area it covers, while a
/// stacked material adds 13: it is clear glass where the bar is frosted, so
/// more of what is behind the bar comes through, and over a mid-tone background
/// that reads darker and more saturated.
///
/// So the capsule is cut out of the bar's glass rather than drawn over it,
/// which also keeps it right in dark mode: less material is less material
/// whichever way the backdrop runs, where a fixed dark overlay would only ever
/// darken.
/// The flight is what animates, not the rectangle it produces, which is why this
/// is a modifier and not a view. Interpolating the rectangle would slide the lens
/// rigidly from one tab to the next, because a rectangle can only be crossfaded
/// corner to corner; interpolating the position and deriving the rectangle from
/// it each frame is what lets the lens stretch on the way and arrive its own
/// length again. `Animatable` is honoured on a `ViewModifier`, so the surface is
/// applied to an empty view rather than being one.
private struct EazyMorphingTabBarSurface: ViewModifier, @preconcurrency Animatable {
    let layout: EazyMorphingTabBarLayout
    /// The toggle, in the canvas's space.
    let toggle: EazyLiquidGlassShape
    /// Where the lens is, and how far through a move. Animated.
    var flight: EazyMorphingTabBarLensFlight
    /// The lens the flight puts on the glass, in the surface's own space.
    let lens: (EazyMorphingTabBarLensFlight) -> EazyLiquidGlassShape
    let style: EazyLiquidGlassStyle

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    /// How far the surface is through its morph. Arrives already interpolated,
    /// a frame at a time, from the modifier that owns that clock.
    @Environment(\.eazyMorphingTabBarMorphProgress) private var morph
    /// Which way the morph is heading, which is what places the stretch's crest.
    @Environment(\.eazyMorphingTabBarIsExpanded) private var isExpanded

    var animatableData: Double {
        get { flight.position }
        set { flight.position = newValue }
    }

    func body(content: Content) -> some View {
        // This layer stands taller than the canvas so the surface has room to
        // overshoot, and its bottom edges are aligned; everything given in the
        // canvas's own space therefore sits that much further down in this one.
        let lift = layout.stretchHeadroom.height
        var shape = layout.surface(expandedBy: morph, expanding: isExpanded)
        shape.frame.origin.y += lift
        var lens = self.lens(flight)
        lens.frame.origin.y += lift
        var toggle = self.toggle
        toggle.frame.origin.y += lift
        // The selection has no meaning once the strip has gone, so the glass
        // closes over it as the panel opens rather than losing it in one frame.
        let clearing = layout.metrics.lensClearing * (1 - min(max(morph, 0), 1))

        return content
            .eazyLiquidGlass(shape, merging: toggle, style: style)
            .overlay(alignment: .topLeading) { rim(shape) }
            .overlay(alignment: .topLeading) {
                // Reduce Transparency asks for an opaque surface, and thinning
                // one would defeat that.
                if !reduceTransparency, clearing > 0, min(lens.frame.width, lens.frame.height) > 0 {
                    Capsule()
                        .frame(width: lens.frame.width, height: lens.frame.height)
                        .offset(x: lens.frame.minX, y: lens.frame.minY)
                        .blendMode(.destinationOut)
                        .opacity(clearing)
                }
            }
            .compositingGroup()
    }

    /// An even hairline along the edge, which the shader's highlight cannot
    /// give on its own: that highlight is a directional specular, so one light
    /// can only ever catch one edge, and a head-on light floods the interior
    /// instead of the rim. The system's edge is lit top *and* bottom, so the
    /// evenness has to be drawn rather than lit.
    @ViewBuilder
    private func rim(_ shape: EazyLiquidGlassShape) -> some View {
        RoundedRectangle(
            cornerRadius: min(shape.cornerRadius, min(shape.frame.width, shape.frame.height) / 2),
            style: .continuous
        )
        .strokeBorder(
            LinearGradient(
                colors: [
                    .white.opacity(0.33),
                    .white.opacity(0.10),
                    .white.opacity(0.40)
                ],
                startPoint: .top,
                endPoint: .bottom
            ),
            lineWidth: 1
        )
        .frame(width: shape.frame.width, height: shape.frame.height)
        .offset(x: shape.frame.minX, y: shape.frame.minY)
        .allowsHitTesting(false)
    }
}

// MARK: - The morph clock

/// Carries how far the bar is through its morph down to everything drawn in it.
///
/// The problem this solves is that a morph is not one animation but several — the
/// glass changes shape, the strip goes, the panel's contents arrive — and each of
/// them animating separately means each of them arriving separately. Giving them
/// separate springs of the same nominal length does not help either, because a
/// spring's *nominal* length is not when it looks finished: `.bouncy` is still
/// visibly moving well past the duration it is asked for, so a 0.34-second fade
/// beside it finished with the glass still growing, and the tiles turned up
/// outside the panel that was supposed to hold them.
///
/// So there is one animated value and everything reads it. `Animatable` is what
/// makes that possible on a modifier: SwiftUI interpolates ``progress`` frame by
/// frame, and each frame publishes it to the subtree.
private struct EazyMorphingTabBarMorph: ViewModifier, @preconcurrency Animatable {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content.environment(\.eazyMorphingTabBarMorphProgress, progress)
    }
}

/// Takes the strip away as the panel opens.
///
/// On the morph's clock, so the strip is gone by the time the glass it sat in is
/// a panel — and back before the panel has finished closing.
private struct EazyMorphingTabBarStripFade: ViewModifier {
    @Environment(\.eazyMorphingTabBarMorphProgress) private var morph

    func body(content: Content) -> some View {
        // Gone by a third of the way, which is before there is enough panel for
        // its contents to start arriving in.
        let showing = 1 - EazyMorphingTabBarStretch.ramp(morph, from: 0, to: 0.35)
        return content
            .opacity(showing)
            .blur(radius: 6 * (1 - showing))
    }
}

/// The panel's contents, kept inside the glass that holds them.
///
/// This is the fix for contents that arrived before the surface did. Fading them
/// in on the same clock as the glass is most of it, but not all: a fade is a
/// whole-view effect, and half way through a morph the panel is only half grown,
/// so a tile near the top of it would still be showing through where there was
/// no glass yet. Clipping the contents to the surface's own outline makes that
/// impossible rather than unlikely — and it does so for whatever content a
/// caller supplies, not only for the grid of actions that ships here.
///
/// It also gives the reveal its shape for nothing. The surface grows upwards, so
/// the contents are uncovered from the bottom row up, and swallowed from the top
/// row down on the way out; neither needed a stagger to be written.
private struct EazyMorphingTabBarPanel<Content: View>: View {
    let layout: EazyMorphingTabBarLayout
    @ViewBuilder let content: Content

    @Environment(\.eazyMorphingTabBarMorphProgress) private var morph
    @Environment(\.eazyMorphingTabBarIsExpanded) private var isExpanded

    var body: some View {
        let progress = min(max(morph, 0), 1)
        let surface = layout.surface(expandedBy: progress, expanding: isExpanded)
        // The panel shares the canvas's bottom leading corner, so the surface's
        // rectangle needs only shifting into the panel's own space.
        let clip = surface.frame.offsetBy(
            dx: -layout.panelRect.minX,
            dy: -layout.panelRect.minY
        )

        content
            .frame(width: layout.panelSize.width, height: layout.panelSize.height)
            // Nothing until the strip has gone, and fully there before the
            // surface has finished settling.
            .opacity(EazyMorphingTabBarStretch.ramp(progress, from: 0.35, to: 0.9))
            .mask(alignment: .topLeading) {
                RoundedRectangle(
                    cornerRadius: min(
                        surface.cornerRadius,
                        min(clip.width, clip.height) / 2
                    ),
                    style: .continuous
                )
                // Clamped: a spring undershoots at the end of a collapse, and a
                // negative size is not a shape.
                .frame(width: max(clip.width, 0), height: max(clip.height, 0))
                .offset(x: clip.minX, y: clip.minY)
            }
    }
}

// MARK: - Tab strip

/// The row of tabs, and the lens that travels between them.
///
/// The selected tab is marked by a lens rather than by a fill: it is a small
/// body of glass sitting on the strip, so the symbol under it refracts as the
/// lens arrives and leaves.
private struct EazyMorphingTabBarStrip: View {
    let tabs: [EazyTab]
    @Binding var selection: EazyTab.ID
    /// Owned by the bar, because the lens is cut out of the bar's glass.
    @Binding var flight: EazyMorphingTabBarLensFlight
    let tint: Color
    let layout: EazyMorphingTabBarLayout
    let selectionAnimation: Animation?

    private var metrics: EazyMorphingTabBarMetrics { layout.metrics }

    /// Which tab the finger is on, if any. Only that one reacts to the touch.
    @State private var pressedIndex: Int?

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                EazyMorphingTabBarTab(
                    tab: tab,
                    isSelected: tab.id == selection,
                    // Nil until a drag starts, so an ordinary tap still uses the
                    // button's own press state.
                    isPressed: pressedIndex.map { $0 == index },
                    tint: tint,
                    metrics: metrics,
                    width: layout.tabStride,
                    boxWidth: layout.tabWidth) {
                    withAnimation(selectionAnimation) { selection = tab.id }
                }
            }
        }
        // Padded on both axes so the strip's coordinate space is the whole bar,
        // which is the space the lens is placed in. Horizontally the padding
        // also absorbs the half-overlap each end box hangs over its hit area by.
        .padding(.horizontal, layout.stripPadding)
        .padding(.vertical, metrics.barPadding)
        // Only the refraction here. The lens's body is cut out of the bar's
        // glass by ``EazyMorphingTabBarSurface``, so drawing one here as well
        // would stack a second material and turn the selection opaque.
        .modifier(EazyMorphingTabBarRefraction(flight: flight, layout: layout))
        // The same animation the bar puts on the glass, so the refraction and
        // the body it belongs to are the same shape on every frame.
        .animation(flight.isTravelling ? selectionAnimation : nil, value: flight.position)
        .highPriorityGesture(drag)
        .accessibilityElement(children: .contain)
    }

    /// Dragging carries the lens under the finger instead of stepping it from
    /// tab to tab, so the glass keeps travelling for as long as the finger does.
    ///
    /// It takes priority over the tab buttons rather than running alongside them.
    /// Sharing the touch let every button the finger crossed light up, and let
    /// the button the drag started on fire its own action on release — which
    /// selected the tab the finger had just left. The minimum distance still
    /// leaves an ordinary tap to the button underneath.
    ///
    /// A dragged lens does not stretch. The stretch is what a lens does when it
    /// is thrown at a tab and has to catch up with itself; under a finger it is
    /// already exactly where it was put.
    private var drag: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                // Set outside the animation: the lens belongs to the finger
                // while it is down, and animating it towards a moving target
                // is what made it lag and double back.
                flight = .init(resting: layout.lensPosition(draggedTo: value.location.x))
                pressedIndex = layout.tabIndex(at: value.location.x)
                // The lens is already under the finger; only the symbol and
                // title need easing between their two states.
                withAnimation(selectionAnimation) { select(at: value.location.x) }
            }
            .onEnded { value in
                pressedIndex = nil
                // Opening a journey is what lets the lens ease onto the tab —
                // and stretch as it goes — instead of snapping there the moment
                // the finger lifts.
                let landing = Double(layout.tabIndex(at: value.location.x))
                flight = .init(
                    position: flight.position,
                    origin: flight.position,
                    destination: landing
                )
                flight.position = landing
                withAnimation(selectionAnimation) { select(at: value.location.x) }
            }
    }

    private func select(at x: CGFloat) {
        guard let tab = tabs[safe: layout.tabIndex(at: x)], tab.id != selection else { return }
        selection = tab.id
    }
}

/// Bends the strip under the travelling lens.
///
/// Animates the flight rather than the lens's rectangle, exactly as
/// ``EazyMorphingTabBarSurface`` does, so the refraction and the glass it
/// belongs to are the same shape on every frame. Were this modifier to
/// interpolate the rectangle instead, the two would take different paths across
/// the bar and the symbols would bend where there was no glass.
private struct EazyMorphingTabBarRefraction: ViewModifier, @preconcurrency Animatable {
    var flight: EazyMorphingTabBarLensFlight
    let layout: EazyMorphingTabBarLayout

    var animatableData: Double {
        get { flight.position }
        set { flight.position = newValue }
    }

    func body(content: Content) -> some View {
        let lens = layout.lens(flight)
        return content
            .eazyLiquidLens(
                lens,
                refraction: layout.metrics.lensRefraction,
                depth: layout.metrics.lensDepth,
                dispersion: layout.metrics.lensDispersion
            )
    }
}

/// A single tab: a symbol above centre, and its title in the space below.
///
/// Neither element is centred in the box and they are not stacked with a
/// spacing, because the system does not stack them either — it pins the symbol's
/// centre and the title's box to fixed heights, which lets a tall symbol grow
/// into the title's line without moving it. `square.stack` is the symbol that
/// makes the difference visible.
private struct EazyMorphingTabBarTab: View {
    let tab: EazyTab
    let isSelected: Bool
    /// Nil while the tab owns its own touch. Set while the strip's drag owns it.
    let isPressed: Bool?
    let tint: Color
    let metrics: EazyMorphingTabBarMetrics
    /// The hit area: one stride wide, so neighbouring tabs never share a point.
    let width: CGFloat
    /// The box the title may spread into, which is wider than the hit area.
    let boxWidth: CGFloat
    let action: () -> Void


    var body: some View {
        Button {
            action()
        } label: {
            EazyMorphingTabBarTabContent(
                tab: tab,
                isSelected: isSelected,
                metrics: metrics,
                boxWidth: boxWidth
            )
            // Unselected tabs are not dimmed. Sampling the system's own bar puts
            // their ink at a luminance of 21 against 132 for a secondary style:
            // the state is carried by hue and weight, and the label keeps its
            // full strength so every tab stays equally legible.
            .foregroundStyle(isSelected ? AnyShapeStyle(tint) : AnyShapeStyle(.primary))
            .frame(width: width, height: metrics.tabHeight)
            .contentShape(.capsule)
        }
        .compositingGroup()
        .buttonStyle(EazyGlassPressStyle(isPressed: isPressed))
        .accessibilityLabel(Text(tab.title))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// A tab's symbol and title, in whichever of the two arrangements applies.
///
/// Split out because the bar has to lay one of these out on its own, out of
/// sight, to find out how wide the short arrangement's tabs want to be.
private struct EazyMorphingTabBarTabContent: View {
    let tab: EazyTab
    let isSelected: Bool
    let metrics: EazyMorphingTabBarMetrics
    /// The box the title may spread into, which is wider than the hit area.
    /// Ignored where the tab is sized to its title instead.
    let boxWidth: CGFloat?

    var body: some View {
        switch metrics.titlePlacement {
        case .below: stacked
        case .trailing: sideBySide
        case .hidden: symbol.frame(height: metrics.tabHeight)
        }
    }

    /// Neither element is centred in the box and they are not stacked with a
    /// spacing, because the system does not stack them either — it pins the
    /// symbol's centre and the title's box to fixed heights, which lets a tall
    /// symbol grow into the title's line without moving it. `square.stack` is
    /// the symbol that makes the difference visible.
    private var stacked: some View {
        ZStack(alignment: .top) {
            // Holds the box open to its full height, so the contents are
            // measured from the top of the tab rather than centred in
            // whatever height the symbol and title happen to need.
            Color.clear
                .frame(height: metrics.tabHeight)

            symbol.frame(height: metrics.symbolCenterY * 2)

            title
                .frame(width: boxWidth, height: metrics.labelHeight)
                .padding(.top, metrics.labelTop)
        }
    }

    /// The short arrangement: one line, both parts centered in the height, and
    /// the whole tab as wide as its own title. The system pads it by six before
    /// the symbol and ten after the title; here the two are shared out evenly,
    /// because these tabs are drawn at one width rather than each at its own.
    private var sideBySide: some View {
        HStack(spacing: metrics.titleSpacing) {
            symbol
            title
        }
        .padding(.horizontal, metrics.tabPadding / 2)
        .frame(height: metrics.tabHeight)
    }

    private var symbol: some View {
        Image(systemName: tab.systemImage)
            // Tab bar symbols are filled in both states, selected or not; the
            // state is carried by color and weight, not by the outline. Symbols
            // with no filled variant are left as they are rather than going
            // missing.
            .symbolVariant(.fill)
            .font(.system(size: metrics.symbolSize, weight: .regular))
    }

    private var title: some View {
        Text(tab.title)
            .font(.system(size: metrics.labelSize, weight: isSelected ? .semibold : .medium))
            .lineLimit(1)
    }
}

/// Lays every tab out at its ideal size, out of sight, and reports the widest.
///
/// Only the short arrangement needs this. There a tab is as wide as its own
/// title — the system's run from 81 points for "Inbox" to 93 for "Settings" — and
/// a title's width is not something a layout can be told in advance, only
/// measured. They are then all drawn at the widest, which is the one deliberate
/// departure from the system here: it keeps a single tab width, and with it the
/// lens geometry, the hit areas and the drag, at the cost of a bar a few points
/// wider than the system's when the titles differ in length. Titles of the same
/// length give the same bar.
///
/// Nothing measured here depends on the bar's own size, so reading it back into
/// the layout cannot feed on itself.
private struct EazyMorphingTabBarTabMeasure: View {
    let tabs: [EazyTab]
    let metrics: EazyMorphingTabBarMetrics
    @Binding var width: CGFloat

    var body: some View {
        ZStack {
            ForEach(tabs) { tab in
                EazyMorphingTabBarTabContent(
                    // Measured selected: the system sizes its boxes to the
                    // heavier weight so they do not shift as the selection
                    // moves.
                    tab: tab,
                    isSelected: true,
                    metrics: metrics,
                    boxWidth: nil
                )
                .fixedSize()
            }
        }
        .hidden()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            width = newValue
        }
    }
}

/// Presses shrink the control briefly.
///
/// Liquid Glass reacts to touch in real time, and the system offers that as
/// `interactive()` on its own material; this is the equivalent for a surface
/// drawn by the package.
private struct EazyGlassPressStyle: ButtonStyle {
    var scale: CGFloat = 0.94
    /// Set when something other than this button owns the touch — the strip's
    /// drag, which knows which single tab the finger is actually on. Without it
    /// every button the finger crossed would react at once.
    var isPressed: Bool?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let pressed = isPressed ?? configuration.isPressed
        return configuration.label
            .scaleEffect(pressed && !reduceMotion ? scale : 1)
            .animation(.spring(response: 0.26, dampingFraction: 0.7), value: pressed)
    }
}

// MARK: - Toggle

/// The round button that expands and collapses the panel.
private struct EazyMorphingTabBarToggle: View {
    @Binding var isExpanded: Bool
    let tint: Color
    let diameter: CGFloat
    let symbolSize: CGFloat
    let expandSymbol: String
    let collapseSymbol: String
    let expandLabel: LocalizedStringResource
    let collapseLabel: LocalizedStringResource

    var body: some View {
        Button {
            isExpanded.toggle()
        } label: {
            Image(systemName: isExpanded ? collapseSymbol : expandSymbol)
                .font(.system(size: symbolSize, weight: .medium))
                .foregroundStyle(tint)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: diameter, height: diameter)
                .contentShape(.circle)
        }
        .buttonStyle(EazyGlassPressStyle(scale: 0.92))
        .accessibilityLabel(Text(isExpanded ? collapseLabel : expandLabel))
    }
}

// MARK: - Action grid

/// The grid of labelled actions the panel shows.
public struct EazyTabBarActionGrid: View {
    private let actions: [EazyTabBarAction]
    private let columns: Int
    private let cellSize: CGSize
    private let onPerform: () -> Void

    @Environment(\.eazyMorphingTabBarIsExpanded) private var isExpanded

    public init(
        actions: [EazyTabBarAction],
        columns: Int = 4,
        cellSize: CGSize = CGSize(width: 72, height: 78),
        onPerform: @escaping () -> Void = {}
    ) {
        self.actions = actions
        self.columns = max(columns, 1)
        self.cellSize = cellSize
        self.onPerform = onPerform
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(rows.indices, id: \.self) { index in
                EazyTabBarActionRow(
                    slots: rows[index],
                    columns: columns,
                    cellSize: cellSize,
                    isExpanded: isExpanded,
                    onPerform: onPerform
                )
            }
        }
    }

    private var rows: [[EazyTabBarActionSlot]] {
        stride(from: 0, to: actions.count, by: columns).map { start in
            let end = min(start + columns, actions.count)
            return (start..<end).map { EazyTabBarActionSlot(index: $0, action: actions[$0]) }
        }
    }
}

/// One action and the position it appears in, which drives its entrance.
private struct EazyTabBarActionSlot: Identifiable {
    let index: Int
    let action: EazyTabBarAction

    var id: String { action.id }
}

/// A single row of the grid, padded out so short rows stay leading-aligned.
private struct EazyTabBarActionRow: View {
    let slots: [EazyTabBarActionSlot]
    let columns: Int
    let cellSize: CGSize
    let isExpanded: Bool
    let onPerform: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(slots) { slot in
                EazyTabBarActionCell(
                    action: slot.action,
                    size: cellSize,
                    isExpanded: isExpanded,
                    index: slot.index,
                    onPerform: onPerform
                )
            }

            if slots.count < columns {
                Color.clear
                    .frame(width: cellSize.width * CGFloat(columns - slots.count), height: 0)
            }
        }
    }
}

/// A single action tile and its label.
private struct EazyTabBarActionCell: View {
    let action: EazyTabBarAction
    let size: CGSize
    let isExpanded: Bool
    let index: Int
    let onPerform: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.eazyMorphingTabBarMorphProgress) private var morph

    var body: some View {
        Button {
            action.handler()
            onPerform()
        } label: {
            VStack(spacing: 5) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.primary.opacity(colorScheme == .dark ? 0.14 : 0.06))
                    .overlay {
                        Image(systemName: action.systemImage)
                            .font(.system(size: 21, weight: .regular))
                            .foregroundStyle(
                                action.isDestructive
                                    ? AnyShapeStyle(Color.red)
                                    : AnyShapeStyle(.primary)
                            )
                    }
                    .frame(width: size.width - 10, height: size.height - 28)

                Text(action.title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(width: size.width, height: size.height)
            .contentShape(.rect)
        }
        .buttonStyle(EazyGlassPressStyle(scale: 0.9))
        // On the surface's clock, not a schedule of its own. A tile used to have
        // its own 0.34-second fade with a delay per position, which finished
        // while the glass was still growing and put the tiles on screen ahead of
        // the panel; the panel itself now uncovers them, bottom row first, which
        // is the stagger those delays were reaching for.
        //
        // No opacity here: the panel is already fading these in as a whole, and
        // fading them twice only makes them arrive late and washed out.
        .blur(radius: 4 * (1 - entrance))
        .scaleEffect(0.86 + 0.14 * entrance, anchor: .bottom)
    }

    /// How far in the tile is, from gone to arrived.
    private var entrance: Double {
        guard !reduceMotion else { return isExpanded ? 1 : 0 }
        return EazyMorphingTabBarStretch.ramp(morph, from: 0.35, to: 0.9)
    }
}

// MARK: - Measurement

/// Lays the panel content out at its ideal size, out of sight, so the panel can
/// take that size before it is ever shown.
private struct EazyMorphingTabBarContentMeasure<Content: View>: View {
    @Binding var size: CGSize
    @ViewBuilder let content: Content

    var body: some View {
        content
            .fixedSize()
            .hidden()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newValue in
                size = newValue
            }
    }
}

// MARK: - Environment

private struct EazyMorphingTabBarIsExpandedKey: EnvironmentKey {
    static let defaultValue = false
}

private struct EazyMorphingTabBarMorphProgressKey: EnvironmentKey {
    static let defaultValue: Double = 0
}

public extension EnvironmentValues {
    /// Whether the enclosing ``EazyMorphingTabBar`` is expanded.
    ///
    /// This is the destination, not the state: it flips the moment the panel is
    /// asked for. Read ``eazyMorphingTabBarMorphProgress`` to follow the morph
    /// itself.
    var eazyMorphingTabBarIsExpanded: Bool {
        get { self[EazyMorphingTabBarIsExpandedKey.self] }
        set { self[EazyMorphingTabBarIsExpandedKey.self] = newValue }
    }

    /// How far the enclosing ``EazyMorphingTabBar`` is through its morph, from
    /// nothing at the strip to one at the panel.
    ///
    /// Updated every frame while the bar is moving, and briefly outside zero and
    /// one where the animation overshoots. Panel content that wants to arrive
    /// with the glass rather than on a schedule of its own should read this
    /// rather than ``eazyMorphingTabBarIsExpanded`` — a fade timed against a
    /// spring finishes before the spring looks finished, which is what puts
    /// content on screen ahead of the surface that holds it.
    ///
    /// ```swift
    /// struct PanelRow: View {
    ///     @Environment(\.eazyMorphingTabBarMorphProgress) private var morph
    ///
    ///     var body: some View {
    ///         content.opacity(morph)
    ///     }
    /// }
    /// ```
    var eazyMorphingTabBarMorphProgress: Double {
        get { self[EazyMorphingTabBarMorphProgressKey.self] }
        set { self[EazyMorphingTabBarMorphProgressKey.self] = newValue }
    }
}

// MARK: - Preview

#Preview("Morphing tab bar") {
    EazyMorphingTabBarPreview()
}

private struct EazyMorphingTabBarPreview: View {
    @State private var selection = "house"
    @State private var isExpanded = false

    private let tabs: [EazyTab] = [
        EazyTab(systemImage: "house", title: "Home"),
        EazyTab(systemImage: "tray", title: "Inbox"),
        EazyTab(systemImage: "bell", title: "Activity"),
        EazyTab(systemImage: "square.stack", title: "Library")
    ]

    private var actions: [EazyTabBarAction] {
        [
            EazyTabBarAction(systemImage: "scissors", title: "Trim") {},
            EazyTabBarAction(systemImage: "crop", title: "Crop") {},
            EazyTabBarAction(systemImage: "wand.and.sparkles", title: "Enhance") {},
            EazyTabBarAction(systemImage: "textformat", title: "Text") {},
            EazyTabBarAction(systemImage: "music.note", title: "Audio") {},
            EazyTabBarAction(systemImage: "hare", title: "Speed") {},
            EazyTabBarAction(systemImage: "square.on.square", title: "Duplicate") {},
            EazyTabBarAction(systemImage: "arrow.uturn.backward", title: "Undo") {},
            EazyTabBarAction(systemImage: "square.and.arrow.up", title: "Share") {},
            EazyTabBarAction(systemImage: "bookmark", title: "Save") {},
            EazyTabBarAction(systemImage: "trash", title: "Delete", isDestructive: true) {}
        ]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [.indigo, .purple, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            EazyMorphingTabBar(
                tabs: tabs,
                selection: $selection,
                isExpanded: $isExpanded,
                actions: actions
            )
            // Where the system puts its own bar: 21 points off the bottom edge,
            // ignoring the safe area rather than sitting above it.
            .padding(.bottom, EazyMorphingTabBarMetrics.screenInset)
            .ignoresSafeArea(edges: .bottom)

        }
    }
}

/// The arrangement the bar takes where the screen is too short for the standard
/// one, which is what an iPhone in landscape gets. Shown directly rather than by
/// rotating a preview, so the two can be compared side by side.
#Preview("Short screen") {
    EazyMorphingTabBarShortScreenPreview()
}

private struct EazyMorphingTabBarShortScreenPreview: View {
    @State private var selection = "bell"
    @State private var isExpanded = false

    private let tabs: [EazyTab] = [
        EazyTab(systemImage: "house", title: "Home"),
        EazyTab(systemImage: "tray", title: "Inbox"),
        EazyTab(systemImage: "bell", title: "Activity"),
        EazyTab(systemImage: "square.stack", title: "Library")
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.indigo, .purple, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                EazyMorphingTabBar(
                    tabs: tabs,
                    selection: $selection,
                    isExpanded: $isExpanded,
                    actions: [],
                    metrics: .standard
                )

                EazyMorphingTabBar(
                    tabs: tabs,
                    selection: $selection,
                    isExpanded: $isExpanded,
                    actions: [],
                    metrics: .shortScreen
                )
            }
        }
    }
}

/// The bar above the system's own, over one background, for comparing them.
#Preview("Against the system bar") {
    EazyMorphingTabBarComparisonPreview()
}

private struct EazyMorphingTabBarComparisonPreview: View {
    @State private var selection = "tray"
    @State private var isExpanded = false

    private let tabs: [EazyTab] = [
        EazyTab(systemImage: "house", title: "Home"),
        EazyTab(systemImage: "tray", title: "Inbox"),
        EazyTab(systemImage: "bell", title: "Activity"),
        EazyTab(systemImage: "square.stack", title: "Library")
    ]

    var body: some View {
        TabView {
            ForEach(tabs) { tab in
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        colors: [.indigo, .purple, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    EazyMorphingTabBar(
                        tabs: tabs,
                        selection: $selection,
                        isExpanded: $isExpanded,
                        actions: []
                    )
                    .padding(.bottom, EazyMorphingTabBarMetrics.screenInset)
                }
                .tabItem { Label(tab.title, systemImage: tab.systemImage) }
                .tag(tab.id)
            }
        }
    }
}
