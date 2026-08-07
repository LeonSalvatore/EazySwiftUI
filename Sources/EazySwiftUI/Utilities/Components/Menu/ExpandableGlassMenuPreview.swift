import SwiftUI

#Preview("Expandable glass menu") {
    ExpandableGlassMenuPreview()
}

private struct ExpandableGlassMenuPreview: View {
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.indigo, .purple, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 28) {
                ExpandableGlassMenu(alignment: .topLeading, progress: progress) {
                    VStack(alignment: .leading, spacing: 8) {
                        Button("Send", systemImage: "paperplane.fill", action: closeMenu)
                        Button(
                            "Swap",
                            systemImage: "arrow.trianglehead.2.counterclockwise",
                            action: closeMenu
                        )
                        Button("Receive", systemImage: "arrow.down", action: closeMenu)
                    }
                    .buttonStyle(.borderless)
                    .padding(16)
                } label: {
                    Button(
                        progress < 0.5 ? "Open menu" : "Close menu",
                        systemImage: progress < 0.5 ? "plus" : "xmark",
                        action: toggleMenu
                    )
                    .labelStyle(.iconOnly)
                    .font(.title3.weight(.semibold))
                }

                Slider(value: $progress, in: 0...1) {
                    Text("Expansion progress")
                }
            }
            .padding(24)
        }
    }

    private func toggleMenu() {
        withAnimation(.bouncy(duration: 0.75, extraBounce: 0.02)) {
            progress = progress < 0.5 ? 1 : 0
        }
    }

    private func closeMenu() {
        withAnimation(.bouncy(duration: 0.75, extraBounce: 0.02)) {
            progress = 0
        }
    }
}
