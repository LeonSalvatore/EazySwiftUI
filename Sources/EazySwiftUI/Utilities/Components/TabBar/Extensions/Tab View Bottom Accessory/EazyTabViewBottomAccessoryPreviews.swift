//
//  EazyTabViewBottomAccessoryPreviews.swift
//  EazySwiftUI
//

import SwiftUI

// MARK: - Sample content

/// A now-playing bar with two arrangements, which is what the placement is for.
///
/// Expanded there is room for the artist and a three-button transport; inline
/// the accessory is 70 points narrower and shares its row with the collapsed
/// bar, so the subtitle goes and the transport comes down to one button. This
/// is the adaptation the system's own accessory makes, and the reason the
/// placement is published rather than kept private to the layout.
private struct SampleAccessoryBar: View {
    @Environment(\.eazyTabViewBottomAccessoryPlacement) private var placement

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "music.note")
                .font(.body)
                .foregroundStyle(.secondary)

            SampleAccessoryTitle(isCompact: placement == .inline)

            Spacer(minLength: 0)

            SampleAccessoryTransport(isCompact: placement == .inline)
        }
        .padding(.horizontal, 16)
    }
}

private struct SampleAccessoryTitle: View {
    let isCompact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Sonnet for Glass")
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)

            if !isCompact {
                Text("The Refractions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

private struct SampleAccessoryTransport: View {
    let isCompact: Bool

    var body: some View {
        HStack(spacing: 20) {
            if !isCompact {
                Button("Previous", systemImage: "backward.fill") {}
            }

            Button("Play", systemImage: "play.fill") {}

            if !isCompact {
                Button("Next", systemImage: "forward.fill") {}
            }
        }
        .labelStyle(.iconOnly)
        .font(.body)
        .foregroundStyle(.primary)
        .buttonStyle(.plain)
    }
}

private struct SampleTabContent: View {
    let tab: EazyTab

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(1..<40) { index in
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.quaternary)
                        .frame(height: 72)
                        .overlay {
                            Text("\(String(localized: tab.title)) item \(index)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .padding()
        }
    }
}

nonisolated(unsafe) private let sampleTabs = [
    EazyTab(systemImage: "house.fill", title: "Home"),
    EazyTab(systemImage: "square.grid.2x2.fill", title: "Browse"),
    EazyTab(systemImage: "books.vertical.fill", title: "Library")
]

// MARK: - Against the system's own

// The system's accessory is iPhone and iPad only — `tabViewBottomAccessory`
// and `.onScrollDown` are both marked unavailable everywhere else — so the
// reference preview is too. The package's own is not: it is drawn on the
// package's glass, and runs from iOS 18 and macOS 15.
#if os(iOS)

/// The reference the geometry and the collapse were measured off.
@available(iOS 26.0, *)
private struct NativeBottomAccessoryPreview: View {
    @State private var selection = "home"

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house.fill", value: "home") {
                SampleTabContent(tab: sampleTabs[0])
            }
            Tab("Browse", systemImage: "square.grid.2x2.fill", value: "browse") {
                SampleTabContent(tab: sampleTabs[1])
            }
            Tab("Library", systemImage: "books.vertical.fill", value: "library") {
                SampleTabContent(tab: sampleTabs[2])
            }
        }
        .tabViewBottomAccessory { SampleAccessoryBar() }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview("Native — scroll down to collapse") {
    if #available(iOS 26.0, *) {
        NativeBottomAccessoryPreview()
    } else {
        ContentUnavailableView("Requires iOS 26", systemImage: "exclamationmark.triangle")
    }
}

#endif

// MARK: - The package's own

/// The whole thing, wired the way it is meant to be wired.
///
/// Scroll down and the bar collapses into its circle while the accessory goes
/// inline beside it; scroll back up, or tap the circle, and both return.
/// Nothing here holds that state.
private struct EazyBottomAccessoryPreview: View {
    @State private var selection = "house.fill"

    var body: some View {
        EazyTabView(tabs: sampleTabs, selection: $selection) { tab in
            SampleTabContent(tab: tab)
        }
        .eazyTabBarMinimizeBehavior(.onScrollDown)
        .eazyTabViewBottomAccessory { SampleAccessoryBar() }
    }
}

#Preview("Eazy — scroll down to collapse") {
    EazyBottomAccessoryPreview()
}

#Preview("Eazy — dark") {
    EazyBottomAccessoryPreview()
        .preferredColorScheme(.dark)
}

#Preview("Eazy — accessibility text") {
    EazyBottomAccessoryPreview()
        .environment(\.dynamicTypeSize, .accessibility2)
}

/// The two placements held still, over a flat backdrop, for comparing them
/// against the measured frames without having to catch a scroll at the right
/// moment.
private struct EazyPlacementPreview: View {
    let placement: EazyTabViewBottomAccessoryPlacement

    @State private var selection = "house.fill"

    var body: some View {
        EazyTabView(tabs: sampleTabs, selection: $selection) { _ in
            LinearGradient(
                colors: [.indigo, .purple, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
        .eazyTabViewBottomAccessory(placement: placement) {
            SampleAccessoryBar()
        }
    }
}

#Preview("Placement — expanded") {
    EazyPlacementPreview(placement: .expanded)
}

#Preview("Placement — inline") {
    EazyPlacementPreview(placement: .inline)
}

/// A bar with actions, so the toggle is in play alongside the accessory — and
/// so the toggle can be seen leaving as the bar collapses.
private struct EazyAccessoryWithActionsPreview: View {
    @State private var selection = "house.fill"

    var body: some View {
        EazyTabView(
            tabs: sampleTabs,
            selection: $selection,
            actions: [
                EazyTabBarAction(systemImage: "square.and.pencil", title: "Compose") {},
                EazyTabBarAction(systemImage: "square.and.arrow.up", title: "Share") {},
                EazyTabBarAction(systemImage: "bookmark", title: "Save") {},
                EazyTabBarAction(systemImage: "trash", title: "Delete", isDestructive: true) {}
            ]
        ) { tab in
            SampleTabContent(tab: tab)
        }
        .eazyTabBarMinimizeBehavior(.onScrollDown)
        .eazyTabViewBottomAccessory { SampleAccessoryBar() }
    }
}

#Preview("Eazy — with actions") {
    EazyAccessoryWithActionsPreview()
}
