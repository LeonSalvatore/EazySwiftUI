//
//  ImageGradient.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 02.08.2026.
//

import SwiftUI

#if os(iOS) || os(macOS)

/// A view that fills its bounds with a gradient built from the colors of an image.
///
/// The view samples the image with an ``EazyColorExtractor`` and animates
/// between palettes whenever the image changes, which makes it a drop-in
/// backdrop for artwork, avatars, or hero images:
///
/// ```swift
/// ZStack {
///     ImageGradient(image: artwork)
///         .ignoresSafeArea()
///
///     AlbumDetails(album: album)
/// }
/// ```
///
/// Configure the sampling through the extractor, and observe the result with
/// `onExtract` when the surrounding UI needs the same colors:
///
/// ```swift
/// ImageGradient(
///     image: artwork,
///     extractor: EazyColorExtractor(count: 5, axis: .horizontal),
///     onExtract: { palette = $0 }
/// )
/// ```
///
/// Sampling happens on a downsampled copy of the image. For large images
/// decoded from disk or from the network, extract the colors ahead of time with
/// `EazyColorExtractor.colors(from:)` on `Data` and pass them to a plain
/// `LinearGradient` instead.
public struct ImageGradient: View {
    private let image: EazyPlatformImage?
    private let extractor: EazyColorExtractor
    private let startPoint: UnitPoint
    private let endPoint: UnitPoint
    private let placeholderColors: [Color]
    private let animation: Animation?
    private let onExtract: ([Color]) -> Void

    @State private var colors = [Color]()

    /// Creates a gradient view for an image.
    ///
    /// - Parameters:
    ///   - image: The image to sample. Pass `nil` to show `placeholderColors`.
    ///   - extractor: The extractor that defines how many colors are read and how.
    ///   - startPoint: The gradient start point. Defaults to the point matching
    ///     the extractor's axis.
    ///   - endPoint: The gradient end point. Defaults to the point matching the
    ///     extractor's axis.
    ///   - placeholderColors: The colors shown while no image is available or
    ///     when extraction produces nothing.
    ///   - animation: The animation used when the palette changes. Pass `nil`
    ///     to update without animating.
    ///   - onExtract: A closure called with the extracted colors after each
    ///     successful extraction.
    public init(
        image: EazyPlatformImage?,
        extractor: EazyColorExtractor = .default,
        startPoint: UnitPoint? = nil,
        endPoint: UnitPoint? = nil,
        placeholderColors: [Color] = [],
        animation: Animation? = .easeInOut(duration: 0.35),
        onExtract: @escaping ([Color]) -> Void = { _ in }
    ) {
        self.image = image
        self.extractor = extractor
        self.startPoint = startPoint ?? extractor.startPoint
        self.endPoint = endPoint ?? extractor.endPoint
        self.placeholderColors = placeholderColors
        self.animation = animation
        self.onExtract = onExtract
    }

    public var body: some View {
        Rectangle()
            .fill(gradient)
            .onAppear(perform: updateColors)
            .onChange(of: imageIdentity) { _, _ in updateColors() }
    }

    private var gradient: LinearGradient {
        LinearGradient(
            colors: eazyGradientColors(colors.isEmpty ? placeholderColors : colors),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    /// Identifies the image by reference so a changed palette is only recomputed
    /// when a different image instance is supplied.
    private var imageIdentity: ObjectIdentifier? {
        image.map(ObjectIdentifier.init)
    }

    private func updateColors() {
        let extracted = extractor.colors(from: image)
        guard !extracted.isEmpty else { return }

        withAnimation(animation) {
            colors = extracted
        }

        onExtract(extracted)
    }
}

// MARK: - View support

public extension View {
    /// Places a gradient built from the colors of an image behind this view.
    ///
    /// ```swift
    /// AlbumDetails(album: album)
    ///     .eazyImageGradientBackground(album.artwork)
    /// ```
    ///
    /// - Parameters:
    ///   - image: The image to sample. Pass `nil` to show `placeholderColors`.
    ///   - extractor: The extractor that defines how many colors are read and how.
    ///   - placeholderColors: The colors shown while no image is available.
    ///   - animation: The animation used when the palette changes.
    /// - Returns: The view, drawn above the extracted gradient.
    func eazyImageGradientBackground(
        _ image: EazyPlatformImage?,
        extractor: EazyColorExtractor = .default,
        placeholderColors: [Color] = [],
        animation: Animation? = .easeInOut(duration: 0.35)
    ) -> some View {
        background {
            ImageGradient(
                image: image,
                extractor: extractor,
                placeholderColors: placeholderColors,
                animation: animation
            )
            .ignoresSafeArea()
        }
    }
}

#if DEBUG
#Preview("Image gradient") {
    ImageGradient(image: EazyPlatformImage.eazyPreviewSample)
        .overlay(alignment: .bottom) {
            HStack(spacing: 8) {
                ForEach(
                    Array(
                        EazyColorExtractor(count: 4)
                            .dominantColors(from: EazyPlatformImage.eazyPreviewSample)
                            .enumerated()
                    ),
                    id: \.offset
                ) { _, color in
                    Circle()
                        .fill(color)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(24)
        }
}

private extension EazyPlatformImage {
    /// A three-band sample image used by previews and by nothing else.
    static var eazyPreviewSample: EazyPlatformImage? {
        let size = CGSize(width: 120, height: 240)
        let colors: [CGColor] = [
            CGColor(red: 0.42, green: 0.36, blue: 0.90, alpha: 1),
            CGColor(red: 0.95, green: 0.45, blue: 0.35, alpha: 1),
            CGColor(red: 0.12, green: 0.62, blue: 0.55, alpha: 1)
        ]

        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        let bandHeight = size.height / CGFloat(colors.count)

        for (index, color) in colors.enumerated() {
            context.setFillColor(color)
            context.fill(
                CGRect(
                    x: 0,
                    y: CGFloat(index) * bandHeight,
                    width: size.width,
                    height: bandHeight
                )
            )
        }

        guard let cgImage = context.makeImage() else { return nil }

        #if os(iOS)
        return UIImage(cgImage: cgImage)
        #elseif os(macOS)
        return NSImage(cgImage: cgImage, size: size)
        #endif
    }
}
#endif

#endif
