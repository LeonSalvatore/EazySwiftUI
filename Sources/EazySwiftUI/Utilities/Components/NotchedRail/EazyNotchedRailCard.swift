import SwiftUI

/// Layout settings for ``EazyNotchedRailCard``.
public struct EazyNotchedRailCardConfiguration {
    /// The width and height of each rail item, and the rail's width.
    public var railWidth: CGFloat
    /// The notch depth as a fraction of `railWidth`.
    public var notchDepthRatio: CGFloat
    /// The width of the rail's selection capsule.
    public var selectionPillWidth: CGFloat
    /// The radius of the card's bottom corners.
    public var bottomCornerRadius: CGFloat
    /// The gap between the card and the container's leading, trailing, and top edges.
    public var cardInset: CGFloat
    /// The header's horizontal padding.
    public var headerHorizontalPadding: CGFloat
    /// The gap between the top safe area and the header.
    public var headerTopSpacing: CGFloat
    /// The minimum distance between the top safe area and the rail's area,
    /// used when the measured header is shorter.
    public var minimumRailTopClearance: CGFloat
    /// The bottom bar's padding.
    public var bottomBarPadding: EdgeInsets

    /// Creates card layout settings.
    public init(
        railWidth: CGFloat = 44,
        notchDepthRatio: CGFloat = 0.825,
        selectionPillWidth: CGFloat = 30,
        bottomCornerRadius: CGFloat = 44,
        cardInset: CGFloat = 4,
        headerHorizontalPadding: CGFloat = 20,
        headerTopSpacing: CGFloat = 8,
        minimumRailTopClearance: CGFloat = 56,
        bottomBarPadding: EdgeInsets = EdgeInsets(top: 12, leading: 12, bottom: 8, trailing: 12)
    ) {
        self.railWidth = max(railWidth, 1)
        self.notchDepthRatio = min(max(notchDepthRatio, 0), 1)
        self.selectionPillWidth = selectionPillWidth
        self.bottomCornerRadius = max(bottomCornerRadius, 0)
        self.cardInset = cardInset
        self.headerHorizontalPadding = headerHorizontalPadding
        self.headerTopSpacing = headerTopSpacing
        self.minimumRailTopClearance = minimumRailTopClearance
        self.bottomBarPadding = bottomBarPadding
    }

    /// The horizontal depth of the card's cutout.
    public var notchDepth: CGFloat { railWidth * notchDepthRatio }
}

/// A full-screen card with a header, content, and bottom bar, whose edge holds
/// an animated notch for an ``EazyControlRail``.
///
/// The card owns the rail's expansion state and reshapes the notch as the rail
/// scrolls and expands. Content reads the notch through
/// ``SwiftUICore/EnvironmentValues/eazyNotchedRailContentRegion``; apply
/// ``SwiftUICore/View/eazyNotchedRailAdaptiveInset(_:)`` to rows so they clear it.
///
/// ```swift
/// EazyNotchedRailCard(
///     items: sections,
///     selection: $selection,
///     fill: gradient.secondary,
///     placement: placement
/// ) { $0.title } icon: { section in
///     Image(systemName: section.symbol)
/// } header: {
///     Text("Library").font(.largeTitle.bold())
/// } content: {
///     ScrollView {
///         ForEach(rows) { row in
///             RowView(row).eazyNotchedRailAdaptiveInset()
///         }
///     }
/// } bottomBar: {
///     SearchField()
/// }
/// ```
public struct EazyNotchedRailCard<
    Item: Identifiable,
    ItemIcon: View,
    Header: View,
    Content: View,
    BottomBar: View
>: View {
    private let items: [Item]
    @Binding private var selection: Item.ID?
    private let fill: AnyShapeStyle
    private let background: AnyShapeStyle?
    private let selectionTint: Color
    private let placement: EazyControlRailPlacement
    private let bottomBoundary: CGFloat?
    private let isBottomBarFocused: Bool
    private let configuration: EazyNotchedRailCardConfiguration
    private let isEnabled: (Item) -> Bool
    private let isSelectable: (Item) -> Bool
    private let accessibilityIdentifier: (Item) -> String
    private let accessibilityValue: (Item) -> String
    private let onActivate: (Item) -> Void
    private let title: (Item) -> String
    private let icon: (Item) -> ItemIcon
    private let header: () -> Header
    private let content: () -> Content
    private let bottomBar: () -> BottomBar

    @State private var collapsedBottomBarHeight: CGFloat = 80

    /// Creates a notched rail card.
    ///
    /// - Parameters:
    ///   - fill: The card's fill.
    ///   - background: The style behind the card. `nil` uses the system background.
    ///   - placement: The rail's docking position.
    ///   - bottomBoundary: A global y-coordinate the card and bottom bar stay
    ///     above, such as the top of a custom tab bar that overlaps this view.
    ///   - isBottomBarFocused: While `true`, the card extends behind the bottom
    ///     bar with square bottom corners, and the bar's measured height is
    ///     frozen so a growing bar (for example, an expanded search field)
    ///     does not resize the card.
    public init<Fill: ShapeStyle>(
        items: [Item],
        selection: Binding<Item.ID?>,
        fill: Fill,
        background: AnyShapeStyle? = nil,
        selectionTint: Color = .accentColor,
        placement: EazyControlRailPlacement = .topLeading,
        bottomBoundary: CGFloat? = nil,
        isBottomBarFocused: Bool = false,
        configuration: EazyNotchedRailCardConfiguration = .init(),
        isEnabled: @escaping (Item) -> Bool = { _ in true },
        isSelectable: @escaping (Item) -> Bool = { _ in true },
        accessibilityIdentifier: @escaping (Item) -> String = { _ in "" },
        accessibilityValue: @escaping (Item) -> String = { _ in "" },
        onActivate: @escaping (Item) -> Void = { _ in },
        title: @escaping (Item) -> String,
        @ViewBuilder icon: @escaping (Item) -> ItemIcon,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder bottomBar: @escaping () -> BottomBar
    ) {
        self.items = items
        self._selection = selection
        self.fill = AnyShapeStyle(fill)
        self.background = background
        self.selectionTint = selectionTint
        self.placement = placement
        self.bottomBoundary = bottomBoundary
        self.isBottomBarFocused = isBottomBarFocused
        self.configuration = configuration
        self.isEnabled = isEnabled
        self.isSelectable = isSelectable
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityValue = accessibilityValue
        self.onActivate = onActivate
        self.title = title
        self.icon = icon
        self.header = header
        self.content = content
        self.bottomBar = bottomBar
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // The card and rail retain their normal viewport while the keyboard
            // and an expanded bottom bar occupy an independent foreground layer.
            GeometryReader { screen in
                VStack(spacing: 0) {
                    EazyNotchedRailCardArea(
                        items: items,
                        selection: $selection,
                        fill: fill,
                        selectionTint: selectionTint,
                        placement: placement,
                        isBottomBarFocused: isBottomBarFocused,
                        collapsedBottomBarHeight: collapsedBottomBarHeight,
                        safeTop: screen.safeAreaInsets.top,
                        configuration: configuration,
                        isEnabled: isEnabled,
                        isSelectable: isSelectable,
                        accessibilityIdentifier: accessibilityIdentifier,
                        accessibilityValue: accessibilityValue,
                        onActivate: onActivate,
                        title: title,
                        icon: icon,
                        header: header,
                        content: content
                    )
                    .padding(.horizontal, configuration.cardInset)
                    .padding(.top, configuration.cardInset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Color.clear
                        .frame(height: collapsedBottomBarHeight)
                }
                .padding(.bottom, bottomOverlap(in: screen))
                .background(background ?? AnyShapeStyle(.background))
                .ignoresSafeArea(edges: .top)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)

            EazyNotchedRailBottomBarLayer(
                bottomBoundary: bottomBoundary,
                padding: configuration.bottomBarPadding,
                isBottomBarFocused: isBottomBarFocused,
                collapsedHeight: $collapsedBottomBarHeight,
                bottomBar: bottomBar
            )
        }
    }

    private func bottomOverlap(in screen: GeometryProxy) -> CGFloat {
        eazyNotchedRailBottomOverlap(
            contentBottom: screen.frame(in: .global).maxY,
            bottomBoundary: bottomBoundary
        )
    }
}

/// How far a view ending at `contentBottom` extends below `bottomBoundary`.
func eazyNotchedRailBottomOverlap(contentBottom: CGFloat, bottomBoundary: CGFloat?) -> CGFloat {
    max(0, contentBottom - (bottomBoundary ?? contentBottom))
}

// MARK: - Bottom Bar

private struct EazyNotchedRailBottomBarLayer<BottomBar: View>: View {
    let bottomBoundary: CGFloat?
    let padding: EdgeInsets
    let isBottomBarFocused: Bool
    @Binding var collapsedHeight: CGFloat
    let bottomBar: () -> BottomBar

    var body: some View {
        GeometryReader { screen in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                bottomBar()
                    .padding(padding)
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                        if !isBottomBarFocused {
                            collapsedHeight = height
                        }
                    }
            }
            .padding(.bottom, eazyNotchedRailBottomOverlap(
                contentBottom: screen.frame(in: .global).maxY,
                bottomBoundary: bottomBoundary
            ))
        }
    }
}

// MARK: - Card Area

private struct EazyNotchedRailCardArea<
    Item: Identifiable,
    ItemIcon: View,
    Header: View,
    Content: View
>: View {
    let items: [Item]
    @Binding var selection: Item.ID?
    let fill: AnyShapeStyle
    let selectionTint: Color
    let placement: EazyControlRailPlacement
    let isBottomBarFocused: Bool
    let collapsedBottomBarHeight: CGFloat
    let safeTop: CGFloat
    let configuration: EazyNotchedRailCardConfiguration
    let isEnabled: (Item) -> Bool
    let isSelectable: (Item) -> Bool
    let accessibilityIdentifier: (Item) -> String
    let accessibilityValue: (Item) -> String
    let onActivate: (Item) -> Void
    let title: (Item) -> String
    let icon: (Item) -> ItemIcon
    let header: () -> Header
    let content: () -> Content

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var railExpansion = EazyControlRailExpansion()
    @State private var headerHeight: CGFloat = 0

    private var railWidth: CGFloat { configuration.railWidth }
    private var notchDepth: CGFloat { configuration.notchDepth }

    var body: some View {
        GeometryReader { geometry in
            let bottomCornerRadius = configuration.bottomCornerRadius
            // The complete header owns a full-width safe-area inset. Keep the
            // rail below its measured bounds for either leading or trailing
            // placement, including wrapped titles and larger text sizes.
            let railAreaTop = max(safeTop + configuration.minimumRailTopClearance, headerHeight) + 12
            let railAreaBottom = geometry.size.height - bottomCornerRadius - 8
            let availableRailHeight = max(0, railAreaBottom - railAreaTop)
            let preferredItemCount = geometry.size.height < 500 || dynamicTypeSize.isAccessibilitySize ? 3 : 5
            let visibleItemCount = min(preferredItemCount,
                availableRailHeight >= railWidth * 5 ? 5 : availableRailHeight >= railWidth * 3 ? 3 : 1)
            let fitted = railExpansion.fittedExtents(maxHeight: availableRailHeight)
            let notchHeight = max(0, fitted.top + fitted.bottom - 2)
            let layoutHalfExtent = min(railExpansion.layoutHalfExtent, availableRailHeight / 2)
            let minimumCenterY = railAreaTop + layoutHalfExtent
            let maximumCenterY = railAreaBottom - layoutHalfExtent
            let railCenter = placement.center(
                in: geometry.size,
                notchDepth: notchDepth,
                verticalBounds: minimumCenterY...max(minimumCenterY, maximumCenterY)
            )
            let notchCenterY = railCenter.y + (fitted.bottom - fitted.top) / 2
            let backgroundHeight = geometry.size.height + (isBottomBarFocused ? collapsedBottomBarHeight : 0)
            let notchRegion = EazyNotchedRailContentRegion(
                top: notchCenterY - notchHeight / 2,
                bottom: notchCenterY + notchHeight / 2,
                depth: notchDepth,
                isTrailing: placement.isTrailing
            )
            let outerShape = cardOuterShape(bottomCornerRadius: isBottomBarFocused ? 0 : bottomCornerRadius)

            ZStack(alignment: .topLeading) {
                EazyNotchedCardShape(
                    cornerRadius: 0,
                    notchDepth: notchDepth,
                    notchCenterYFraction: notchCenterY / max(backgroundHeight, 1),
                    notchHeight: notchHeight,
                    shoulderHeight: railExpansion.shoulderHeight,
                    placement: placement
                )
                .fill(fill)
                .frame(height: backgroundHeight)
                .clipShape(outerShape)
                .accessibilityHidden(true)

                content()
                    .environment(\.eazyNotchedRailContentRegion, notchRegion)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(outerShape)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        header()
                            .padding(.horizontal, configuration.headerHorizontalPadding)
                            .padding(.top, safeTop + configuration.headerTopSpacing)
                            .frame(maxWidth: .infinity)
                            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
                                headerHeight = $0
                            }
                    }

                if availableRailHeight >= railWidth {
                    EazyControlRail(
                        items: items,
                        selection: $selection,
                        expansion: $railExpansion,
                        configuration: .init(
                            itemWidth: railWidth,
                            itemHeight: railWidth,
                            visibleItemCount: visibleItemCount,
                            selectionTint: selectionTint,
                            selectionPillWidth: configuration.selectionPillWidth,
                            notchDepth: notchDepth
                        ),
                        placement: placement,
                        isEnabled: isEnabled,
                        isSelectable: isSelectable,
                        accessibilityIdentifier: accessibilityIdentifier,
                        accessibilityValue: accessibilityValue,
                        onActivate: onActivate,
                        title: title,
                        icon: icon
                    )
                    .frame(width: railWidth)
                    .position(railCenter)
                }
            }
            // Extending the background behind the bottom bar must not recenter the header.
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            .coordinateSpace(.named(EazyNotchedRailContentRegion.coordinateSpace))
        }
    }

    private func cardOuterShape(bottomCornerRadius: CGFloat) -> AnyShape {
        if #available(iOS 26.0, macOS 26.0, *) {
            AnyShape(ConcentricRectangle(
                uniformTopCorners: .concentric,
                uniformBottomCorners: .fixed(bottomCornerRadius)
            ))
        } else {
            AnyShape(ContainerRelativeShape().intersection(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: bottomCornerRadius,
                    bottomTrailingRadius: bottomCornerRadius
                )
            ))
        }
    }
}
