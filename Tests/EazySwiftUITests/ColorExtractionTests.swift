import CoreGraphics
import Foundation
import SwiftUI
import Testing
@testable import EazySwiftUI

#if os(iOS) || os(macOS)

@Suite("Color extraction")
struct ColorExtractionTests {

    // MARK: - Banded colors

    @Test
    func bandedColorsFollowTheVerticalOrderOfTheImage() throws {
        let image = try makeImage(
            bands: [.red, .green, .blue],
            axis: .vertical
        )

        let colors = EazyColorExtractor(count: 3).colors(from: image)

        #expect(colors.count == 3)
        expectApproximatelyEqual(colors[0], .red)
        expectApproximatelyEqual(colors[1], .green)
        expectApproximatelyEqual(colors[2], .blue)
    }

    @Test
    func bandedColorsFollowTheHorizontalOrderOfTheImage() throws {
        let image = try makeImage(
            bands: [.red, .blue],
            axis: .horizontal
        )

        let colors = EazyColorExtractor(count: 2, axis: .horizontal).colors(from: image)

        #expect(colors.count == 2)
        expectApproximatelyEqual(colors[0], .red)
        expectApproximatelyEqual(colors[1], .blue)
    }

    @Test
    func requestedCountIsAlwaysHonoredAndNeverBelowOne() throws {
        let image = try makeImage(bands: [.red, .green], axis: .vertical)

        #expect(EazyColorExtractor(count: 5).colors(from: image).count == 5)
        #expect(EazyColorExtractor(count: 0).count == 1)
        #expect(EazyColorExtractor(count: 0).colors(from: image).count == 1)
    }

    // MARK: - Average color

    @Test
    func averageColorMixesTheWholeImage() throws {
        let image = try makeImage(bands: [.black, .white], axis: .vertical)

        let average = try #require(EazyColorExtractor.default.averageColor(from: image))

        let components = try #require(sRGBComponents(of: average))
        #expect(abs(components.red - 0.5) < 0.05)
        #expect(abs(components.green - 0.5) < 0.05)
        #expect(abs(components.blue - 0.5) < 0.05)
    }

    @Test
    func transparentPixelsAreIgnored() throws {
        let image = try makeImage(
            bands: [.red, .clearBand],
            axis: .vertical
        )

        let average = try #require(EazyColorExtractor.default.averageColor(from: image))

        expectApproximatelyEqual(average, .red, tolerance: 0.05)
    }

    // MARK: - Dominant colors

    @Test
    func dominantColorsAreOrderedByCoverage() throws {
        let image = try makeImage(
            bands: [.blue, .blue, .blue, .red],
            axis: .vertical
        )

        let palette = EazyColorExtractor(count: 2).dominantColors(from: image)

        #expect(palette.count == 2)
        expectApproximatelyEqual(palette[0], .blue)
        expectApproximatelyEqual(palette[1], .red)
    }

    @Test
    func dominantColorReturnsTheMostCoveredColor() throws {
        let image = try makeImage(
            bands: [.green, .green, .green, .red],
            axis: .vertical
        )

        let dominant = try #require(EazyColorExtractor(count: 3).dominantColor(from: image))

        expectApproximatelyEqual(dominant, .green)
    }

    // MARK: - Data entry point

    @Test
    func colorsCanBeExtractedFromEncodedImageData() async throws {
        let image = try makeImage(bands: [.red, .blue], axis: .vertical)
        let data = try #require(encodedPNG(from: image))

        let colors = await EazyColorExtractor(count: 2).colors(from: data)

        #expect(colors.count == 2)
        expectApproximatelyEqual(colors[0], .red, tolerance: 0.08)
        expectApproximatelyEqual(colors[1], .blue, tolerance: 0.08)
    }

    // MARK: - Gradient support

    @Test
    func gradientPointsFollowTheSamplingAxis() {
        #expect(EazyColorExtractor(axis: .vertical).startPoint == .top)
        #expect(EazyColorExtractor(axis: .vertical).endPoint == .bottom)
        #expect(EazyColorExtractor(axis: .horizontal).startPoint == .leading)
        #expect(EazyColorExtractor(axis: .horizontal).endPoint == .trailing)
    }

    @Test
    func gradientColorsAlwaysProvideTwoStops() {
        #expect(eazyGradientColors([]).count == 2)
        #expect(eazyGradientColors([.red]).count == 2)
        #expect(eazyGradientColors([.red, .green, .blue]).count == 3)
    }

    // MARK: - Legibility helpers

    @Test
    func readableForegroundFollowsLuminance() {
        #expect(Color.white.isDark == false)
        #expect(Color.black.isDark)
        #expect(Color.white.readableForeground == .black)
        #expect(Color.black.readableForeground == .white)
        #expect(Color.white.luminance > Color.black.luminance)
    }
}

// MARK: - Fixtures

private struct BandColor {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    static let red = BandColor(red: 1, green: 0, blue: 0, alpha: 1)
    static let green = BandColor(red: 0, green: 1, blue: 0, alpha: 1)
    static let blue = BandColor(red: 0, green: 0, blue: 1, alpha: 1)
    static let black = BandColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let white = BandColor(red: 1, green: 1, blue: 1, alpha: 1)
    static let clearBand = BandColor(red: 0, green: 0, blue: 0, alpha: 0)

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

/// Builds a flat, banded test image so extraction results can be asserted exactly.
private func makeImage(
    bands: [BandColor],
    axis: EazyColorExtractor.Axis,
    size: CGSize = CGSize(width: 120, height: 120)
) throws -> CGImage {
    let context = try #require(
        CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    )

    // The context origin is bottom left, so vertical bands are drawn in reverse
    // to keep the first band at the top of the resulting image.
    let extent = axis == .vertical ? size.height : size.width
    let bandExtent = extent / CGFloat(bands.count)

    for (index, band) in bands.enumerated() {
        context.setFillColor(
            red: band.red,
            green: band.green,
            blue: band.blue,
            alpha: band.alpha
        )

        let offset = CGFloat(index) * bandExtent
        let rect = axis == .vertical
            ? CGRect(x: 0, y: extent - offset - bandExtent, width: size.width, height: bandExtent)
            : CGRect(x: offset, y: 0, width: bandExtent, height: size.height)

        context.clear(rect)
        context.fill(rect)
    }

    return try #require(context.makeImage())
}

private func encodedPNG(from cgImage: CGImage) -> Data? {
    #if os(iOS)
    return UIImage(cgImage: cgImage).pngData()
    #elseif os(macOS)
    let representation = NSBitmapImageRep(cgImage: cgImage)
    return representation.representation(using: .png, properties: [:])
    #endif
}

// MARK: - Assertions

private func expectApproximatelyEqual(
    _ color: Color,
    _ expected: BandColor,
    tolerance: Double = 0.02,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    guard let components = sRGBComponents(of: color) else {
        Issue.record("Could not read sRGB components", sourceLocation: sourceLocation)
        return
    }

    #expect(abs(components.red - expected.red) < tolerance, sourceLocation: sourceLocation)
    #expect(abs(components.green - expected.green) < tolerance, sourceLocation: sourceLocation)
    #expect(abs(components.blue - expected.blue) < tolerance, sourceLocation: sourceLocation)
}

private func sRGBComponents(of color: Color) -> (red: Double, green: Double, blue: Double, alpha: Double)? {
    #if os(iOS)
    let platformColor = EazyPlatformColor(color).resolvedColor(with: .init())
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    guard platformColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
        return nil
    }
    #elseif os(macOS)
    guard let platformColor = EazyPlatformColor(color).usingColorSpace(.sRGB) else {
        return nil
    }

    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    platformColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    #endif

    return (Double(red), Double(green), Double(blue), Double(alpha))
}

#endif
