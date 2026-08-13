import SwiftUI
import Testing
import EazySwiftUI

@Suite("Border beam public API")
struct BorderBeamPublicAPITests {
    @Test
    @MainActor
    func borderBeamCanBeConstructedOutsideTheModule() {
        let modifier = BorderBeamEffectModifier(
            border: .accentColor,
            showsBaseBorder: true,
            beam: [.pink, .purple],
            beamBlur: 14,
            cornerRadius: 12
        )

        _ = Text("Register")
            .modifier(modifier)

        _ = Text("Register")
            .borderBeamEffect(
                border: .accentColor,
                beam: [.pink, .purple],
                beamBlur: 14,
                cornerRadius: 12,
                duration: 2
            )
    }
}
