//
//  EazyGlassSegmentControl.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 10.08.2026.
//

import SwiftUI

// MARK: - EazyGlassSegmentControl

/// A scrollable segment control with a Liquid Glass selection capsule.
///
/// `EazyGlassSegmentControl` renders a horizontally scrollable strip of tab
/// labels. The active tab is highlighted by a glass capsule that morphs its
/// width to match the current label. Tapping a tab or programmatically changing
/// `selection` scrolls the strip to keep the active tab centered.
///
/// ```swift
/// @State private var selection = 0
/// @State private var tabs: [EazyGlassSegmentControl.Tab] = [
///     .init(title: "Home", icon: "house"),
///     .init(title: "Library", icon: "books.vertical"),
///     .init(title: "Search", icon: "magnifyingglass"),
/// ]
///
/// EazyGlassSegmentControl(selection: $selection, tabs: $tabs)
/// ```
///
/// Customise the appearance via ``EazyGlassSegmentControl/Configuration``:
///
/// ```swift
/// EazyGlassSegmentControl(
///     configuration: .init(tint: .purple, height: 44),
///     selection: $selection,
///     tabs: $tabs
/// )
/// ```
public struct EazyGlassSegmentControl: View {

    // MARK: - Configuration

    /// Appearance and behaviour settings for ``EazyGlassSegmentControl``.
    public struct Configuration {
        /// The color applied to the active tab's label.
        public var tint: Color
        /// The font used for every tab label.
        public var font: Font
        /// The height of the control strip.
        public var height: CGFloat
        /// The horizontal padding applied on each side of a tab's label content.
        public var labelPadding: CGFloat
        /// Whether SF Symbol icons (provided via ``Tab/icon``) are shown.
        public var showIcons: Bool
        /// Whether haptic feedback fires when the selection changes.
        public var hapticsEnabled: Bool

        public init(
            tint: Color = .accentColor,
            font: Font = .callout,
            height: CGFloat = 50,
            labelPadding: CGFloat = 16,
            showIcons: Bool = true,
            hapticsEnabled: Bool = true
        ) {
            self.tint = tint
            self.font = font
            self.height = height
            self.labelPadding = labelPadding
            self.showIcons = showIcons
            self.hapticsEnabled = hapticsEnabled
        }
    }

    // MARK: - Tab

    /// A single selectable item in ``EazyGlassSegmentControl``.
    public struct Tab: Identifiable {
        /// A stable unique identifier.
        public let id: UUID
        /// The label text displayed in the control strip.
        public var title: String
        /// An optional SF Symbol name shown next to the title when
        /// ``Configuration/showIcons`` is `true`.
        public var icon: String?
        /// An optional badge string shown after the title (e.g. an unread count).
        public var badge: String?

        public init(title: String, icon: String? = nil, badge: String? = nil) {
            self.id = UUID()
            self.title = title
            self.icon = icon
            self.badge = badge
        }
    }

    // MARK: - Properties

    private let configuration: Configuration
    @Binding private var selection: Int
    @Binding private var tabs: [Tab]

    // Tab sizes are kept local to each instance so two controls sharing the same
    // `tabs` binding (e.g. one with icons, one without) don't overwrite each other.
    @State private var tabSizes: [UUID: CGSize] = [:]
    @State private var activeIndex: Int? = nil
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var isInitiallyScrolled: Bool = false

    // MARK: - Init

    /// Creates an ``EazyGlassSegmentControl``.
    ///
    /// - Parameters:
    ///   - configuration: Appearance and behaviour settings.
    ///   - selection: The index of the currently selected tab.
    ///   - tabs: The tabs to display in the strip.
    public init(
        configuration: Configuration = .init(),
        selection: Binding<Int>,
        tabs: Binding<[Tab]>
    ) {
        self.configuration = configuration
        self._selection = selection
        self._tabs = tabs
    }

    // MARK: - Helpers

    private var snapPoints: [CGFloat] {
        var points = [CGFloat]()
        var x: CGFloat = 0
        for tab in tabs {
            let width = tabSizes[tab.id]?.width ?? 0
            points.append(x + width / 2)
            x += width
        }
        return points
    }

    private func closeSnapPoint(_ offset: CGFloat) -> CGFloat {
        snapPoints.min { abs($0 - offset) < abs($1 - offset) } ?? offset
    }

    private func closeSnapPointIndex(_ offset: CGFloat) -> Int? {
        snapPoints.enumerated()
            .min { abs($0.element - offset) < abs($1.element - offset) }?
            .offset
    }

    private var activeSize: CGSize {
        let index = activeIndex ?? 0
        guard index < tabs.count else { return .zero }
        return tabSizes[tabs[index].id] ?? .zero
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { proxy in
            let containerWidth = proxy.size.width

            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(tabs) { tab in
                        Button {
                            if configuration.hapticsEnabled {
                                EazyHaptics.selection()
                            }
                            if let index = tabs.firstIndex(where: { $0.id == tab.id }),
                               selection != index {
                                selection = index
                            }
                        } label: {
                            EazyGlassSegmentTabLabel(
                                tab: tab,
                                configuration: configuration,
                                foregroundStyle: AnyShapeStyle(.secondary)
                            )
                            .frame(height: configuration.height)
                        }
                        .buttonStyle(.plain)
                        .contentShape(.rect)
                        .onGeometryChange(for: CGSize.self) { $0.size } action: { newValue in
                            tabSizes[tab.id] = newValue
                            guard !isInitiallyScrolled,
                                  newValue.width > 0,
                                  let index = tabs.firstIndex(where: { $0.id == tab.id }),
                                  index == (activeIndex ?? 0) else { return }
                            isInitiallyScrolled = true
                            let target = snapPoints[index]
                            // Defer until the next main-actor tick so the scroll
                            // view's safe-area inset is committed before scrolling.
                            Task { @MainActor in
                                scrollPosition.scrollTo(x: target)
                            }
                        }
                    }
                }
                // Tinted labels, visible only through the glass capsule via the mask.
                .overlay {
                    HStack(spacing: 0) {
                        ForEach(tabs) { tab in
                            EazyGlassSegmentTabLabel(
                                tab: tab,
                                configuration: configuration,
                                foregroundStyle: AnyShapeStyle(configuration.tint)
                            )
                            .frame(height: configuration.height)
                        }
                    }
                    .mask {
                        Capsule()
                            .frame(width: activeSize.width, height: activeSize.height)
                            .visualEffect { view, proxy in
                                let midX = proxy.frame(in: .scrollView).midX
                                return view.offset(x: -midX)
                            }
                    }
                    .allowsHitTesting(false)
                }
                // Glass selection capsule, continuously positioned via visualEffect
                // so it tracks the scroll without requiring extra state updates.
                .background(alignment: .leading) {
                    EazyGlassSegmentCapsule(size: activeSize)
                        .visualEffect { view, proxy in
                            let midX = proxy.frame(in: .scrollView).midX
                            return view.offset(x: -midX)
                        }
                }
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .safeAreaPadding(.horizontal, containerWidth / 2)
            .scrollTargetBehavior(EazyGlassSegmentScrollTarget(snapPoints: snapPoints))
            .scrollPosition($scrollPosition, anchor: .center)
            .onScrollGeometryChange(for: CGFloat.self) {
                $0.contentOffset.x + $0.contentInsets.leading
            } action: { _, newValue in
                // Live tracking: keep the capsule morphing to the centered tab's
                // width while scrolling. Selection is committed on settle (below).
                if let index = closeSnapPointIndex(newValue), activeIndex != nil {
                    activeIndex = index
                }
            }
            .onScrollPhaseChange { _, phase in
                // Commit selection once the scroll comes to rest so tapping or
                // dragging reports the final destination exactly once.
                if phase == .idle, let index = activeIndex, selection != index {
                    selection = index
                }
            }
            .animation(
                .interactiveSpring(response: 0.35, dampingFraction: 0.3, blendDuration: 0.4),
                value: activeIndex
            )
        }
        .frame(height: configuration.height)
        .task {
            guard activeIndex == nil else { return }
            let cappedIndex = max(min(selection, tabs.count - 1), 0)
            selection = cappedIndex
            activeIndex = cappedIndex
            // Initial centering is handled by onGeometryChange once the active
            // tab's width is measured; scrolling here would fire with zero width.
        }
        .onChange(of: selection) { _, newValue in
            guard activeIndex != newValue else { return }
            let cappedIndex = max(min(newValue, tabs.count - 1), 0)
            withAnimation(.snappy) {
                scrollPosition.scrollTo(x: snapPoints[cappedIndex])
            }
        }
    }
}

// MARK: - Private: Tab label

private struct EazyGlassSegmentTabLabel: View {
    let tab: EazyGlassSegmentControl.Tab
    let configuration: EazyGlassSegmentControl.Configuration
    let foregroundStyle: AnyShapeStyle

    var body: some View {
        HStack(spacing: 5) {
            if configuration.showIcons, let icon = tab.icon {
                Image(systemName: icon)
                    .imageScale(.small)
            }
            Text(tab.title)
                .font(configuration.font)
            if let badge = tab.badge {
                Text(badge)
                    .font(.caption2.bold())
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(.secondary.opacity(0.25), in: .capsule)
            }
        }
        .foregroundStyle(foregroundStyle)
        .padding(.horizontal, configuration.labelPadding)
    }
}

// MARK: - Private: Glass capsule

private struct EazyGlassSegmentCapsule: View {
    let size: CGSize

    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                Capsule()
                    .fill(.clear)
                    .frame(width: size.width, height: size.height)
                    .glassEffect(.regular, in: .capsule)
            } else {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(width: size.width, height: size.height)
            }
        }
    }
}

// MARK: - Private: Scroll snap behavior

private struct EazyGlassSegmentScrollTarget: ScrollTargetBehavior {
    let snapPoints: [CGFloat]

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let offset = target.rect.origin.x
        target.rect.origin.x = snapPoints.min { abs($0 - offset) < abs($1 - offset) } ?? offset
    }

    @available(iOS 18.4, macOS 15.4, *)
    func properties(context: PropertiesContext) -> Properties {
        var properties = Properties()
        properties.limitsScrolls = true
        return properties
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selection = 0
    @Previewable @State var tabs: [EazyGlassSegmentControl.Tab] = [
        .init(title: "Home", icon: "house"),
        .init(title: "Library", icon: "books.vertical"),
        .init(title: "Search", icon: "magnifyingglass"),
        .init(title: "Settings", icon: "gear"),
        .init(title: "Profile", icon: "person"),
        .init(title: "Favorites", icon: "heart"),
    ]

    VStack(spacing: 20) {
        EazyGlassSegmentControl(selection: $selection, tabs: $tabs)

        EazyGlassSegmentControl(
            configuration: .init(tint: .pink, showIcons: false),
            selection: $selection,
            tabs: $tabs
        )

        Spacer()
        Text("Selected: \(tabs[selection].title)")
            .font(.headline)
    }
    .padding()
}
