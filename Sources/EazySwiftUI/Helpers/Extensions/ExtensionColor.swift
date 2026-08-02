//
//  ExtensionColor.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 03.03.2026.
//

import SwiftUI

#if os(iOS)
import UIKit

public typealias EazyPlatformColor = UIColor

public extension UIColor {
    convenience init(hex: String) {
        let components = EazyHexColorComponents(hex)
        self.init(
            red: components.red,
            green: components.green,
            blue: components.blue,
            alpha: components.alpha
        )
    }
}
#elseif os(macOS)
import AppKit

public typealias EazyPlatformColor = NSColor

public extension NSColor {
    convenience init(hex: String) {
        let components = EazyHexColorComponents(hex)
        self.init(
            srgbRed: components.red,
            green: components.green,
            blue: components.blue,
            alpha: components.alpha
        )
    }
}
#endif

// MARK: - Color Hexadecimal Extensions

public extension Color {

    /// Creates a dynamic color that switches between light and dark mode variants.
    init(lightHex: String, darkHex: String) {
        #if os(iOS)
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: darkHex)
                : UIColor(hex: lightHex)
        })
        #elseif os(macOS)
        self.init(NSColor(name: nil) { appearance in
            let matchedAppearance = appearance.bestMatch(from: [.darkAqua, .aqua])
            return matchedAppearance == .darkAqua
                ? NSColor(hex: darkHex)
                : NSColor(hex: lightHex)
        })
        #else
        self.init(hex: lightHex)
        #endif
    }

    /// Initializes a Color from a hexadecimal integer value.
    ///
    /// Supports 6-digit RGB (`0xRRGGBB`) and 8-digit RGBA (`0xRRGGBBAA`) values.
    init(hex: Int, alpha: Double = 1.0) {
        if hex > 0xFFFFFF {
            self.init(
                .sRGB,
                red: Double((hex >> 24) & 0xFF) / 255,
                green: Double((hex >> 16) & 0xFF) / 255,
                blue: Double((hex >> 8) & 0xFF) / 255,
                opacity: Double(hex & 0xFF) / 255
            )
        } else {
            self.init(
                .sRGB,
                red: Double((hex >> 16) & 0xFF) / 255,
                green: Double((hex >> 8) & 0xFF) / 255,
                blue: Double(hex & 0xFF) / 255,
                opacity: alpha
            )
        }
    }

    /// Initializes a Color from a hexadecimal string.
    ///
    /// Supports `#RGB`, `#RRGGBB`, and `#AARRGGBB`. The `#` prefix is optional.
    init(hex: String) {
        let components = EazyHexColorComponents(hex)
        self.init(
            .sRGB,
            red: components.red,
            green: components.green,
            blue: components.blue,
            opacity: components.alpha
        )
    }

    /// The color's hexadecimal representation as an integer.
    ///
    /// Returns `0xRRGGBB` for opaque colors and `0xRRGGBBAA` when alpha is below 1.
    var hex: Int {
        let components = rgbaComponents
        let red = eazyColorByte(components.red)
        let green = eazyColorByte(components.green)
        let blue = eazyColorByte(components.blue)
        let alpha = eazyColorByte(components.alpha)

        if alpha == 255 {
            return (red << 16) | (green << 8) | blue
        } else {
            return (red << 24) | (green << 16) | (blue << 8) | alpha
        }
    }

    /// The color's hexadecimal representation as a formatted string.
    ///
    /// Returns `#RRGGBB` for opaque colors and `#RRGGBBAA` when alpha is below 1.
    var hexString: String {
        let components = rgbaComponents
        let red = eazyColorByte(components.red)
        let green = eazyColorByte(components.green)
        let blue = eazyColorByte(components.blue)
        let alpha = eazyColorByte(components.alpha)

        if alpha == 255 {
            return String(format: "#%02X%02X%02X", red, green, blue)
        } else {
            return String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
        }
    }

    /// The relative luminance of the color, from `0` for black to `1` for white.
    ///
    /// Uses the sRGB coefficients defined by WCAG, so the value reflects
    /// perceived brightness rather than raw component averages. This pairs well
    /// with colors produced by `EazyColorExtractor`, where the brightness of an
    /// extracted palette is not known ahead of time.
    var luminance: Double {
        let components = rgbaComponents
        return 0.2126 * Double(components.red)
            + 0.7152 * Double(components.green)
            + 0.0722 * Double(components.blue)
    }

    /// A Boolean value indicating whether the color reads as a dark color.
    var isDark: Bool {
        luminance < 0.5
    }

    /// A foreground color that stays legible on top of this color.
    ///
    /// Returns white on dark colors and black on light ones.
    ///
    /// ```swift
    /// let background = artwork.eazyDominantColor ?? .accentColor
    ///
    /// Text(album.title)
    ///     .foregroundStyle(background.readableForeground)
    ///     .background(background)
    /// ```
    var readableForeground: Color {
        isDark ? .white : .black
    }

    private var rgbaComponents: EazyHexColorComponents {
        #if os(iOS)
        let color = UIColor(self).resolvedColor(with: .init())
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return .black
        }

        return .init(red: red, green: green, blue: blue, alpha: alpha)
        #elseif os(macOS)
        guard let color = NSColor(self).usingColorSpace(.sRGB) else {
            return .black
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return .init(red: red, green: green, blue: blue, alpha: alpha)
        #else
        return .black
        #endif
    }
}

private func eazyColorByte(_ component: CGFloat) -> Int {
    min(max(Int((component * 255).rounded()), 0), 255)
}

private struct EazyHexColorComponents {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat

    static let black = EazyHexColorComponents(red: 0, green: 0, blue: 0, alpha: 1)

    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(_ hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let alpha: UInt64
        let red: UInt64
        let green: UInt64
        let blue: UInt64

        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }
}
