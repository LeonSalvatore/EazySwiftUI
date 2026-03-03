//
//  SwiftUIView.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 03.03.2026.
//

import SwiftUI

// MARK: - UIColor Hexadecimal Extensions
/// Provides hexadecimal color initialization and conversion capabilities for UIColor.
public extension UIColor {

    // MARK: - Hexadecimal Initialization

    /**
     Initializes a UIColor from a hexadecimal string.

     The string can be in the following formats:
     - RGB (12-bit): "#RGB" (e.g., "#F0F")
     - RGB (24-bit): "#RRGGBB" (e.g., "#FF0000" for red)
     - ARGB (32-bit): "#AARRGGBB" (e.g., "#80FF0000" for 50% transparent red)

     The # prefix is optional. The method automatically trims whitespaces and invalid characters.

     - Parameter hex: A hexadecimal color string (e.g., "#FF0000", "FF0000", "#F00")

     - Note: If an invalid hex string is provided, defaults to black color.

     **Example Usage:**
     ```swift
     let red = UIColor(hex: "#FF0000")
     let blue = UIColor(hex: "0000FF")
     let shortRed = UIColor(hex: "#F00")
     let semiTransparentGreen = UIColor(hex: "#8000FF00")
     */
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, alpha: Double(a) / 255)
    }
}

// MARK: - Color Hexadecimal Extensions
/// Provides comprehensive hexadecimal support for SwiftUI Color, including dynamic colors and conversions.
public extension Color {

    // MARK: - Dynamic Color Initialization

    /**
     Creates a dynamic color that automatically switches between light and dark mode variants.

     This initializer creates a UIColor that responds to trait collection changes, which is then
     wrapped in a SwiftUI Color. Perfect for implementing custom dark mode support.

     Parameters:

     lightHex: Hexadecimal color string for light mode (e.g., "#6B5BFF")
     darkHex: Hexadecimal color string for dark mode (e.g., "#8B7BFF")
     Example Usage:

     swift
     struct ContentView: View {
     // Dynamic brand color that adapts to light/dark mode
     let brandColor = Color(lightHex: "#6B5BFF", darkHex: "#8B7BFF")

     var body: some View {
     Text("Metronome")
     .foregroundColor(brandColor)
     }
     }
     */
    init(lightHex: String, darkHex: String) {
        self.init(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(hex: darkHex)
            } else {
                return UIColor(hex: lightHex)
            }
        })
    }

    // MARK: - Hexadecimal Integer Initialization

    /**
     Initializes a Color from a hexadecimal integer value.

     Supports both 6-digit RGB and 8-digit RGBA formats. When using 8-digit format,
     the alpha component from the hex value takes precedence over the alpha parameter.

     Parameters:

     hex: A 6-digit (RGB) or 8-digit (RGBA) hexadecimal color code as an integer.
     alpha: The optional alpha component (0.0 - 1.0). Defaults to 1.0.
     Ignored when using 8-digit hex format.
     Note: For 8-digit hex, format should be 0xRRGGBBAA (e.g., 0xFF000080 for 50% transparent red)
     Example Usage:

     swift
     let blue = Color(hex: 0x2C8DFF)              // Solid blue
     let red = Color(hex: 0xFF0000)                // Solid red
     let semiTransparentRed = Color(hex: 0xFF0000, alpha: 0.5) // 50% red
     let purpleWithAlpha = Color(hex: 0x9D5BFF80)   // Purple with alpha from hex
     */
    init(hex: Int, alpha: Double = 1.0) {
        if hex > 0xFFFFFF { // RGBA format (8 digits)
            self.init(
                .sRGB,
                red: Double((hex >> 24) & 0xFF) / 255,
                green: Double((hex >> 16) & 0xFF) / 255,
                blue: Double((hex >> 8) & 0xFF) / 255,
                opacity: Double(hex & 0xFF) / 255
            )
        } else { // RGB format (6 digits)
            self.init(
                .sRGB,
                red: Double((hex >> 16) & 0xFF) / 255,
                green: Double((hex >> 8) & 0xFF) / 255,
                blue: Double(hex & 0xFF) / 255,
                opacity: alpha
            )
        }
    }

    // MARK: - Hexadecimal String Initialization

    /**
     Initializes a Color from a hexadecimal string.

     Supports the following formats:

     3-digit RGB: "#RGB" (e.g., "#F0F" for magenta)
     6-digit RGB: "#RRGGBB" (e.g., "#FF0000" for red)
     8-digit ARGB: "#AARRGGBB" (e.g., "#80FF0000" for 50% transparent red)
     The # prefix is optional. Case-insensitive.

     Parameter hex: A hexadecimal color string
     Note: Invalid hex strings default to black (#000000)
     Example Usage:

     swift
     let red = Color(hex: "#FF0000")
     let blue = Color(hex: "0000FF")
     let shortMagenta = Color(hex: "#F0F")
     let transparentGreen = Color(hex: "#8000FF00")
     */
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Integer Hexadecimal Representation

    /**
     Returns the color's hexadecimal representation as an integer.

     The returned value will be:

     6-digit RGB (0xRRGGBB) if alpha is 255 (opaque)
     8-digit RGBA (0xRRGGBBAA) if alpha is less than 255 (transparent)
     Note: This property resolves the color for the current trait collection,
     so it respects dark/light mode if the color is dynamic.
     Example Usage:

     swift
     let color = Color.blue
     let hexValue = color.hex  // Returns 0x0000FF
     print(String(format: "%06X", hexValue)) // Prints "0000FF"
     */
    var hex: Int {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return 0
        }

        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)
        let alpha = components.count >= 4 ? Int(components[3] * 255) : 255

        if alpha == 255 {
            return (red << 16) | (green << 8) | blue
        } else {
            return (red << 24) | (green << 16) | (blue << 8) | alpha
        }
    }

    // MARK: - String Hexadecimal Representation

    /**
     Returns the color's hexadecimal representation as a formatted string.

     The string format will be:

     "#RRGGBB" if alpha is 255 (opaque)
     "#RRGGBBAA" if alpha is less than 255 (transparent)
     Note: This property resolves the color for the current trait collection,
     so it respects dark/light mode if the color is dynamic.
     Example Usage:

     swift
     let color = Color(hex: 0xFF0000)
     print(color.hexString) // Prints "#FF0000"

     let transparent = Color(hex: 0xFF000080)
     print(transparent.hexString) // Prints "#FF000080"
     */
    var hexString: String {
        let uiColor = UIColor(self).resolvedColor(with: .init())

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return "#000000"
        }

        let red = Int(r * 255.0)
        let green = Int(g * 255.0)
        let blue = Int(b * 255.0)
        let alpha = Int(a * 255.0)

        if alpha == 255 {
            return String(format: "#%02X%02X%02X", red, green, blue)
        } else {
            return String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
        }
    }
}

// MARK: - Example View
/// A demonstration view showcasing the color extension usage
struct SwiftUIView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Dynamic color example
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(lightHex: "#6B5BFF", darkHex: "#8B7BFF"))
                .frame(height: 60)
                .overlay(
                    Text("Dynamic Brand Color")
                        .foregroundColor(.white)
                        .font(.headline)
                )

            // Hex integer example
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: 0x2C8DFF))
                .frame(height: 60)
                .overlay(
                    Text("Hex: 0x2C8DFF")
                        .foregroundColor(.white)
                )

            // Hex string with transparency example
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#80FF0000"))
                .frame(height: 60)
                .overlay(
                    Text("50% Transparent Red")
                        .foregroundColor(.white)
                )

            // Display hex values
            let color = Color.blue
            Text("Blue hex: (color.hexString)")
                .font(.caption)
                .padding()
                .background(color.opacity(0.1))
                .cornerRadius(8)

            // Test hex conversion
            let testColor = Color(hex: "#FF5733")
            Text("Test color hex: (testColor.hexString)")
                .font(.caption)
                .padding()
                .background(testColor.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    SwiftUIView()
}
