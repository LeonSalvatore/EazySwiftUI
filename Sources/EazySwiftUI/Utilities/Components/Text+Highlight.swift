//
//  Text+Highlight.swift
//  EazySwiftUI
//

import SwiftUI

/// Attributes applied to every matching substring in localized text.
public struct TextHighlight {
    let value: String
    let color: Color
    let font: Font?

    public init(_ value: String, color: Color, font: Font? = nil) {
        self.value = value
        self.color = color
        self.font = font
    }
}

public extension Text {
    /// Creates localized text and applies attributes after localization.
    ///
    /// Matching after localization preserves translated word order and styles
    /// every occurrence of each requested substring.
    init(
        localized resource: LocalizedStringResource,
        highlighting highlights: TextHighlight...
    ) {
        self.init(eazyHighlightedAttributedString(localized: resource, highlights: highlights))
    }
}

func eazyHighlightedAttributedString(
    localized resource: LocalizedStringResource,
    highlights: [TextHighlight]
) -> AttributedString {
    var attributedText = AttributedString(localized: resource)

    for highlight in highlights where !highlight.value.isEmpty {
        var searchStart = attributedText.startIndex
        while searchStart < attributedText.endIndex,
              let range = attributedText[searchStart...].range(of: highlight.value) {
            attributedText[range].foregroundColor = highlight.color
            if let font = highlight.font {
                attributedText[range].font = font
            }
            searchStart = range.upperBound
        }
    }

    return attributedText
}
