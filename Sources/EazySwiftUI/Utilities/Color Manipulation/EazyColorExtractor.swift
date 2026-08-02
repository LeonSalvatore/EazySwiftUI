//
//  EazyColorExtractor.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 02.08.2026.
//

import SwiftUI
import CoreGraphics
import ImageIO

#if os(iOS)
import UIKit

/// The platform image type accepted by the color extraction APIs.
///
/// Maps to `UIImage` on iOS and `NSImage` on macOS.
public typealias EazyPlatformImage = UIImage
#elseif os(macOS)
import AppKit

/// The platform image type accepted by the color extraction APIs.
///
/// Maps to `UIImage` on iOS and `NSImage` on macOS.
public typealias EazyPlatformImage = NSImage
#endif

#if os(iOS) || os(macOS)

/// Extracts representative colors from an image so they can be reused as
/// gradients, backgrounds, or accent colors.
///
/// The extractor downsamples the image once and then reads the resulting
/// pixels directly, so a single instance can be configured and reused:
///
/// ```swift
/// let extractor = EazyColorExtractor(count: 3, axis: .vertical)
/// let colors = extractor.colors(from: artwork)
/// ```
///
/// Two families of colors are available:
///
/// - `colors(from:)` splits the image into evenly sized
///   bands along ``axis`` and averages each band. The result keeps the spatial
///   order of the image, which is what a gradient needs.
/// - `dominantColors(from:)` quantizes the whole image
///   and returns the most frequently occurring colors, ordered by frequency.
///   This is what a palette or an accent color needs.
///
/// Every method has a `CGImage` overload for callers that already decoded an
/// image, and a `Data` overload that decodes, downsamples, and extracts off the
/// calling actor.
///
/// Extraction is deterministic and side-effect free, and colors are returned in
/// the sRGB color space.
public struct EazyColorExtractor: Sendable, Hashable {

    /// The direction along which the image is split into bands.
    public enum Axis: Sendable, Hashable, CaseIterable {
        /// Bands are stacked from the top of the image to the bottom.
        case vertical
        /// Bands are stacked from the leading edge of the image to the trailing edge.
        case horizontal
    }

    /// An extractor that produces three vertical bands from a 200 point sample.
    public static let `default` = EazyColorExtractor()

    /// The number of colors to produce. Always at least `1`.
    public var count: Int

    /// The direction along which the image is split into bands.
    public var axis: Axis

    /// The largest dimension, in pixels, of the downsampled image used for sampling.
    ///
    /// Smaller values are faster and smooth out noise; larger values preserve
    /// small details. Images smaller than this value are never upscaled.
    public var sampleSize: CGFloat

    /// Pixels whose opacity is below this value are ignored.
    ///
    /// This keeps transparent padding around logos and stickers from washing
    /// out the extracted colors. Use `0` to include every pixel.
    public var minimumOpacity: Double

    /// Creates an extractor.
    ///
    /// - Parameters:
    ///   - count: The number of colors to produce. Values below `1` are clamped to `1`.
    ///   - axis: The direction along which the image is split into bands.
    ///   - sampleSize: The largest dimension, in pixels, of the downsampled image.
    ///   - minimumOpacity: The opacity below which a pixel is ignored, from `0` to `1`.
    public init(
        count: Int = 3,
        axis: Axis = .vertical,
        sampleSize: CGFloat = 200,
        minimumOpacity: Double = 0.1
    ) {
        self.count = max(count, 1)
        self.axis = axis
        self.sampleSize = max(sampleSize, 1)
        self.minimumOpacity = minimumOpacity.clamped(to: 0...1)
    }

    /// The gradient start point that matches ``axis``.
    public var startPoint: UnitPoint {
        axis == .vertical ? .top : .leading
    }

    /// The gradient end point that matches ``axis``.
    public var endPoint: UnitPoint {
        axis == .vertical ? .bottom : .trailing
    }

    // MARK: - Banded colors

    /// Returns ``count`` colors sampled from evenly sized bands of the image.
    ///
    /// The colors keep the order of the image along ``axis``: with
    /// ``Axis/vertical`` the first color comes from the top of the image and
    /// the last one from the bottom.
    ///
    /// Bands that contain no pixel above ``minimumOpacity`` are reported as
    /// `Color.clear`, so the returned array always contains ``count`` elements
    /// unless the image cannot be decoded, in which case it is empty.
    ///
    /// - Parameter image: The image to sample.
    /// - Returns: The extracted colors, or an empty array if the image is `nil`
    ///   or cannot be decoded.
    public func colors(from image: EazyPlatformImage?) -> [Color] {
        guard let cgImage = image?.eazyCGImage else { return [] }
        return colors(from: cgImage)
    }

    /// Returns ``count`` colors sampled from evenly sized bands of the image.
    ///
    /// - Parameter cgImage: The decoded image to sample.
    /// - Returns: The extracted colors, or an empty array if the image cannot be read.
    public func colors(from cgImage: CGImage) -> [Color] {
        guard let grid = pixelGrid(from: cgImage) else { return [] }

        let extent = axis == .vertical ? grid.height : grid.width
        var result = [Color]()
        result.reserveCapacity(count)

        for index in 0..<count {
            let lower = extent * index / count
            let upper = max(extent * (index + 1) / count, lower + 1)
            let band = lower..<min(upper, extent)

            let region = axis == .vertical
                ? PixelRegion(columns: 0..<grid.width, rows: band)
                : PixelRegion(columns: band, rows: 0..<grid.height)

            result.append(grid.averageColor(in: region, minimumOpacity: minimumOpacity) ?? .clear)
        }

        return result
    }

    /// Decodes the image data and returns ``count`` banded colors.
    ///
    /// Decoding, downsampling, and sampling all happen off the calling actor,
    /// which makes this the preferred entry point for images loaded from disk
    /// or from the network.
    ///
    /// - Parameter data: Encoded image data, such as the contents of a JPEG or PNG file.
    /// - Returns: The extracted colors, or an empty array if the data cannot be decoded.
    public func colors(from data: Data) async -> [Color] {
        let extractor = self
        return await Task.detached(priority: .userInitiated) {
            guard let cgImage = extractor.decodedThumbnail(from: data) else { return [] }
            return extractor.colors(from: cgImage)
        }.value
    }

    // MARK: - Dominant colors

    /// Returns up to ``count`` colors ordered by how much of the image they cover.
    ///
    /// Similar colors are merged, so the result is a palette of visually
    /// distinct colors rather than several shades of the same one. Use this
    /// when picking an accent or tint color; use `colors(from:)`
    /// when the spatial order matters, such as for a gradient.
    ///
    /// - Parameter image: The image to sample.
    /// - Returns: The palette, ordered from the most to the least common color.
    public func dominantColors(from image: EazyPlatformImage?) -> [Color] {
        guard let cgImage = image?.eazyCGImage else { return [] }
        return dominantColors(from: cgImage)
    }

    /// Returns up to ``count`` colors ordered by how much of the image they cover.
    ///
    /// - Parameter cgImage: The decoded image to sample.
    /// - Returns: The palette, ordered from the most to the least common color.
    public func dominantColors(from cgImage: CGImage) -> [Color] {
        guard let grid = pixelGrid(from: cgImage) else { return [] }
        return grid.dominantColors(
            count: count,
            minimumOpacity: minimumOpacity
        )
    }

    /// Decodes the image data and returns up to ``count`` dominant colors.
    ///
    /// Decoding, downsampling, and sampling all happen off the calling actor.
    ///
    /// - Parameter data: Encoded image data, such as the contents of a JPEG or PNG file.
    /// - Returns: The palette, ordered from the most to the least common color.
    public func dominantColors(from data: Data) async -> [Color] {
        let extractor = self
        return await Task.detached(priority: .userInitiated) {
            guard let cgImage = extractor.decodedThumbnail(from: data) else { return [] }
            return extractor.dominantColors(from: cgImage)
        }.value
    }

    /// Returns the single color that covers most of the image.
    ///
    /// - Parameter image: The image to sample.
    /// - Returns: The most common color, or `nil` if the image cannot be sampled.
    public func dominantColor(from image: EazyPlatformImage?) -> Color? {
        dominantColors(from: image).first
    }

    /// Returns the single color that covers most of the image.
    ///
    /// - Parameter cgImage: The decoded image to sample.
    /// - Returns: The most common color, or `nil` if the image cannot be sampled.
    public func dominantColor(from cgImage: CGImage) -> Color? {
        dominantColors(from: cgImage).first
    }

    // MARK: - Average color

    /// Returns the opacity-weighted average color of the whole image.
    ///
    /// - Parameter image: The image to sample.
    /// - Returns: The average color, or `nil` if the image cannot be sampled or
    ///   contains no pixel above ``minimumOpacity``.
    public func averageColor(from image: EazyPlatformImage?) -> Color? {
        guard let cgImage = image?.eazyCGImage else { return nil }
        return averageColor(from: cgImage)
    }

    /// Returns the opacity-weighted average color of the whole image.
    ///
    /// - Parameter cgImage: The decoded image to sample.
    /// - Returns: The average color, or `nil` if the image cannot be sampled or
    ///   contains no pixel above ``minimumOpacity``.
    public func averageColor(from cgImage: CGImage) -> Color? {
        guard let grid = pixelGrid(from: cgImage) else { return nil }
        return grid.averageColor(
            in: PixelRegion(columns: 0..<grid.width, rows: 0..<grid.height),
            minimumOpacity: minimumOpacity
        )
    }

    // MARK: - Gradients

    /// Returns a gradient built from the banded colors of the image.
    ///
    /// - Parameter image: The image to sample.
    /// - Returns: A gradient with one stop per extracted color. The gradient is
    ///   clear when the image cannot be sampled.
    public func gradient(from image: EazyPlatformImage?) -> Gradient {
        Gradient(colors: eazyGradientColors(colors(from: image)))
    }

    /// Returns a linear gradient built from the banded colors of the image.
    ///
    /// The default start and end points follow ``axis``, so a vertical
    /// extractor produces a top-to-bottom gradient.
    ///
    /// ```swift
    /// Rectangle()
    ///     .fill(EazyColorExtractor.default.linearGradient(from: artwork))
    /// ```
    ///
    /// - Parameters:
    ///   - image: The image to sample.
    ///   - startPoint: The gradient start point. Defaults to the point matching ``axis``.
    ///   - endPoint: The gradient end point. Defaults to the point matching ``axis``.
    /// - Returns: A linear gradient with one stop per extracted color.
    public func linearGradient(
        from image: EazyPlatformImage?,
        startPoint: UnitPoint? = nil,
        endPoint: UnitPoint? = nil
    ) -> LinearGradient {
        LinearGradient(
            gradient: gradient(from: image),
            startPoint: startPoint ?? self.startPoint,
            endPoint: endPoint ?? self.endPoint
        )
    }

    // MARK: - Sampling

    private func pixelGrid(from cgImage: CGImage) -> EazyPixelGrid? {
        let width = cgImage.width
        let height = cgImage.height
        guard width > 0, height > 0 else { return nil }

        let scale = min(1, sampleSize / CGFloat(max(width, height)))
        let targetWidth = max(Int((CGFloat(width) * scale).rounded()), 1)
        let targetHeight = max(Int((CGFloat(height) * scale).rounded()), 1)
        let bytesPerRow = targetWidth * 4

        var pixels = [UInt8](repeating: 0, count: bytesPerRow * targetHeight)

        let didDraw = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard
                let baseAddress = buffer.baseAddress,
                let context = CGContext(
                    data: baseAddress,
                    width: targetWidth,
                    height: targetHeight,
                    bitsPerComponent: 8,
                    bytesPerRow: bytesPerRow,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                )
            else {
                return false
            }

            context.interpolationQuality = .medium
            context.draw(
                cgImage,
                in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight)
            )
            return true
        }

        guard didDraw else { return nil }

        return EazyPixelGrid(
            pixels: pixels,
            width: targetWidth,
            height: targetHeight
        )
    }

    private func decodedThumbnail(from data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(sampleSize.rounded())
        ]

        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }
}

// MARK: - Pixel sampling

/// A downsampled, premultiplied RGBA8 representation of an image.
private struct EazyPixelGrid {
    let pixels: [UInt8]
    let width: Int
    let height: Int

    /// Returns the opacity-weighted average color of a region, or `nil` when the
    /// region contains no pixel above `minimumOpacity`.
    func averageColor(in region: PixelRegion, minimumOpacity: Double) -> Color? {
        let alphaCutoff = UInt8(min(max(minimumOpacity * 255, 0), 255).rounded())

        var redTotal = 0
        var greenTotal = 0
        var blueTotal = 0
        var alphaTotal = 0
        var sampledPixels = 0

        for row in region.rows {
            let rowOffset = row * width * 4

            for column in region.columns {
                let offset = rowOffset + column * 4
                let alpha = pixels[offset + 3]
                guard alpha >= alphaCutoff, alpha > 0 else { continue }

                // The buffer is premultiplied, so summing the raw components and
                // dividing by the summed alpha yields the opacity-weighted average.
                redTotal += Int(pixels[offset])
                greenTotal += Int(pixels[offset + 1])
                blueTotal += Int(pixels[offset + 2])
                alphaTotal += Int(alpha)
                sampledPixels += 1
            }
        }

        guard sampledPixels > 0, alphaTotal > 0 else { return nil }

        let alphaScale = Double(alphaTotal)
        return Color(
            .sRGB,
            red: (Double(redTotal) / alphaScale).clamped(to: 0...1),
            green: (Double(greenTotal) / alphaScale).clamped(to: 0...1),
            blue: (Double(blueTotal) / alphaScale).clamped(to: 0...1),
            opacity: (alphaScale / Double(sampledPixels * 255)).clamped(to: 0...1)
        )
    }

    /// Returns the most frequent colors of the grid, merging visually similar ones.
    func dominantColors(count: Int, minimumOpacity: Double) -> [Color] {
        let alphaCutoff = UInt8(min(max(minimumOpacity * 255, 0), 255).rounded())

        struct Bucket {
            var red = 0
            var green = 0
            var blue = 0
            var occurrences = 0
        }

        var buckets = [Int: Bucket]()

        for row in 0..<height {
            let rowOffset = row * width * 4

            for column in 0..<width {
                let offset = rowOffset + column * 4
                let alpha = pixels[offset + 3]
                guard alpha >= alphaCutoff, alpha > 0 else { continue }

                let alphaScale = 255 / Double(alpha)
                let red = Int((Double(pixels[offset]) * alphaScale).rounded()).clamped(to: 0...255)
                let green = Int((Double(pixels[offset + 1]) * alphaScale).rounded()).clamped(to: 0...255)
                let blue = Int((Double(pixels[offset + 2]) * alphaScale).rounded()).clamped(to: 0...255)

                // Five bits per channel keeps shades of the same color together
                // without collapsing distinct hues.
                let key = (red >> 3) << 10 | (green >> 3) << 5 | (blue >> 3)

                var bucket = buckets[key] ?? Bucket()
                bucket.red += red
                bucket.green += green
                bucket.blue += blue
                bucket.occurrences += 1
                buckets[key] = bucket
            }
        }

        let ranked = buckets
            .sorted { lhs, rhs in
                lhs.value.occurrences == rhs.value.occurrences
                    ? lhs.key < rhs.key
                    : lhs.value.occurrences > rhs.value.occurrences
            }
            .map { _, bucket in
                (
                    red: Double(bucket.red) / Double(bucket.occurrences) / 255,
                    green: Double(bucket.green) / Double(bucket.occurrences) / 255,
                    blue: Double(bucket.blue) / Double(bucket.occurrences) / 255
                )
            }

        var selected = [(red: Double, green: Double, blue: Double)]()

        for candidate in ranked where selected.count < count {
            let isDistinct = selected.allSatisfy { existing in
                let redDelta = existing.red - candidate.red
                let greenDelta = existing.green - candidate.green
                let blueDelta = existing.blue - candidate.blue
                let distance = (redDelta * redDelta + greenDelta * greenDelta + blueDelta * blueDelta).squareRoot()
                return distance > 0.12
            }

            if isDistinct {
                selected.append(candidate)
            }
        }

        // Fall back to the raw ranking when the image is too uniform to provide
        // enough distinct colors.
        if selected.isEmpty {
            selected = Array(ranked.prefix(count))
        }

        return selected.map {
            Color(.sRGB, red: $0.red, green: $0.green, blue: $0.blue, opacity: 1)
        }
    }
}

/// A rectangular region of an ``EazyPixelGrid``.
private struct PixelRegion {
    let columns: Range<Int>
    let rows: Range<Int>
}

// MARK: - Platform image bridging

public extension EazyPlatformImage {
    /// The underlying Core Graphics image, bridged consistently across platforms.
    var eazyCGImage: CGImage? {
        #if os(iOS)
        return cgImage
        #elseif os(macOS)
        var rect = CGRect(origin: .zero, size: size)
        return cgImage(forProposedRect: &rect, context: nil, hints: nil)
        #endif
    }

    /// The colors of the image, sampled in bands from top to bottom.
    ///
    /// A convenience for `EazyColorExtractor.colors(from:)`.
    ///
    /// - Parameter count: The number of colors to extract.
    /// - Returns: The extracted colors, ordered from the top of the image to the bottom.
    func eazyColors(count: Int = 3) -> [Color] {
        EazyColorExtractor(count: count).colors(from: self)
    }

    /// The color that covers most of the image.
    ///
    /// A convenience for `EazyColorExtractor.dominantColor(from:)`.
    var eazyDominantColor: Color? {
        EazyColorExtractor(count: 1).dominantColor(from: self)
    }

    /// The opacity-weighted average color of the image.
    ///
    /// A convenience for `EazyColorExtractor.averageColor(from:)`.
    var eazyAverageColor: Color? {
        EazyColorExtractor.default.averageColor(from: self)
    }
}

// MARK: - Helpers

/// Returns colors that are always valid gradient stops.
///
/// SwiftUI needs at least two stops to interpolate, so a single extracted color
/// is repeated and an empty result becomes a clear gradient.
func eazyGradientColors(_ colors: [Color]) -> [Color] {
    switch colors.count {
    case 0: [.clear, .clear]
    case 1: [colors[0], colors[0]]
    default: colors
    }
}

#endif
