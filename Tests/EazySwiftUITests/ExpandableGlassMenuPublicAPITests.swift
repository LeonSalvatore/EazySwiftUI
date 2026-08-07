import SwiftUI
import Testing
import EazySwiftUI

@Suite("Expandable glass menu public API")
struct ExpandableGlassMenuPublicAPITests {
    @Test
    @MainActor
    func menuCanBeConstructedOutsideTheModule() {
        _ = ExpandableGlassMenu(
            alignment: .topLeading,
            progress: 0,
            labelSize: CGSize(width: 44, height: 44),
            cornerRadius: 22
        ) {
            Text("Menu")
        } label: {
            Image(systemName: "plus")
        }
    }
}
