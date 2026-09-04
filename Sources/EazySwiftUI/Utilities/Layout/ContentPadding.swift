//
//  ContentPadding.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 04.09.2026.
//

import SwiftUI

// MARK: - Content Padding

/// A semantic horizontal padding scale for the design system.
///
/// `ContentPadding` represents the base horizontal dimension of a
/// component's content inset. The corresponding vertical inset is
/// calculated proportionally using a `ContentPadding.Ratio`.
///
/// The scale follows a 4-point spacing system:
///
///     XS →  8pt
///     SM → 12pt
///     MD → 16pt
///     LG → 20pt
///     XL → 24pt
///
/// The vertical padding is derived from the horizontal padding rather
/// than being independently defined:
///
///     vertical = horizontal × ratio
///
/// The default ratio is `.compact`, which produces a 3:4
/// vertical-to-horizontal relationship.
///
/// Example:
///
///     Text("Continue")
///         .contentPadding(.md)
///
/// Produces:
///
///     Horizontal = 16pt
///     Vertical   = 16pt × 0.75 = 12pt
///
/// - Note: `ContentPadding` defines visual content insets. It does not
///   define an interactive hit target.
public enum ContentPadding: CGFloat, Sendable {

    /// 8pt horizontal padding.
    case xs = 8

    /// 12pt horizontal padding.
    case sm = 12

    /// 16pt horizontal padding.
    ///
    /// The recommended default for most text-based components.
    case md = 16

    /// 20pt horizontal padding.
    case lg = 20

    /// 24pt horizontal padding.
    case xl = 24
}

// MARK: - Ratio

extension ContentPadding {

    /// Defines the proportional relationship between horizontal
    /// and vertical content padding.
    ///
    /// The vertical value is calculated using:
    ///
    ///     vertical = horizontal × ratio
    public enum Ratio: CGFloat, Sendable {

        /// Compact vertical spacing.
        ///
        /// Uses a 3:4 vertical-to-horizontal relationship.
        ///
        ///     vertical = horizontal × 0.75
        ///
        /// Example:
        ///
        ///     16pt × 0.75 = 12pt
        case compact = 0.75

        /// Standard vertical spacing.
        ///
        /// Uses a 7:8 vertical-to-horizontal relationship.
        ///
        ///     vertical = horizontal × 0.875
        ///
        /// Example:
        ///
        ///     16pt × 0.875 = 14pt
        case standard = 0.875

        /// Equal horizontal and vertical spacing.
        ///
        ///     vertical = horizontal × 1.0
        ///
        /// Example:
        ///
        ///     16pt × 1.0 = 16pt
        case equal = 1.0
    }
}

// MARK: - Values

extension ContentPadding {

    /// The base horizontal content padding in points.
    public var horizontal: CGFloat {
        rawValue
    }

    /// Returns the vertical content padding calculated using
    /// the specified ratio.
    ///
    /// - Parameter ratio: The proportional relationship between
    ///   horizontal and vertical padding.
    /// - Returns: The calculated vertical padding in points.
    public func vertical(
        using ratio: Ratio
    ) -> CGFloat {
        horizontal * ratio.rawValue
    }

    /// Returns the complete edge insets calculated using
    /// the specified ratio.
    ///
    /// - Parameter ratio: The proportional relationship between
    ///   horizontal and vertical padding.
    /// - Returns: The calculated content insets.
    public func insets(
        using ratio: Ratio
    ) -> EdgeInsets {
        let vertical = vertical(using: ratio)

        return EdgeInsets(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        )
    }
}

// MARK: - Default Ratio

extension ContentPadding {

    /// The default ratio used by `contentPadding(_:)`.
    ///
    /// `.compact` provides a 3:4 vertical-to-horizontal relationship:
    ///
    ///     vertical : horizontal = 3 : 4
    ///
    /// For example:
    ///
    ///     16pt horizontal × 0.75 = 12pt vertical
    public static let defaultRatio: Ratio = .compact
}

// MARK: - View

extension View {

    /// Applies content padding using the default proportional ratio.
    ///
    /// The vertical padding is calculated from the horizontal padding:
    ///
    ///     vertical = horizontal × 0.75
    ///
    /// Example:
    ///
    ///     Text("Some text")
    ///         .contentPadding(.md)
    ///
    /// Produces:
    ///
    ///     Horizontal = 16pt
    ///     Vertical   = 12pt
    ///
    /// This is equivalent to:
    ///
    ///     Text("Some text")
    ///         .padding(.horizontal, 16)
    ///         .padding(.vertical, 12)
    ///
    /// - Parameter padding: The semantic content padding size.
    /// - Returns: A view with the specified content padding applied.
    @inlinable
    public func contentPadding(
        _ padding: ContentPadding
    ) -> some View {
        self.padding(
            padding.insets(
                using: ContentPadding.defaultRatio
            )
        )
    }

    /// Applies content padding using an explicit proportional ratio.
    ///
    /// The vertical padding is calculated as:
    ///
    ///     vertical = horizontal × ratio
    ///
    /// Example:
    ///
    ///     Text("Some text")
    ///         .contentPadding(.md, ratio: .standard)
    ///
    /// Produces:
    ///
    ///     Horizontal = 16pt
    ///     Vertical   = 14pt
    ///
    /// - Parameters:
    ///   - padding: The semantic horizontal content padding size.
    ///   - ratio: The proportional relationship between horizontal
    ///     and vertical padding.
    /// - Returns: A view with the calculated content padding applied.
    @inlinable
    public func contentPadding(
        _ padding: ContentPadding,
        ratio: ContentPadding.Ratio
    ) -> some View {
        self.padding(
            padding.insets(using: ratio)
        )
    }
}
