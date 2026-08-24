import SwiftUI

#Preview("Slide-out menu") {
    EazySlideOutMenuPreview()
}

 struct EazySlideOutMenuPreview: View {
    @State private var isExpanded = false

    private let destinations = [
        ("Home", "house"),
        ("Library", "books.vertical"),
        ("Downloads", "arrow.down.circle"),
        ("Settings", "gearshape")
    ]

    var body: some View {
        EazySlideOutMenu(
            isExpanded: $isExpanded,
            configuration: .init(
                menuBackground: Color.secondary.opacity(0.08)
            ),
            closeAccessibilityLabel: "Close navigation menu"
        ) { _ in
            VStack(alignment: .leading, spacing: 8) {
                Label("My Library", systemImage: "square.stack.3d.up.fill")
                    .font(.headline)
                    .padding(.bottom, 12)

                ForEach(destinations, id: \.0) { destination in
                    Button(
                        destination.0,
                        systemImage: destination.1,
                        action: selectDestination
                    )
                    .buttonStyle(.borderless)
                    .frame(minHeight: 44)
                }

                Spacer()
            }
            .padding(24)
        } content: { _ in
            NavigationStack {
                List {
                    Section("Recently played") {
                        Label("Morning Focus", systemImage: "play.circle")
                        Label("Saved for Later", systemImage: "bookmark")
                    }
                }
                .navigationTitle("Library")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(
                            isExpanded ? "Close menu" : "Open menu",
                            systemImage: isExpanded
                                ? "xmark"
                                : "line.3.horizontal",
                            action: toggleMenu
                        )
                        .labelStyle(.iconOnly)
                    }
                }
            }
        }
    }

    private func toggleMenu() {
        isExpanded.toggle()
    }

    private func selectDestination() {
        isExpanded = false
    }
}
