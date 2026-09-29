import SwiftUI
import Testing
import EazySwiftUI

@Suite("Notched rail public API")
struct EazyNotchedRailPublicAPITests {
    private struct Item: Identifiable {
        let id: String
    }

    @Test
    @MainActor
    func cardCanBeConstructedOutsideTheModule() {
        let items = [Item(id: "a"), Item(id: "b")]

        for placement in EazyControlRailPlacement.allCases {
            _ = EazyNotchedRailCard(
                items: items,
                selection: .constant("a"),
                fill: Color.purple.secondary,
                background: AnyShapeStyle(.white),
                selectionTint: .orange,
                placement: placement,
                bottomBoundary: 700,
                isBottomBarFocused: true,
                configuration: .init(railWidth: 40, bottomCornerRadius: 32),
                isEnabled: { _ in true },
                isSelectable: { $0.id != "b" },
                accessibilityIdentifier: { $0.id },
                accessibilityValue: { $0.id },
                onActivate: { _ in }
            ) { $0.id } icon: { Text($0.id) } header: {
                Text("Header")
            } content: {
                Text("Row").eazyNotchedRailAdaptiveInset(20)
            } bottomBar: {
                Text("Bar")
            }
        }
    }

    @Test
    @MainActor
    func railAndShapeCanBeConstructedOutsideTheModule() {
        _ = EazyControlRail(
            items: [Item(id: "a")],
            selection: .constant(nil),
            expansion: .constant(EazyControlRailExpansion()),
            configuration: EazyControlRailConfiguration(
                itemWidth: 44,
                itemHeight: 44,
                itemSpacing: 40,
                visibleItemCount: 3,
                selectionDisplayDuration: .seconds(1),
                selectionTint: .blue,
                selectionPillWidth: 30,
                expandedHeightMultiple: 2,
                expandedSpacing: 6,
                notchDepth: 36
            ),
            placement: .bottomTrailing
        ) { $0.id } icon: { Text($0.id) }

        _ = EazyNotchedCardShape(
            cornerRadius: 44,
            notchDepth: 36,
            notchCenterYFraction: 0.3,
            notchHeight: 200,
            shoulderHeight: 40,
            placement: .topTrailing
        )
        _ = EnvironmentValues().eazyNotchedRailContentRegion
    }
}
