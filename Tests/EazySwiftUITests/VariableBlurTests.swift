#if canImport(UIKit)
import Testing
@testable import EazySwiftUI

@Suite("Variable blur masks")
@MainActor
struct VariableBlurTests {
    @Test
    func topAndBottomEdgesProduceMirroredRamps() {
        let top = BlurGradientMask.alphaValues(
            length: 5,
            edge: .top,
            plateau: 0,
            eased: false
        )
        let bottom = BlurGradientMask.alphaValues(
            length: 5,
            edge: .bottom,
            plateau: 0,
            eased: false
        )

        #expect(top.first == 255)
        #expect(top.last == 0)
        #expect(bottom == Array(top.reversed()))
    }

    @Test
    func plateauIsClampedToAUnitValue() {
        let fullPlateau = BlurGradientMask.alphaValues(
            length: 5,
            edge: .top,
            plateau: 2,
            eased: false
        )
        let nonFinitePlateau = BlurGradientMask.alphaValues(
            length: 5,
            edge: .top,
            plateau: .infinity,
            eased: false
        )

        #expect(fullPlateau.allSatisfy { $0 == 255 })
        #expect(nonFinitePlateau.first == 255)
        #expect(nonFinitePlateau.last == 0)
    }

    @Test
    func invalidLengthDoesNotCreateAMask() {
        #expect(
            BlurGradientMask.alphaValues(
                length: 0,
                edge: .top,
                plateau: 0,
                eased: true
            ).isEmpty
        )
        #expect(
            BlurGradientMask.ramp(
                length: 0,
                edge: .top,
                plateau: 0,
                eased: true
            ) == nil
        )
    }

    @Test
    func generatedMaskHasOnePixelWidthAndRequestedHeight() throws {
        let mask = try #require(
            BlurGradientMask.ramp(
                length: 12,
                edge: .bottom,
                plateau: 0.25,
                eased: true
            )
        )

        #expect(mask.width == 1)
        #expect(mask.height == 12)
    }
}
#endif
