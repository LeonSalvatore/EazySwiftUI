import SwiftUI
import Testing
import EazySwiftUI

@Suite("Slide-out menu public API")
struct EazySlideOutMenuPublicAPITests {
    @Test
    @MainActor
    func menuCanBeConstructedOutsideTheModule() {
        let configurations = [
            EazySlideOutMenuConfiguration(),
            EazySlideOutMenuConfiguration(
                edge: .trailing,
                menuWidth: .fixed(320),
                minimumVisibleContentWidth: 60,
                openingEdgeWidth: 32,
                menuMinimumScale: 0.9,
                contentShape: .roundedRectangle(cornerRadius: 40),
                contentBackground: .white,
                menuBackground: .gray,
                scrimColor: .indigo,
                maximumScrimOpacity: 0.3,
                borderColor: .purple,
                borderWidth: 2,
                shadowColor: .black,
                shadowRadius: 8,
                shadowOffset: 12,
                settleAnimation: .smooth,
                hapticsEnabled: false
            )
        ]

        for configuration in configurations {
            _ = EazySlideOutMenu(
                isExpanded: .constant(false),
                isGestureEnabled: true,
                configuration: configuration,
                closeAccessibilityLabel: "Close navigation menu"
            ) { progress in
                Text(progress, format: .percent)
            } content: { progress in
                Text(progress, format: .percent)
            }
        }
    }
}
