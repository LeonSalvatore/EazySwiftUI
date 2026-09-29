import SwiftUI

#Preview("Notched rail card") {
    EazyNotchedRailCardPreview()
}

#Preview("Top trailing") {
    EazyNotchedRailCardPreview(placement: .topTrailing)
}

#Preview("Bottom leading") {
    EazyNotchedRailCardPreview(placement: .bottomLeading)
}

#Preview("Bottom trailing") {
    EazyNotchedRailCardPreview(placement: .bottomTrailing)
}

struct EazyNotchedRailCardPreview: View {
    private struct Section: Identifiable {
        let id: String
        let symbol: String
    }

    let placement: EazyControlRailPlacement
    @State private var selection: String? = "Songs"

    init(placement: EazyControlRailPlacement = .topLeading) {
        self.placement = placement
    }

    private let sections = [
        Section(id: "All", symbol: "square.grid.2x2"),
        Section(id: "Songs", symbol: "music.note"),
        Section(id: "Albums", symbol: "square.stack"),
        Section(id: "Artists", symbol: "music.mic"),
        Section(id: "Playlists", symbol: "music.note.list"),
        Section(id: "Downloads", symbol: "arrow.down.circle")
    ]

    private let gradient = LinearGradient(
        colors: [.purple.opacity(0.6), .pink.opacity(0.5), .orange.opacity(0.45)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        EazyNotchedRailCard(
            items: sections,
            selection: $selection,
            fill: gradient.secondary,
            selectionTint: .orange.opacity(0.55),
            placement: placement
        ) { section in
            section.id
        } icon: { section in
            Image(systemName: section.symbol)
                .font(.system(size: 15))
        } header: {
            Text(selection ?? "Library")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
        } content: {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(1...30, id: \.self) { row in
                        Text("Row \(row)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                            .eazyNotchedRailAdaptiveInset()
                    }
                }
            }
        } bottomBar: {
            Label("Search", systemImage: "magnifyingglass")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background {
                    Capsule().strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                }
        }
    }
}
