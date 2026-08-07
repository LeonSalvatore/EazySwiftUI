import SwiftUI
import Testing
import EazySwiftUI

@Suite("Glass surface public API")
struct EazyGlassSurfacePublicAPITests {
    @Test
    @MainActor
    func glassSurfaceCanBeConstructedOutsideTheModule() {
        _ = EazyGlassContainer(spacing: 12) {
            Text("Glass")
                .eazyGlassSurface(in: .capsule)
        }
    }
}
