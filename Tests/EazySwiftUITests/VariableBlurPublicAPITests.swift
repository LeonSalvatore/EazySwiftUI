#if canImport(UIKit)
import SwiftUI
import Testing
import UIKit
import EazySwiftUI

@Suite("Variable blur public API")
@MainActor
struct VariableBlurPublicAPITests {
    @Test
    func variableBlurCanBeConstructedOutsideTheModule() {
        let dimming = VariableBlurDimming(
            color: .indigo,
            lightAlpha: 0.4,
            darkAlpha: 0.2,
            overshoot: 1.5
        )
        let blur = VariableBlur(
            edge: .bottom,
            maxRadius: 8,
            plateau: 0.2,
            dimming: dimming,
            fallbackStyle: .systemThinMaterial
        )

        _ = VariableBlur()
        _ = VariableBlur(dimming: nil)
        _ = VariableBlurDimming.bar

        #expect(blur.edge == .bottom)
        #expect(blur.maxRadius == 8)
        #expect(blur.plateau == 0.2)
        #expect(blur.dimming == dimming)
        #expect(VariableBlurEdge.top.rawValue == "top")
    }
}
#endif
