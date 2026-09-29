import SwiftUI

/// Matches the card's concave shoulder so wheel items cannot draw over its fill.
private struct RailNotchMask: Shape {
    var notchDepth: CGFloat
    var notchHeight: CGFloat
    var centerOffset: CGFloat
    var shoulderHeight: CGFloat
    var placement: EazyControlRailPlacement = .topLeading

    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>> {
        get { AnimatablePair(notchHeight, AnimatablePair(centerOffset, shoulderHeight)) }
        set {
            notchHeight = newValue.first
            centerOffset = newValue.second.first
            shoulderHeight = newValue.second.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let depth = min(max(notchDepth, 0), rect.width)
        let top = rect.midY + centerOffset - notchHeight / 2
        let bottom = rect.midY + centerOffset + notchHeight / 2
        guard depth > 0, bottom > top else { return Path() }

        let left = rect.midX - depth / 2
        let right = rect.midX + depth / 2
        let upperShoulder = min(shoulderHeight, notchHeight / 3)
        let lowerShoulder = min(shoulderHeight, notchHeight / 3)

        var path = Path()
        path.move(to: CGPoint(x: left, y: top))
        path.addCurve(
            to: CGPoint(x: right, y: top + upperShoulder),
            control1: CGPoint(x: left, y: top + upperShoulder * 0.636),
            control2: CGPoint(x: right, y: top + upperShoulder * 0.326)
        )
        path.addLine(to: CGPoint(x: right, y: bottom - lowerShoulder))
        path.addCurve(
            to: CGPoint(x: left, y: bottom),
            control1: CGPoint(x: right, y: bottom - lowerShoulder * 0.314),
            control2: CGPoint(x: left, y: bottom - lowerShoulder * 0.683)
        )
        path.closeSubpath()
        if placement.isTrailing {
            return path.applying(CGAffineTransform(
                a: -1, b: 0, c: 0, d: 1, tx: rect.minX + rect.maxX, ty: 0
            ))
        }
        return path
    }
}

// MARK: - State

private struct ControlRailState<ID: Hashable> {

    var offset: CGFloat = 0
    var dragStartOffset: CGFloat = 0
    var isDragging: Bool = false
    var expandedItemID: ID?
    var titleTask: Task<Void, Never>?

    mutating func beginDrag() {
        isDragging = true
        dragStartOffset = offset
        expandedItemID = nil
        titleTask?.cancel()
        titleTask = nil
    }

    mutating func cancelTitleTask() {
        titleTask?.cancel()
        titleTask = nil
    }
}

// MARK: - Control Rail

/// A vertical icon wheel that sits inside a notched container.
///
/// Dragging scrolls the wheel and snaps to the nearest item; tapping an item
/// selects and activates it. After each selection a capsule briefly expands to
/// show the item's title. The rail publishes its live extents through
/// `expansion` so a container such as ``EazyNotchedCardShape`` can grow its
/// cutout in the same animation.
public struct EazyControlRail<Item: Identifiable, ItemIcon: View>: View {

    // MARK: Inputs

    private let items: [Item]
    @Binding private var selection: Item.ID?
    @Binding private var expansion: EazyControlRailExpansion
    private let configuration: EazyControlRailConfiguration
    private let placement: EazyControlRailPlacement
    private let title: (Item) -> String
    private let icon: (Item) -> ItemIcon
    private let isEnabled: (Item) -> Bool
    private let isSelectable: (Item) -> Bool
    private let accessibilityIdentifier: (Item) -> String
    private let accessibilityValue: (Item) -> String
    private let onActivate: (Item) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: State

    @State private var state = ControlRailState<Item.ID>()
    @ScaledMetric(relativeTo: .caption2) private var titleScale: CGFloat = 1

    // MARK: Convenience

    private var itemWidth: CGFloat { configuration.itemWidth }
    private var itemHeight: CGFloat { configuration.itemHeight }
    private var itemSpacing: CGFloat { configuration.itemSpacing }
    private var railHeight: CGFloat { configuration.railHeight }
    private var centerY: CGFloat { configuration.centerY }
    private var lastIndex: Int { max(items.count - 1, 0) }
    private var expandedItemHeight: CGFloat {
        min(railHeight, max(configuration.expandedHeight,
            min(railHeight * 0.85, configuration.expandedHeight * titleScale)))
    }

    private var minOffset: CGFloat { -CGFloat(lastIndex) * itemSpacing }
    private var maxOffset: CGFloat { 0 }

    private var continuousIndex: CGFloat { -state.offset / itemSpacing }
    private var currentIndex: Int { index(for: state.offset) }

    private var expandedIndex: Int? {
        guard let id = state.expandedItemID else { return nil }
        return items.firstIndex(where: { $0.id == id })
    }

    private var reflowShift: CGFloat {
        let extra = expandedItemHeight - itemHeight
        return max(extra / 2 + (itemHeight - itemSpacing)
            + configuration.expandedSpacing, 0)
    }

    // MARK: Init

    /// Creates a rail over `items`.
    ///
    /// - Parameters:
    ///   - expansion: Receives the rail's live extents. Pass it to a notched
    ///     container so its cutout follows the rail.
    ///   - isSelectable: Whether landing on an item changes `selection`. A
    ///     non-selectable item still triggers `onActivate` when tapped.
    public init(
        items: [Item],
        selection: Binding<Item.ID?>,
        expansion: Binding<EazyControlRailExpansion>? = nil,
        configuration: EazyControlRailConfiguration = .init(),
        placement: EazyControlRailPlacement = .topLeading,
        isEnabled: @escaping (Item) -> Bool = { _ in true },
        isSelectable: @escaping (Item) -> Bool = { _ in true },
        accessibilityIdentifier: @escaping (Item) -> String = { _ in "" },
        accessibilityValue: @escaping (Item) -> String = { _ in "" },
        onActivate: @escaping (Item) -> Void = { _ in },
        title: @escaping (Item) -> String,
        @ViewBuilder icon: @escaping (Item) -> ItemIcon
    ) {
        self.items = items
        self._selection = selection
        self._expansion = expansion ?? .constant(.init())
        self.configuration = configuration
        self.placement = placement
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.isSelectable = isSelectable
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityValue = accessibilityValue
        self.onActivate = onActivate
    }

    // MARK: Body

    public var body: some View {
        let railGeometry = calculatedRailGeometry()
        GeometryReader { geometry in
            ZStack {

                selectionIndicator
                    .position(
                        x: geometry.size.width / 2,
                        y: centerY
                    )

                ForEach(
                    Array(items.enumerated()),
                    id: \.element.id
                ) { index, item in
                    wheelItem(item, index: index)
                        .position(
                            x: geometry.size.width / 2,
                            y: yPosition(for: index)
                        )
                }
            }
            .frame(
                width: geometry.size.width,
                height: railHeight
            )
            .mask {
                RailNotchMask(
                    notchDepth: configuration.notchDepth,
                    notchHeight: max(1, railGeometry.activeRailHeight - 2),
                    centerOffset: railGeometry.notchCenterOffset,
                    shoulderHeight: railGeometry.shoulderHeight,
                    placement: placement
                )
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.65), location: 0.16),
                            .init(color: .white, location: 0.32),
                            .init(color: .white, location: 0.68),
                            .init(color: .white.opacity(0.65), location: 0.84),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .contentShape(
                RailNotchMask(
                    notchDepth: configuration.notchDepth,
                    notchHeight: max(1, railGeometry.activeRailHeight - 2),
                    centerOffset: railGeometry.notchCenterOffset,
                    shoulderHeight: railGeometry.shoulderHeight,
                    placement: placement
                )
            )
            .gesture(wheelGesture)
            .accessibilityElement(children: .contain)
            .accessibilityValue(Text(verbatim: items.indices.contains(currentIndex) ? title(items[currentIndex]) : ""))
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: moveAccessibilityFocus(by: 1)
                case .decrement: moveAccessibilityFocus(by: -1)
                @unknown default: break
                }
            }
            .onAppear {
                synchronizeFromSelection(animated: false)
                publishRailGeometry()
            }
            .onChange(of: expandedItemHeight) { _, _ in publishRailGeometry() }
            .onChange(of: configuration.railHeight) { _, _ in publishRailGeometry() }
            .onChange(of: configuration.itemSpacing) { _, _ in publishRailGeometry() }
            .onChange(of: configuration.expandedSpacing) { _, _ in publishRailGeometry() }
            .onChange(of: selection) { _, _ in
                guard !state.isDragging else { return }
                synchronizeFromSelection(animated: true)
            }
            .onChange(of: items.map(\.id)) { _, _ in
                if let expandedID = state.expandedItemID,
                   !items.contains(where: { $0.id == expandedID }) {
                    state.cancelTitleTask()
                    state.expandedItemID = nil
                    expansion.progress = 0
                }
                clampCurrentOffset(animated: true)
                synchronizeFromSelection(animated: true)
                publishRailGeometry()
            }
            .onDisappear {
                state.cancelTitleTask()
                state.expandedItemID = nil
                expansion.progress = 0
            }
        }
        .frame(height: railHeight)
    }
}

// MARK: - Selection Indicator

private extension EazyControlRail {

    @ViewBuilder
    var selectionIndicator: some View {
        let isExpanded = state.expandedItemID != nil

        ZStack {
            if let id = state.expandedItemID,
               let item = items.first(where: { $0.id == id }) {
                Text(verbatim: title(item))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .frame(width: expandedItemHeight - 8, height: configuration.selectionPillWidth)
                    .rotationEffect(.degrees(90))
                    .transition(.opacity)
            }
        }
        .frame(
            width: configuration.selectionPillWidth,
            height: isExpanded
                ? expandedItemHeight
                : itemHeight
        )
        .eazyGlassSurface(in: .capsule, tint: configuration.selectionTint)

    }
}

// MARK: - Wheel Item

private extension EazyControlRail {

    @ViewBuilder
    func wheelItem(
        _ item: Item,
        index: Int
    ) -> some View {

        let distance = distance(for: index)
        let isSelected = selection == item.id
        let isExpanded = state.expandedItemID == item.id
        let enabled = isEnabled(item)

        icon(item)
            .foregroundStyle(
                isSelected ? Color.primary : Color.secondary
            )
            .frame(width: itemWidth, height: itemHeight)
            .opacity(isExpanded ? 0 : opacity(for: distance) * (enabled ? 1 : 0.35))
            .scaleEffect(scale(for: distance))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: title(item)))
            .accessibilityIdentifier(accessibilityIdentifier(item))
            .accessibilityValue(Text(verbatim: accessibilityValue(item)))
            .accessibilityAddTraits(
                isSelected ? [.isButton, .isSelected] : .isButton
            )
            .disabled(!enabled)
            .accessibilityAction {
                activate(index)
            }
    }
}

// MARK: - Position

private extension EazyControlRail {

    func yPosition(for index: Int) -> CGFloat {
        let stepsFromCenter = CGFloat(index) - continuousIndex
        let anglePerItem = CGFloat.pi / CGFloat(configuration.visibleItemCount + 1)
        let radius = itemSpacing / sin(anglePerItem)
        let angle = min(max(stepsFromCenter * anglePerItem, -.pi / 2), .pi / 2)
        let base = centerY + radius * sin(angle)

        guard let expandedIndex else { return base }

        if index < expandedIndex {
            return base - reflowShift
        } else if index > expandedIndex {
            return base + reflowShift
        } else {
            return base
        }
    }

    func distance(for index: Int) -> CGFloat {
        abs(CGFloat(index) - continuousIndex)
    }

    func tappedIndex(at location: CGPoint) -> Int? {
        guard !items.isEmpty else { return nil }
        guard let nearest = items.indices.filter({ opacity(for: distance(for: $0)) > 0 }).min(by: {
            abs(yPosition(for: $0) - location.y) < abs(yPosition(for: $1) - location.y)
        }), abs(yPosition(for: nearest) - location.y) <= itemSpacing / 2 else { return nil }
        return nearest
    }
}

// MARK: - Visual Effects

private extension EazyControlRail {

    func opacity(for distance: CGFloat) -> CGFloat {
        let d = max(0, min(distance, 2.5))

        switch d {
        case 0..<0.45:
            return 1.0
        case 0.45..<1.25:
            let t = (d - 0.45) / 0.80
            return 1.0 + (0.72 - 1.0) * t
        case 1.25..<2.0:
            let t = (d - 1.25) / 0.75
            return 0.72 + (0.38 - 0.72) * t
        default:
            let t = (d - 2.0) / 0.5
            return 0.38 * (1 - t)
        }
    }

    func scale(for distance: CGFloat) -> CGFloat {
        let d = max(0, min(distance, 2.0))

        switch d {
        case 0..<0.45:
            return 1.0
        case 0.45..<1.25:
            let t = (d - 0.45) / 0.80
            return 1.0 + (0.9 - 1.0) * t
        default:
            let t = (d - 1.25) / 0.75
            return 0.9 + (0.82 - 0.9) * t
        }
    }
}

// MARK: - Gesture

private extension EazyControlRail {

    static var tapThreshold: CGFloat { 4 }

    var wheelGesture: some Gesture {

        DragGesture(minimumDistance: 0, coordinateSpace: .local)

            .onChanged { value in

                guard !items.isEmpty else { return }

                let translation = value.translation
                let moved =
                    abs(translation.height) >= Self.tapThreshold ||
                    abs(translation.width) >= Self.tapThreshold

                if !state.isDragging && moved {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) {
                        state.beginDrag()
                        expansion.progress = 0
                        publishRailGeometry()
                    }
                }

                guard state.isDragging else { return }

                let proposed = state.dragStartOffset + translation.height
                state.offset = clampedOffset(proposed)
                publishRailGeometry()

            }

            .onEnded { value in

                guard !items.isEmpty else {
                    state.isDragging = false
                    return
                }

                let wasDragging = state.isDragging
                state.isDragging = false

                if !wasDragging {
                    if let index = tappedIndex(at: value.location) {
                        activate(index)
                    }
                    return
                }

                let targetIndex = index(for: state.offset)

                withAnimation(reduceMotion ? nil : .snappy(duration: 0.32, extraBounce: 0.06)) {
                    state.offset = -CGFloat(targetIndex) * itemSpacing
                    publishRailGeometry()
                }

                commitSelection(at: targetIndex, activate: false)
            }
    }
}

// MARK: - Selection

private extension EazyControlRail {

    func publishRailGeometry() {
        expansion = calculatedRailGeometry()
    }

    func calculatedRailGeometry() -> EazyControlRailExpansion {
        guard !items.isEmpty else { return .init() }
        var geometry = EazyControlRailExpansion(progress: expandedIndex == nil ? 0 : 1)

        let halfViewport = railHeight / 2
        let edgeInset = configuration.expandedSpacing / 2
        let shoulder = configuration.shoulderHeight
        var topExtent: CGFloat = 0
        var bottomExtent: CGFloat = 0

        for index in items.indices where opacity(for: distance(for: index)) > 0 {
            let relativeY = yPosition(for: index) - centerY
            let halfIcon = itemHeight * scale(for: distance(for: index)) / 2
            let iconTop = relativeY - halfIcon - edgeInset
            let iconBottom = relativeY + halfIcon + edgeInset
            guard iconBottom > -halfViewport, iconTop < halfViewport else { continue }
            // Include the curved part of the cutout in the icon's clearance.
            // Outer items then fade through the shoulder instead of vanishing
            // before the wheel reaches its edge.
            topExtent = max(topExtent, min(halfViewport, -iconTop + shoulder))
            bottomExtent = max(bottomExtent, min(halfViewport, iconBottom + shoulder))
        }

        geometry.layoutHalfExtent = max(halfViewport,
            expandedItemHeight / 2 + shoulder + configuration.expandedSpacing)
        let pillHalfHeight = (itemHeight
            + (expandedItemHeight - itemHeight) * geometry.progress) / 2
        let pillClearance = pillHalfHeight + shoulder + configuration.expandedSpacing

        geometry.topExtent = max(topExtent, pillClearance)
        geometry.bottomExtent = max(bottomExtent, pillClearance)
        geometry.shoulderHeight = shoulder
        return geometry
    }

    func moveAccessibilityFocus(by offset: Int) {
        guard !items.isEmpty else { return }
        let target = min(max(currentIndex + offset, 0), lastIndex)
        guard target != currentIndex else { return }
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.30)) {
            state.offset = -CGFloat(target) * itemSpacing
            publishRailGeometry()
        }
    }

    func clampedOffset(_ value: CGFloat) -> CGFloat {
        min(max(value, minOffset), maxOffset)
    }

    func clampCurrentOffset(animated: Bool) {
        let clamped = clampedOffset(state.offset)
        guard abs(clamped - state.offset) > 0.5 else { return }

        if animated {
            withAnimation(reduceMotion ? nil : .snappy(duration: 0.30)) {
                state.offset = clamped
                publishRailGeometry()
            }
        } else {
            state.offset = clamped
            publishRailGeometry()
        }
    }

    func index(for offset: CGFloat) -> Int {
        guard itemSpacing > 0, !items.isEmpty else { return 0 }
        let rounded = Int((-offset / itemSpacing).rounded())
        return min(max(rounded, 0), lastIndex)
    }

    func activate(_ index: Int) {
        guard items.indices.contains(index) else { return }
        guard isEnabled(items[index]) else { return }

        withAnimation(reduceMotion ? nil : .snappy(duration: 0.30, extraBounce: 0.05)) {
            state.offset = -CGFloat(index) * itemSpacing
            publishRailGeometry()
        }

        commitSelection(at: index, activate: true)
    }

    func commitSelection(at index: Int, activate: Bool) {
        guard items.indices.contains(index) else { return }
        let item = items[index]
        guard isEnabled(item) else { return }

        if isSelectable(item), selection != item.id {
            selection = item.id
            EazyHaptics.selection()
        }

        if activate { onActivate(item) }
        activateTitle(for: item.id)
    }

    func synchronizeFromSelection(animated: Bool) {
        guard !items.isEmpty else {
            state.offset = 0
            return
        }

        guard
            let selection,
            let index = items.firstIndex(where: { $0.id == selection })
        else {
            clampCurrentOffset(animated: animated)
            return
        }

        let targetOffset = -CGFloat(index) * itemSpacing
        guard abs(targetOffset - state.offset) > 0.5 else { return }

        if animated {
            withAnimation(reduceMotion ? nil : .snappy(duration: 0.30)) {
                state.offset = targetOffset
                publishRailGeometry()
            }
        } else {
            state.offset = targetOffset
            publishRailGeometry()
        }
    }
}

// MARK: - Temporary Title

private extension EazyControlRail {

    func activateTitle(for id: Item.ID) {
        state.cancelTitleTask()

        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
            state.expandedItemID = id
            expansion.progress = 1
            publishRailGeometry()
        }

        state.titleTask = Task { @MainActor in

            try? await Task.sleep(
                for: configuration.selectionDisplayDuration
            )
            guard !Task.isCancelled else { return }

            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.22)) {
                if state.expandedItemID == id {
                    state.expandedItemID = nil
                    expansion.progress = 0
                    publishRailGeometry()
                }
            }
        }
    }
}
