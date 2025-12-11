//
//  PageSize.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 11.12.2025.
//


/// A representation of a page size with standardized dimensions.
///
/// `PageSize` encapsulates a `CGSize` value representing the dimensions
/// of a page in points (1/72 of an inch). This type is commonly used
/// for PDF generation, printing, and document layout operations.
///
/// ## Conformance
/// - `Hashable`: Can be used in sets and dictionaries
/// - Value semantics: Copy-on-write behavior for safe mutation
///
/// ## Points vs Physical Units
/// The dimensions are specified in **points**, where:
/// - 1 point = 1/72 inch ≈ 0.3528 mm
/// - Common conversions:
///   - A4: 210 × 297 mm = 595.2 × 841.8 points
///   - US Letter: 8.5 × 11 inches = 612 × 792 points
///
/// ## Usage Example
/// ```swift
/// // Create a custom page size
/// let customSize = PageSize(width: 500, height: 700)
///
/// // Use a standard size
/// let a4 = PageSize.a4()
/// let letter = PageSize.letter()
///
/// // Access the underlying CGSize
/// print("A4 width: \(a4.size.width) points") // 595.2
/// print("A4 height: \(a4.size.height) points") // 841.8
/// ```
public struct PageSize: Hashable {

    /// The dimensions of the page in points.
    ///
    /// This property stores the width and height as a `CGSize`.
    /// Points are a resolution-independent unit (1 point = 1/72 inch).
    ///
    /// - Note: For PDF generation, these dimensions typically represent
    ///   the **media box** size, which is the physical page dimensions.
    ///   Additional boxes (crop, bleed, trim) may be smaller.
    public var size: CGSize

    /// Creates a page size with specified width and height.
    ///
    /// - Parameters:
    ///   - width: The width of the page in points.
    ///   - height: The height of the page in points.
    ///
    /// - Important: Dimensions should be positive values. While negative
    ///   values won't cause immediate errors, they may lead to unexpected
    ///   behavior in layout and rendering systems.
    public init(width: CGFloat, height: CGFloat) {
        self.size = .init(width: width, height: height)
    }

    /// Creates a page size from an existing `CGSize`.
    ///
    /// - Parameter size: The dimensions in points.
    public init(size: CGSize) {
        self.size = size
    }
}

extension PageSize {
    /// The standard A4 paper size in points.
    ///
    /// Returns a page size representing ISO 216 A4 paper:
    /// - **Physical dimensions**: 210 × 297 mm
    /// - **Point dimensions**: 595.2 × 841.8 points
    /// - **Common usage**: Standard paper size in most countries
    ///   outside North America
    ///
    /// - Returns: A `PageSize` instance for A4 paper.
    ///
    /// ## Example
    /// ```swift
    /// let documentSize = PageSize.a4()
    /// generatePDF(for: document, size: documentSize)
    /// ```
    public static func a4() -> Self {
        .init(width: 595.2, height: 841.8)
    }

    /// The standard US Letter paper size in points.
    ///
    /// Returns a page size representing US Letter paper:
    /// - **Physical dimensions**: 8.5 × 11 inches
    /// - **Point dimensions**: 612 × 792 points
    /// - **Common usage**: Standard paper size in the United States,
    ///   Canada, and some Latin American countries
    ///
    /// - Returns: A `PageSize` instance for US Letter paper.
    ///
    /// ## Example
    /// ```swift
    /// let resumeSize = PageSize.letter()
    /// printDocument(for: resume, size: resumeSize)
    /// ```
    public static func letter() -> Self {
        .init(width: 612, height: 792)
    }

    // Additional standard sizes could be added here:
    // static func a3() -> Self
    // static func legal() -> Self
    // static func tabloid() -> Self
}

extension PageSize {
    /// The width of the page in points.
    ///
    /// This is a convenience property that provides direct access
    /// to the width component of the underlying `CGSize`.
    public var width: CGFloat {
        size.width
    }

    /// The height of the page in points.
    ///
    /// This is a convenience property that provides direct access
    /// to the height component of the underlying `CGSize`.
    public var height: CGFloat {
        size.height
    }

    /// The aspect ratio of the page (width / height).
    ///
    /// Useful for maintaining proportions when scaling pages.
    /// Returns `NaN` if height is zero.
    public var aspectRatio: CGFloat {
        size.width / size.height
    }

    /// A Boolean value indicating whether the page is in portrait orientation.
    ///
    /// Returns `true` if height ≥ width (portrait or square),
    /// `false` if width > height (landscape).
    public var isPortrait: Bool {
        size.height >= size.width
    }

    /// A Boolean value indicating whether the page is in landscape orientation.
    ///
    /// Returns `true` if width > height, `false` otherwise.
    public var isLandscape: Bool {
        size.width > size.height
    }

    /// Returns a page size with the orientation swapped.
    ///
    /// Useful for converting between portrait and landscape orientations
    /// while maintaining the same physical paper size.
    ///
    /// - Returns: A new `PageSize` with width and height swapped.
    ///
    /// ## Example
    /// ```swift
    /// let portraitA4 = PageSize.a4() // 595.2 × 841.8
    /// let landscapeA4 = portraitA4.swappedOrientation() // 841.8 × 595.2
    /// ```
    public func swappedOrientation() -> Self {
        .init(width: size.height, height: size.width)
    }
}
