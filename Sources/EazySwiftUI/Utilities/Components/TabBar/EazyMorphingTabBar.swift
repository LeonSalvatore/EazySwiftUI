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
    /// The diameter of the circle the bar collapses into while minimised.
    ///
    /// Forty-eight points, measured: the system's minimised bar is a 48-point
    /// circle sitting where the 62-point bar was, centred in that band, which
    /// puts it seven points inside the bar on every side and 28 points off the
    /// screen's leading edge. The same 48 points the bottom accessory is tall,
    /// which is what lets the two share a row.
    public var collapsedDiameter: CGFloat
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
    /// the title. They are stored together because the compact layout measures
    /// each complete symbol-and-title row as one tab box.
    public var tabPadding: CGFloat
    /// The combined breathing room around a title that outgrows the standard
    /// portrait tab box.
    ///
    /// Short titles keep ``tabWidth`` exactly. A longer title instead receives
    /// its measured width plus this inset, matching the native bar's behavior of
    /// widening that destination and yielding space from its shorter neighbors.
    public var longTitlePadding: CGFloat
    /// The smallest horizontal touch target the layout tries to preserve while
    /// compressing differently-sized tabs.
    public var minimumHitWidth: CGFloat
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
    /// How far the surface leads its linear size while morphing, as a fraction
    /// of the distance the moving edge travels.
    ///
    /// The panel is one of the few things here with nothing to measure against,
    /// because the system tab bar has no panel to expand into. The *law* is
    /// measured, though: it is the lens's, so the surface leads its underlying
    /// size and is exactly its own size again at both ends. The same geometric
    /// path is traversed in reverse while closing, which keeps an interrupted
    /// or reversed morph continuous.
    ///
    /// The crest sits four fifths of the way along. The default keeps this
    /// geometric lead deliberately small and leaves the visible settling to the
    /// caller's animation. Set it to zero for a surface that resizes without
    /// stretching.
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
        collapsedDiameter: CGFloat = 48,
        symbolSize: CGFloat = 24,
        symbolCenterY: CGFloat = 20,
        titlePlacement: EazyMorphingTabBarTitlePlacement = .below,
        labelSize: CGFloat = 10,
        labelTop: CGFloat = 35,
        labelHeight: CGFloat = 12,
        titleSpacing: CGFloat = 8,
        tabPadding: CGFloat = 16,
        longTitlePadding: CGFloat = 40,
        minimumHitWidth: CGFloat = 44,
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
        morphStretch: Double = 0.12,
        morphStretchPeak: Double = 0.83
    ) {
        self.tabWidth = tabWidth
        self.tabStride = tabStride
        self.barHeight = barHeight
        self.barPadding = barPadding
        self.collapsedDiameter = min(max(collapsedDiameter, 1), barHeight)
        self.symbolSize = symbolSize
        self.symbolCenterY = symbolCenterY
        self.titlePlacement = titlePlacement
        self.labelSize = labelSize
        self.labelTop = labelTop
        self.labelHeight = labelHeight
        self.titleSpacing = titleSpacing
        self.tabPadding = tabPadding
        self.longTitlePadding = max(longTitlePadding, 0)
        self.minimumHitWidth = max(minimumHitWidth, 1)
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
        // A placeholder pair, replaced by each tab's own width once the bar has
        // measured its titles; the gap between them is what matters and is held
        // to the measured four points. The system's own tabs run from 81 to 93
        // points wide over the original titles measured.
        tabWidth: 84,
        tabStride: 88,
        barHeight: 44,
        // Derived, not measured: the standard bar keeps seven points of itself
        // on every side of the circle, so the short one does too. The system's
        // landscape bar was not filmed collapsing.
        collapsedDiameter: 30,
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
    /// Ideal widths measured from the compact, side-by-side tab contents.
    /// Nil keeps the standard system geometry, where every tab has one width.
    let tabWidths: [CGFloat]?
    let expandedContentSize: CGSize
    /// The width the strip has to fill. Nil takes the natural width, which is
    /// what the strip measures when nothing constrains it.
    let barWidth: CGFloat?
    /// Whether a toggle sits beside the strip and has to be left room for.
    let hasToggle: Bool

    init(
        metrics: EazyMorphingTabBarMetrics,
        tabCount: Int,
        tabWidths: [CGFloat]? = nil,
        expandedContentSize: CGSize,
        barWidth: CGFloat? = nil,
        hasToggle: Bool = true
    ) {
        self.metrics = metrics
        self.tabCount = tabCount
        self.tabWidths = tabWidths
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
            tabWidths: tabWidths,
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
            tabWidths: tabWidths,
            expandedContentSize: expandedContentSize,
            barWidth: max(resolved, metrics.barHeight),
            hasToggle: hasToggle
        )
    }

    private var tabs: CGFloat { CGFloat(max(tabCount, 1)) }

    /// Compact system tabs size themselves to their own symbol and title. The
    /// standard arrangement has fixed boxes, represented by the fallback.
    private var naturalTabWidths: [CGFloat] {
        guard
            let tabWidths,
            tabWidths.count == tabCount,
            tabWidths.allSatisfy({ $0 > 0 })
        else {
            return Array(repeating: metrics.tabWidth, count: max(tabCount, 1))
        }
        return tabWidths
    }

    var usesVariableTabWidths: Bool {
        guard let tabWidths else { return false }
        return tabCount > 0
            && tabWidths.count == tabCount
            && tabWidths.allSatisfy { $0 > 0 }
    }

    /// The empty space between neighbouring compact boxes. It is negative in
    /// the standard arrangement, where the fixed boxes overlap.
    var tabGap: CGFloat { metrics.tabStride - metrics.tabWidth }

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
        metrics.barPadding * 2
            + naturalTabWidths.reduce(0, +)
            + (tabs - 1) * tabGap
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

    /// A content-sized tab's resolved box width.
    ///
    /// Compression first preserves a 44-point hit target, then preserves the
    /// part of any unusually long title that exceeds the normal tab width, and
    /// only then shares the remaining room between the ordinary tabs. This is
    /// what keeps one long portrait title readable beside the detached toggle
    /// instead of truncating it while much shorter labels retain excess space.
    func tabWidth(at index: Int) -> CGFloat {
        guard usesVariableTabWidths else { return tabWidth }
        let clamped = min(max(index, 0), max(tabCount - 1, 0))
        return resolvedVariableTabWidths[clamped]
    }

    private var resolvedVariableTabWidths: [CGFloat] {
        let ideal = naturalTabWidths
        let gaps = CGFloat(max(tabCount - 1, 0)) * tabGap
        let target = max(contentWidth - gaps, 0)
        let idealTotal = ideal.reduce(0, +)
        guard idealTotal > 0, tabCount > 0 else { return ideal }

        if target >= idealTotal {
            let extra = (target - idealTotal) / CGFloat(tabCount)
            return ideal.map { $0 + extra }
        }

        // A box's hit cell also owns the fixed gap beside it. For overlapping
        // portrait boxes the cell is eight points narrower; for compact boxes
        // it is four points wider.
        let minimumBox = max(metrics.minimumHitWidth - tabGap, 1)
        let minimumTotal = minimumBox * CGFloat(tabCount)
        guard target >= minimumTotal else {
            return Array(repeating: target / CGFloat(tabCount), count: tabCount)
        }

        var widths = Array(repeating: minimumBox, count: tabCount)
        var remaining = target - minimumTotal

        // A label wider than the ordinary system box gets first claim on the
        // constrained space. This is the behavior visible in the native bar:
        // short destinations narrow while the long destination stays legible.
        let longTitleNeeds = ideal.map { max($0 - metrics.tabWidth, 0) }
        let longTitleTotal = longTitleNeeds.reduce(0, +)
        if longTitleTotal > 0, remaining > 0 {
            let scale = min(remaining / longTitleTotal, 1)
            for index in widths.indices {
                widths[index] += longTitleNeeds[index] * scale
            }
            remaining -= longTitleTotal * scale
        }

        let ordinaryNeeds = zip(ideal, widths).map { max($0.0 - $0.1, 0) }
        let ordinaryTotal = ordinaryNeeds.reduce(0, +)
        if ordinaryTotal > 0, remaining > 0 {
            let scale = min(remaining / ordinaryTotal, 1)
            for index in widths.indices {
                widths[index] += ordinaryNeeds[index] * scale
            }
            remaining -= ordinaryTotal * scale
        }

        if remaining > 0 {
            let extra = remaining / CGFloat(tabCount)
            for index in widths.indices {
                widths[index] += extra
            }
        }
        return widths
    }

    /// The lens width at a fractional position, interpolated between the two
    /// differently-sized compact tabs it is travelling between.
    func tabWidth(at position: Double) -> CGFloat {
        guard tabCount > 0 else { return 0 }
        let clamped = min(max(position, 0), Double(tabCount - 1))
        let lower = Int(clamped.rounded(.down))
        let upper = min(lower + 1, tabCount - 1)
        let progress = CGFloat(clamped - Double(lower))
        let start = tabWidth(at: lower)
        return start + (tabWidth(at: upper) - start) * progress
    }

    /// Width assigned to a button in the strip.
    ///
    /// The cell owns the fixed gap as well as its box. With an eight-point
    /// overlap this makes the hit cell eight points narrower than the lens; with
    /// a four-point compact gap it makes the cell four points wider. Either way,
    /// cells meet without overlapping and their centers remain the lens centers.
    func tabHitWidth(at index: Int) -> CGFloat {
        max(tabWidth(at: index) + tabGap, 1)
    }

    var stripSpacing: CGFloat { 0 }

    /// The inset from the bar edge to the first tab's hit area.
    ///
    /// Offsets the first hit cell by half the fixed box gap, leaving its visual
    /// box exactly ``barPadding`` points from the surface edge.
    var stripPadding: CGFloat {
        metrics.barPadding - tabGap / 2
    }

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

    /// The circle the bar collapses into while minimised.
    ///
    /// Centred in the band the full bar occupied rather than pinned to its
    /// corner: the system's 48-point circle sits seven points inside its
    /// 62-point bar on every side, which puts it 28 points off the screen's
    /// leading edge once the bar's own 21-point inset is counted, and level
    /// with an inline bottom accessory.
    var collapsedRect: CGRect {
        let inset = (metrics.barHeight - metrics.collapsedDiameter) / 2
        return CGRect(
            x: inset,
            y: canvasSize.height - metrics.barHeight + inset,
            width: metrics.collapsedDiameter,
            height: metrics.collapsedDiameter
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
    /// Two things can carry it past: the geometric stretch and the spring,
    /// which carries progress a little past one on its own. The stretch amount
    /// is a safe upper bound for its excess; a quarter of the journey remains
    /// the minimum so a caller-supplied spring has room to settle.
    var stretchHeadroom: CGSize {
        let reach = max(metrics.morphStretch, 0.25)
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
    /// Opening and closing traverse the same path in opposite directions. The
    /// previous direction-dependent path always added the stretch toward the
    /// larger panel while closing; around the middle of a collapse that made the
    /// surface stop shrinking, grow again, then snap shut near the end.
    func surface(expandedBy progress: Double) -> EazyLiquidGlassShape {
        // The progress is deliberately not clamped where it is interpolated.
        // The morph is a spring, and a spring's overshoot past its destination
        // and back is the bounce; clamping it to one threw the bounce away and
        // left the surface arriving dead against a hard stop.
        //
        // The stretch is clamped, because it is a single hump over a journey and
        // has to be nothing at both ends whatever the spring does around them.
        let journey = min(max(progress, 0), 1)
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

    /// The bar's outline part way between whatever it is now and the circle it
    /// collapses into.
    ///
    /// Collapsing and expanding into the panel are mutually exclusive — there is
    /// nothing to minimise a bar into while its panel is open — so this takes
    /// the shape the expansion produced and carries it the rest of the way,
    /// rather than trying to interpolate three states at once.
    ///
    /// The stretch is the same law the lens and the panel use, spent on the
    /// edges that move. Filmed collapsing, the system's selection runs *past*
    /// its resting place — its leading edge reaches 24.5 points on the way to
    /// 28 and comes back — so the shape has to be able to overshoot and settle
    /// rather than slide between two rectangles.
    func surface(expandedBy expand: Double, collapsedBy collapse: Double) -> EazyLiquidGlassShape {
        let open = surface(expandedBy: expand)
        guard collapse > 0 else { return open }

        let circle = EazyLiquidGlassShape(
            frame: collapsedRect,
            cornerRadius: metrics.collapsedDiameter / 2
        )
        let journey = min(max(collapse, 0), 1)
        let stretch = CGFloat(
            EazyMorphingTabBarStretch.hump(journey, peak: metrics.morphStretchPeak)
                * metrics.morphStretch
        )
        // The progress is not clamped where it interpolates, so a spring's
        // overshoot survives; the stretch is, because it is one hump over a
        // journey and has to be nothing at both ends.
        let lerp = { (from: CGFloat, to: CGFloat) -> CGFloat in
            from + (to - from) * CGFloat(collapse)
        }
        let height = max(lerp(open.frame.height, circle.frame.height), 0)
        // The stretch is spent on the trailing edge, and only there. That is
        // what the recordings show: filmed collapsing, the system's shape runs
        // *past* where it is going along the axis it is travelling — its
        // travelling edge reaches 24.5 points on the way to 28 and comes back —
        // while its height decays onto 48 without ever dipping below it. So the
        // width overshoots and nothing else does.
        let width = max(
            lerp(open.frame.width, circle.frame.width)
                - abs(circle.frame.width - open.frame.width) * stretch,
            0
        )
        return EazyLiquidGlassShape(
            frame: CGRect(
                x: lerp(open.frame.minX, circle.frame.minX),
                // Straight to the circle's own top edge. Deriving it from the
                // height instead put the circle on the bar's floor rather than
                // centred in the band it left behind, seven points low — which
                // is exactly the seven points that separate a 48-point circle
                // centred in a 62-point bar from one resting on its bottom.
                y: lerp(open.frame.minY, circle.frame.minY),
                width: width,
                height: height
            ),
            cornerRadius: open.cornerRadius
                + (circle.cornerRadius - open.cornerRadius) * CGFloat(journey)
        )
    }

    // MARK: Strip geometry

    /// The index of the tab under a point in the strip, clamped to the strip so
    /// a drag that runs past either end keeps the last tab it reached.
    ///
    /// Boxes overlap, so a point can fall inside two of them; the nearer centre
    /// wins, which puts the boundary exactly halfway between two tabs.
    func tabIndex(at x: CGFloat) -> Int {
        guard tabCount > 0 else { return 0 }
        return (0..<tabCount).min {
            abs(lensCenter(at: $0) - x) < abs(lensCenter(at: $1) - x)
        } ?? 0
    }

    /// The centre of the lens when it rests on a tab.
    func lensCenter(at index: Int) -> CGFloat {
        lensCenter(at: Double(index))
    }

    /// The centre of the lens at a fractional position between tabs, which is
    /// where it sits for all but the two instants at either end of a move.
    func lensCenter(at position: Double) -> CGFloat {
        guard tabCount > 0 else { return metrics.barPadding }
        let clamped = min(max(position, 0), Double(max(tabCount - 1, 0)))
        let lower = Int(clamped.rounded(.down))
        let upper = min(lower + 1, tabCount - 1)
        let progress = CGFloat(clamped - Double(lower))
        let start = lensCenterForTab(at: lower)
        return start + (lensCenterForTab(at: upper) - start) * progress
    }

    private func lensCenterForTab(at index: Int) -> CGFloat {
        guard usesVariableTabWidths else {
            return metrics.barPadding + tabWidth / 2 + CGFloat(index) * tabStride
        }
        let precedingWidths = (0..<index).reduce(CGFloat.zero) {
            $0 + tabWidth(at: $1)
        }
        return metrics.barPadding
            + precedingWidths
            + CGFloat(index) * tabGap
            + tabWidth(at: index) / 2
    }

    /// The centre of the lens while a drag carries it, never leaving the strip.
    func lensCenter(draggedTo x: CGFloat) -> CGFloat {
        min(max(x, lensCenter(at: 0)), lensCenter(at: tabCount - 1))
    }

    /// Where a point in the strip falls, as a fractional tab position.
    func lensPosition(draggedTo x: CGFloat) -> Double {
        guard tabCount > 1 else { return 0 }
        let center = lensCenter(draggedTo: x)
        for index in 0..<(tabCount - 1) {
            let start = lensCenter(at: index)
            let end = lensCenter(at: index + 1)
            if center <= end {
                guard end > start else { return Double(index) }
                return Double(index) + Double((center - start) / (end - start))
            }
        }
        return Double(tabCount - 1)
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
        let width = tabWidth(at: flight.position)
        let travelDistance = abs(
            lensCenter(at: flight.destination) - lensCenter(at: flight.origin)
        )
        let stretch = CGFloat(
            EazyMorphingTabBarStretch.hump(
                flight.progress,
                peak: metrics.lensStretchPeak
            ) * metrics.lensStretch
        ) * travelDistance
        let leading = center + flight.direction * width / 2
        let trailing = center - flight.direction * (width / 2 + stretch)
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
    /// as a smear rather than as one thing becoming another. So the strip leaves
    /// first and the panel follows, with only a short low-opacity overlap that
    /// prevents an empty frame between them.
    ///
    /// Smoothstepped, so neither end of a fade is a corner.
    static func ramp(_ progress: Double, from start: Double, to end: Double) -> Double {
        guard end > start else { return progress >= end ? 1 : 0 }
        let travelled = min(max((progress - start) / (end - start), 0), 1)
        return travelled * travelled * (3 - 2 * travelled)
    }

    /// How visible the collapsed strip is along the reversible morph path.
    ///
    /// It leaves quickly while opening and starts returning before the final
    /// third of closing. Its small overlap with the nearly transparent panel
    /// avoids a frame where neither state visually belongs to the glass.
    static func stripVisibility(at progress: Double) -> Double {
        1 - ramp(progress, from: 0, to: 0.45)
    }

    /// How visible expanded content is along the reversible morph path.
    ///
    /// Ending at one rather than holding a fully opaque plateau makes the panel
    /// react on the first interpolated frame of a close. Using one curve in both
    /// directions also keeps rapid reversals continuous.
    static func panelVisibility(at progress: Double) -> Double {
        ramp(progress, from: 0.25, to: 1)
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

    /// Commits the lens to a selected tab without losing an existing landing.
    ///
    /// A drag schedules its landing before it updates the selection binding.
    /// The binding observer then asks for the same transition. Returning the
    /// existing flight in that case is essential: replacing it would discard
    /// the finger's release position and briefly send the lens back through the
    /// previously selected tab.
    func committingSelection(to destination: Double, animated: Bool) -> Self {
        guard animated else { return .init(resting: destination) }
        guard !(isTravelling && self.destination == destination) else {
            return self
        }
        return .init(
            position: destination,
            origin: position,
            destination: destination
        )
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
    private let collapseAnimation: Animation
    private let showsToggle: Bool
    private let expandedContent: () -> Expanded

    @State private var expandedContentSize: CGSize = .zero
    @State private var availableWidth: CGFloat = 0
    /// Where the lens is, and how far through a move.
    ///
    /// Held here rather than in the strip because the lens is cut out of the
    /// bar's glass, which is drawn at this level.
    @State private var flight = EazyMorphingTabBarLensFlight(resting: 0)
    /// Which tab is currently under an active press.
    @State private var pressedIndex: Int?
    /// Ideal content widths for the two labelled arrangements. Keeping separate
    /// caches prevents an orientation change from briefly applying landscape
    /// measurements to the portrait bar, or vice versa.
    @State private var measuredStackedTabWidths: [EazyTab.ID: CGFloat] = [:]
    @State private var measuredTrailingTabWidths: [EazyTab.ID: CGFloat] = [:]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Whether a scroll has asked the bar to collapse, and the way back out.
    /// Published by ``SwiftUICore/View/eazyTabBarMinimizeBehavior(_:)``; the
    /// default proxy tracks nothing, so a bar with no behavior attached never
    /// collapses.
    @Environment(\.eazyTabBarMinimize) private var minimize
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
    ///   - collapseAnimation: How the bar collapses into its circle and back.
    ///     The default is measured off the system's own: filmed collapsing, its
    ///     selection overshoots its resting place by about three percent of the
    ///     distance it covered and settles back over roughly half a second.
    ///     Ignored when Reduce Motion is on.
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
        collapseAnimation: Animation = .spring(duration: 0.5, bounce: 0.12),
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
        self.collapseAnimation = collapseAnimation
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
            // Leading-aligned, and centred by an offset rather than by the
            // alignment. A bar narrower than the room it is given does sit in
            // the middle — that is where the system puts one that does not
            // spread — but the circle it collapses into does not: that sits a
            // fixed 28 points from the screen's leading edge whatever the strip
            // above it measured, level with an inline bottom accessory, which
            // has no idea how many tabs there were. Carrying the centring in an
            // offset lets it unwind as the bar collapses, so both are true.
            .overlay(alignment: .bottomLeading) {
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

    /// Whether the bar is drawing its collapsed circle.
    ///
    /// A bar whose panel is open is not a candidate: there is nothing sensible
    /// to collapse a panel of actions into, and the toggle that closes it would
    /// go with the strip. So the panel wins, and the scroll is ignored until it
    /// is closed.
    private var isCollapsed: Bool {
        minimize.isTracking && minimize.isMinimized && !isExpanded && !tabs.isEmpty
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
        flight = flight.committingSelection(
            to: Double(current),
            animated: !reduceMotion && previous != current
        )
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
            tabWidths: resolvedTabWidths,
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
    /// tabs are as wide as their titles, with each measured width passed to the
    /// layout independently.
    private var scaledMetrics: EazyMorphingTabBarMetrics {
        var scaled = activeMetrics
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

    /// Measured widths in tab order, available only after every tab in the
    /// active arrangement has reported a valid size. Falling back as one set
    /// avoids a partially-sized bar shifting several times on first layout.
    private var resolvedTabWidths: [CGFloat]? {
        let measured: [EazyTab.ID: CGFloat]
        switch activeMetrics.titlePlacement {
        case .below:
            measured = measuredStackedTabWidths
        case .trailing:
            measured = measuredTrailingTabWidths
        case .hidden:
            return nil
        }

        let widths = tabs.compactMap { measured[$0.id] }
        guard widths.count == tabs.count, widths.allSatisfy({ $0 > 0 }) else {
            return nil
        }

        guard activeMetrics.titlePlacement == .below else { return widths }
        let padded = widths.map {
            max(scaledMetrics.tabWidth, $0 + scaledMetrics.longTitlePadding)
        }
        // Ordinary portrait titles keep the measured fixed geometry exactly.
        // Variable widths activate only when at least one title outgrows it.
        guard padded.contains(where: { $0 > scaledMetrics.tabWidth }) else {
            return nil
        }
        return padded
    }

    /// How far a bar narrower than its room is pushed off the leading edge to
    /// centre it.
    ///
    /// Spent by the collapse: the circle belongs to the screen's edge, not to
    /// the strip's.
    private func centeringOffset(_ layout: EazyMorphingTabBarLayout) -> CGFloat {
        max((availableWidth - layout.canvasSize.width) / 2, 0)
    }

    private func canvas(_ layout: EazyMorphingTabBarLayout) -> some View {
        ZStack(alignment: .bottomLeading) {
            EazyMorphingTabBarStrip(
                tabs: tabs,
                selection: $selection,
                flight: $flight,
                pressedIndex: $pressedIndex,
                tint: tint,
                layout: layout,
                selectionAnimation: reduceMotion ? nil : selectionAnimation
            )
            .frame(width: layout.barSize.width, height: layout.barSize.height)
            // Fades on the surface's own clock rather than on the boolean, so
            // the strip is gone by the time there is a panel where it was — and
            // by the time there is a circle where it was.
            .modifier(EazyMorphingTabBarStripFade())
            .allowsHitTesting(!isExpanded && !isCollapsed)
            .accessibilityHidden(isExpanded || isCollapsed)

            EazyMorphingTabBarPanel(layout: layout) {
                expandedContent()
            }
            .allowsHitTesting(isExpanded)
            .accessibilityHidden(!isExpanded)

            if minimize.isTracking, let selected = tabs[safe: selectedIndex] {
                EazyMorphingTabBarCollapsedTab(
                    tab: selected,
                    tint: tint,
                    metrics: layout.metrics,
                    rect: layout.collapsedRect
                ) {
                    minimize.setMinimized(false)
                }
                .allowsHitTesting(isCollapsed)
                .accessibilityHidden(!isCollapsed)
            }

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
                .modifier(EazyMorphingTabBarCollapseFade())
                .allowsHitTesting(!isCollapsed)
                .accessibilityHidden(isCollapsed)
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
            switch layout.metrics.titlePlacement {
            case .below:
                EazyMorphingTabBarTabMeasure(
                    tabs: tabs,
                    metrics: layout.metrics,
                    widths: $measuredStackedTabWidths
                )
            case .trailing:
                EazyMorphingTabBarTabMeasure(
                    tabs: tabs,
                    metrics: layout.metrics,
                    widths: $measuredTrailingTabWidths
                )
            case .hidden:
                EmptyView()
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
                        // A collapsed bar has no toggle beside it, so the glass
                        // must stop merging with one: a shape left in the merge
                        // keeps a bridge of glass reaching out to nothing.
                        toggle: showsToggle && !isCollapsed
                            ? .capsule(layout.toggleRect)
                            : .none,
                        flight: flight,
                        pressedIndex: pressedIndex,
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
        // Unwound by the collapse, so the circle lands on the screen's leading
        // inset rather than on the centered strip's. Driven by the same value as
        // the collapse clock below, so the two travel together.
        .offset(x: isCollapsed ? 0 : centeringOffset(layout))
        // A clock of its own, for the same reason the morph has one: the strip
        // leaving, the glass shrinking and the circle arriving are three things
        // that have to keep step, and three springs of the same nominal length
        // do not.
        .modifier(EazyMorphingTabBarCollapse(progress: isCollapsed ? 1 : 0))
        .animation(reduceMotion ? nil : collapseAnimation, value: isCollapsed)
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
        selectionAnimation: Animation = .spring(duration: 0.4, bounce: 0.15),
        collapseAnimation: Animation = .spring(duration: 0.5, bounce: 0.12)
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
            collapseAnimation: collapseAnimation,
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
private struct EazyMorphingTabBarSurface: ViewModifier, @MainActor Animatable {
    let layout: EazyMorphingTabBarLayout
    /// The toggle, in the canvas's space.
    let toggle: EazyLiquidGlassShape
    /// Where the lens is, and how far through a move. Animated.
    var flight: EazyMorphingTabBarLensFlight
    /// Which tab is currently under an active press.
    let pressedIndex: Int?
    /// The lens the flight puts on the glass, in the surface's own space.
    let lens: (EazyMorphingTabBarLensFlight) -> EazyLiquidGlassShape
    let style: EazyLiquidGlassStyle

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    /// How far the surface is through its morph. Arrives already interpolated,
    /// a frame at a time, from the modifier that owns that clock.
    @Environment(\.eazyMorphingTabBarMorphProgress) private var morph
    /// How far the bar is through collapsing into its circle. Arrives already
    /// interpolated, a frame at a time, like the morph beside it.
    @Environment(\.eazyMorphingTabBarCollapseProgress) private var collapse
    var animatableData: Double {
        get { flight.position }
        set { flight.position = newValue }
    }

    private let maxScaleEffect: CGFloat = 1.06

    private var backgroundScale: CGFloat {
        let travelProgress = flight.isTravelling ? flight.progress : 0
        let triangularProgress = 1 - abs(travelProgress * 2 - 1)
        let easedProgress = triangularProgress * triangularProgress * (3 - 2 * triangularProgress)
        let travelScale = 1 + (maxScaleEffect - 1) * CGFloat(easedProgress)
        let pressScale = pressedIndex == nil ? 1 : maxScaleEffect
        return max(travelScale, pressScale)
    }

    func body(content: Content) -> some View {
        // This layer stands taller than the canvas so the surface has room to
        // overshoot, and its bottom edges are aligned; everything given in the
        // canvas's own space therefore sits that much further down in this one.
        let lift = layout.stretchHeadroom.height
        var shape = layout.surface(expandedBy: morph, collapsedBy: collapse)
        shape.frame.origin.y += lift
        var lens = self.lens(flight)
        lens.frame.origin.y += lift
        var toggle = self.toggle
        toggle.frame.origin.y += lift
        // The selection has no meaning once the strip has gone, so the glass
        // closes over it as the panel opens — or as the bar collapses — rather
        // than losing it in one frame. Left open through a collapse the lens
        // would end up clearing the whole circle, since the circle is the size
        // the lens has shrunk to.
        let clearing = layout.metrics.lensClearing
            * (1 - min(max(morph, 0), 1))
            * (1 - min(max(collapse, 0), 1))

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
    @Environment(\.eazyMorphingTabBarCollapseProgress) private var collapse

    func body(content: Content) -> some View {
        // Two clocks can take the strip away, and only the one that has gone
        // furthest should be believed: multiplying them would let a bar that is
        // half collapsed and half expanded show a strip at a quarter strength
        // it never asked for.
        let showing = min(
            EazyMorphingTabBarStretch.stripVisibility(at: morph),
            EazyMorphingTabBarStretch.stripVisibility(at: collapse)
        )
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

    var body: some View {
        let progress = min(max(morph, 0), 1)
        let surface = layout.surface(expandedBy: progress)
        // The panel shares the canvas's bottom leading corner, so the surface's
        // rectangle needs only shifting into the panel's own space.
        let clip = surface.frame.offsetBy(
            dx: -layout.panelRect.minX,
            dy: -layout.panelRect.minY
        )

        content
            .frame(width: layout.panelSize.width, height: layout.panelSize.height)
            // Starts after the strip is mostly gone and reaches full strength
            // only when the surface reaches the panel.
            .opacity(
                EazyMorphingTabBarStretch.panelVisibility(at: progress)
            )
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

/// Carries how far the bar is through its collapse down to everything drawn in
/// it.
///
/// A second clock beside ``EazyMorphingTabBarMorph``, and for the same reason:
/// the strip fading, the glass shrinking and the circle arriving all have to
/// land together, and giving each its own spring of the same nominal length is
/// what puts them out of step.
private struct EazyMorphingTabBarCollapse: ViewModifier, @preconcurrency Animatable {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content.environment(\.eazyMorphingTabBarCollapseProgress, progress)
    }
}

/// Takes a control away as the bar collapses.
///
/// Used for the toggle, which has nowhere to be beside a 48-point circle. On
/// the collapse's clock, so it is gone by the time the glass has shrunk past
/// where it was standing.
private struct EazyMorphingTabBarCollapseFade: ViewModifier {
    @Environment(\.eazyMorphingTabBarCollapseProgress) private var collapse

    func body(content: Content) -> some View {
        let showing = 1 - EazyMorphingTabBarStretch.ramp(collapse, from: 0, to: 0.45)
        return content
            .opacity(showing)
            .blur(radius: 4 * (1 - showing))
            .scaleEffect(0.8 + 0.2 * showing)
    }
}

/// What the bar shows once it has collapsed: the selected tab's symbol, and
/// nothing else.
///
/// The symbol is centered here, where in the strip it sits well above centre to
/// leave the lower half of the box to a label. There is no label to leave room
/// for in a circle, and the system centres its own.
///
/// It is a button, because the collapsed bar is the only way back to the strip
/// without scrolling: the system restores its bar when this is tapped, so this
/// one does too.
private struct EazyMorphingTabBarCollapsedTab: View {
    let tab: EazyTab
    let tint: Color
    let metrics: EazyMorphingTabBarMetrics
    let rect: CGRect
    let onTap: () -> Void

    @Environment(\.eazyMorphingTabBarCollapseProgress) private var collapse

    var body: some View {
        Button(action: onTap) {
            Image(systemName: tab.systemImage)
                .symbolVariant(.fill)
                .font(.system(size: metrics.symbolSize, weight: .regular))
                .foregroundStyle(tint)
                .frame(width: rect.width, height: rect.height)
                .contentShape(.circle)
        }
        .buttonStyle(EazyGlassPressStyle(scale: 0.92))
        .accessibilityLabel(Text(tab.title))
        .accessibilityHint(Text("Shows the tab bar"))
        .accessibilityAddTraits([.isButton, .isSelected])
        // Arrives only once the glass has most of the way shrunk, on the same
        // clock, so the symbol is never sitting outside the circle that holds
        // it — the mirror of the strip leaving.
        .modifier(EazyMorphingTabBarCollapsedTabFade())
        // The canvas is bottom-leading anchored and the circle is shorter than
        // the bar, so it has to be lifted by the inset that centres it in the
        // band the bar occupied.
        .offset(x: rect.minX, y: -(metrics.barHeight - rect.height) / 2)
    }
}

/// Brings the collapsed symbol in as the glass finishes shrinking.
private struct EazyMorphingTabBarCollapsedTabFade: ViewModifier {
    @Environment(\.eazyMorphingTabBarCollapseProgress) private var collapse

    func body(content: Content) -> some View {
        let showing = EazyMorphingTabBarStretch.ramp(collapse, from: 0.35, to: 1)
        return content
            .opacity(showing)
            .blur(radius: 4 * (1 - showing))
            .scaleEffect(0.7 + 0.3 * showing)
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
    @Binding var pressedIndex: Int?
    let tint: Color
    let layout: EazyMorphingTabBarLayout
    let selectionAnimation: Animation?

    @State private var dragPressedIndex: Int?
    @Environment(\.eazyTabReselectionHandler) private var reselection

    private var metrics: EazyMorphingTabBarMetrics { layout.metrics }

    var body: some View {
        HStack(spacing: layout.stripSpacing) {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                EazyMorphingTabBarTab(
                    tab: tab,
                    isSelected: tab.id == selection,
                    // Nil until a drag starts, so an ordinary tap still uses the
                    // button's own press and release state.
                    isPressed: dragPressedIndex.map { $0 == index },
                    tint: tint,
                    metrics: metrics,
                    width: layout.tabHitWidth(at: index),
                    boxWidth: layout.tabWidth(at: index),
                    onPressChanged: { isPressed in
                        withAnimation(selectionAnimation) {
                            pressedIndex = isPressed ? index : nil
                        }
                    }) {
                    select(tab)
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

    /// Dragging keeps the bar in its pressed state while the finger is down, then
    /// commits the landing tab once on release.
    ///
    /// It takes priority over the tab buttons rather than running alongside them.
    /// Sharing the touch let every button the finger crossed light up, and let
    /// the button the drag started on fire its own action on release — which
    /// selected the tab the finger had just left. The minimum distance still
    /// leaves an ordinary tap to the button underneath.
    private var drag: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                flight = .init(resting: layout.lensPosition(draggedTo: value.location.x))
                let index = layout.tabIndex(at: value.location.x)
                dragPressedIndex = index
                if pressedIndex == nil {
                    withAnimation(selectionAnimation) { pressedIndex = index }
                } else {
                    pressedIndex = index
                }
            }
            .onEnded { value in
                dragPressedIndex = nil
                withAnimation(selectionAnimation) { pressedIndex = nil }
                let landingIndex = layout.tabIndex(at: value.location.x)
                let landing = Double(landingIndex)
                // Schedule the landing before changing the binding. The parent
                // observes that binding too, and the idempotent transition keeps
                // this release position as the journey's origin instead of
                // replacing it with the previously selected tab.
                flight = flight.committingSelection(
                    to: landing,
                    animated: selectionAnimation != nil
                )
                guard let tab = tabs[safe: landingIndex] else { return }
                select(tab, isTap: false)
            }
    }

    /// - Parameter isTap: Whether this came from a tap rather than from the end
    ///   of a drag. A drag that lands back on the tab it started on has not
    ///   asked for anything, so it reports nothing.
    private func select(_ tab: EazyTab, isTap: Bool = true) {
        guard tab.id != selection else {
            // Tapping the tab already showing is not nothing — the system takes
            // that screen back to the top. The bar has no way to do that
            // itself, so it says the tap happened and leaves it to whoever owns
            // the content. No haptic: nothing has been selected.
            if isTap { reselection.handle(tab.id) }
            return
        }
        selection = tab.id
        EazyHaptics.selection()
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
    let onPressChanged: (Bool) -> Void
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
        .buttonStyle(EazyGlassPressStyle(isPressed: isPressed, onPressChanged: onPressChanged))
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
    /// the symbol and ten after the title; here the combined inset is shared
    /// evenly while every tab keeps its own measured width.
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

/// Lays every tab out at its ideal size, out of sight, and reports each width.
///
/// Only the short arrangement needs this. There a tab is as wide as its own
/// title — the system's run from 81 points for "Inbox" to 93 for "Settings" —
/// and a title's width is not something a layout can be told in advance, only
/// measured. Keeping every result independently prevents one long title from
/// widening every tab in the bar.
///
/// Nothing measured here depends on the bar's own size, so reading it back into
/// the layout cannot feed on itself.
private struct EazyMorphingTabBarTabMeasure: View {
    let tabs: [EazyTab]
    let metrics: EazyMorphingTabBarMetrics
    @Binding var widths: [EazyTab.ID: CGFloat]

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
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.width
                } action: { newValue in
                    widths[tab.id] = newValue
                }
            }
        }
        .hidden()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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
    var onPressChanged: (Bool) -> Void = { _ in }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let pressed = isPressed ?? configuration.isPressed
        return configuration.label
            .scaleEffect(pressed && !reduceMotion ? scale : 1)
            .animation(.spring(response: 0.26, dampingFraction: 0.7), value: pressed)
            .onChange(of: pressed) { _, isPressed in
                guard self.isPressed == nil else { return }
                onPressChanged(isPressed)
            }
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
            onPerform()
            action.handler()
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
        return EazyMorphingTabBarStretch.panelVisibility(at: morph)
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

private struct EazyMorphingTabBarCollapseProgressKey: EnvironmentKey {
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

    /// How far the enclosing ``EazyMorphingTabBar`` is through collapsing into
    /// its circle, from nothing at the full strip to one at the circle.
    ///
    /// Updated every frame while the bar is collapsing, and briefly outside
    /// zero and one where the spring overshoots. Read it for content that has
    /// to keep step with the collapse rather than with the boolean that started
    /// it.
    var eazyMorphingTabBarCollapseProgress: Double {
        get { self[EazyMorphingTabBarCollapseProgressKey.self] }
        set { self[EazyMorphingTabBarCollapseProgressKey.self] = newValue }
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
        EazyTab(systemImage: "tray", title: "Departments"),
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

            ScrollView {
                ForEach(0..<100, id: \.self) { _ in
                    Rectangle()
                        .frame(height: 66)
                       
                }
            }

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
        EazyTab(systemImage: "tray", title: "Departments"),
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
    private static let nativeSearchID = "native-search"

    @State private var nativeSelection = "tray"
    @State private var customSelection = "tray"
    @State private var isExpanded = false

    private let tabs: [EazyTab] = [
        EazyTab(systemImage: "house", title: "Home"),
        EazyTab(systemImage: "tray", title: "Departments and Ministries"),
        EazyTab(systemImage: "bell", title: "Calendar"),
        EazyTab(systemImage: "square.stack", title: "Library")
    ]

    private var actions: [EazyTabBarAction] {
        []
    }

    var body: some View {
        TabView(selection: $nativeSelection) {
            ForEach(tabs) { tab in
                Tab(value: tab.id) {
                    comparisonCanvas
                } label: {
                    Label(tab.title, systemImage: tab.systemImage)
                }
            }

            // Search is the system's detached trailing tab and therefore the
            // closest native reference for the custom bar's action toggle.
            Tab(value: Self.nativeSearchID, role: .search) {
                comparisonCanvas
            }
        }
        .onChange(of: nativeSelection) { _, current in
            guard tabs.contains(where: { $0.id == current }) else { return }
            customSelection = current
        }
        .onChange(of: customSelection) { _, current in
            nativeSelection = current
        }
    }

    private var comparisonCanvas: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [.indigo, .purple, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            EazyMorphingTabBar(
                tabs: tabs,
                selection: $customSelection,
                isExpanded: $isExpanded,
                actions: actions
            )
            .padding(.bottom, EazyMorphingTabBarMetrics.screenInset)
        }
    }
}
