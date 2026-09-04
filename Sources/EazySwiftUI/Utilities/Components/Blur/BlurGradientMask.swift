//
//  BlurGradientMask.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 04.09.2026.
//


#if canImport(UIKit)
import CoreGraphics
import UIKit

/// Builds the single-column alpha ramps that drive ``VariableBlur``.
@MainActor
enum BlurGradientMask {
    private static let cache = NSCache<NSString, CGImage>()
    private static let colorSpace = CGColorSpaceCreateDeviceGray()

    static func ramp(
        length: Int,
        edge: VariableBlurEdge,
        plateau: CGFloat,
        eased: Bool
    ) -> CGImage? {
        let alphas = alphaValues(
            length: length,
            edge: edge,
            plateau: plateau,
            eased: eased
        )
        guard !alphas.isEmpty else { return nil }

        let normalizedPlateau = unitValue(plateau)
        let key = "\(length)-\(edge.rawValue)-\(normalizedPlateau)-\(eased)" as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        let bytesPerPixel = 2
        var bytes = [UInt8](repeating: 0, count: length * bytesPerPixel)
        for (row, alpha) in alphas.enumerated() {
            // Gray remains zero. Premultiplication requires gray <= alpha, and
            // the filter reads only the alpha channel.
            bytes[row * bytesPerPixel + 1] = alpha
        }

        guard let provider = CGDataProvider(data: Data(bytes) as CFData),
              let image = CGImage(
                  width: 1,
                  height: length,
                  bitsPerComponent: 8,
                  bitsPerPixel: bytesPerPixel * 8,
                  bytesPerRow: bytesPerPixel,
                  space: colorSpace,
                  bitmapInfo: CGBitmapInfo(
                      rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
                  ),
                  provider: provider,
                  decode: nil,
                  shouldInterpolate: true,
                  intent: .defaultIntent
              ) else {
            return nil
        }

        cache.setObject(image, forKey: key)
        return image
    }

    static func alphaValues(
        length: Int,
        edge: VariableBlurEdge,
        plateau: CGFloat,
        eased: Bool
    ) -> [UInt8] {
        guard length > 0 else { return [] }

        let plateau = unitValue(plateau)
        let lastIndex = CGFloat(max(length - 1, 1))
        let rampRange = plateau < 1 ? 1 / (1 - plateau) : 0

        return (0..<length).map { row in
            let position = CGFloat(row) / lastIndex
            let distance = edge == .top ? position : 1 - position

            let alpha: CGFloat
            if distance <= plateau {
                alpha = 1
            } else {
                let progress = (distance - plateau) * rampRange
                alpha = 1 - (eased ? easeInOutSine(progress) : progress)
            }

            return UInt8(unitValue(alpha) * 255)
        }
    }

    private static func easeInOutSine(_ value: CGFloat) -> CGFloat {
        -(cos(.pi * unitValue(value)) - 1) / 2
    }

    private static func unitValue(_ value: CGFloat) -> CGFloat {
        value.isFinite ? min(max(value, 0), 1) : 0
    }
}
#endif
