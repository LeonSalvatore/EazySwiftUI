//
//  EazyFlowLayout.swift
//  EazySwiftUI
//

import SwiftUI

/// A layout that places children in horizontal rows and wraps them when they
/// no longer fit the proposed width.
public struct EazyFlowLayout: Layout {
    /// Alignment applied independently to every row.
    public enum RowAlignment: Sendable {
        case leading
        case center
        case trailing
    }

    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let alignment: RowAlignment

    public init(
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        alignment: RowAlignment = .leading
    ) {
        self.horizontalSpacing = max(0, horizontalSpacing)
        self.verticalSpacing = max(0, verticalSpacing)
        self.alignment = alignment
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let proposedWidth = proposal.width
        let availableWidth = proposedWidth ?? naturalWidth(for: sizes)
        let rows = EazyFlowLayoutEngine.rows(
            for: sizes,
            maxWidth: availableWidth,
            horizontalSpacing: horizontalSpacing
        )

        let contentWidth = rows.map(\.width).max() ?? 0
        let height = rows.reduce(0) { $0 + $1.height }
            + verticalSpacing * CGFloat(max(rows.count - 1, 0))

        return CGSize(
            width: proposedWidth.map { max(0, $0) } ?? contentWidth,
            height: height
        )
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let rows = EazyFlowLayoutEngine.rows(
            for: sizes,
            maxWidth: bounds.width,
            horizontalSpacing: horizontalSpacing
        )

        var y = bounds.minY
        for row in rows {
            var x = bounds.minX + xOffset(for: row.width, availableWidth: bounds.width)
            for index in row.indices {
                let size = sizes[index]
                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(size)
                )
                x += size.width + horizontalSpacing
            }
            y += row.height + verticalSpacing
        }
    }

    private func naturalWidth(for sizes: [CGSize]) -> CGFloat {
        sizes.reduce(0) { $0 + $1.width }
            + horizontalSpacing * CGFloat(max(sizes.count - 1, 0))
    }

    private func xOffset(for rowWidth: CGFloat, availableWidth: CGFloat) -> CGFloat {
        let remaining = max(availableWidth - rowWidth, 0)
        switch alignment {
        case .leading: return 0
        case .center: return remaining / 2
        case .trailing: return remaining
        }
    }
}

struct EazyFlowLayoutEngine {
    struct Row: Equatable {
        let indices: Range<Int>
        let width: CGFloat
        let height: CGFloat
    }

    static func rows(
        for sizes: [CGSize],
        maxWidth: CGFloat,
        horizontalSpacing: CGFloat
    ) -> [Row] {
        guard !sizes.isEmpty else { return [] }

        let finiteWidth = maxWidth.isFinite ? max(maxWidth, 0) : .greatestFiniteMagnitude
        var rows: [Row] = []
        var start = 0
        var width: CGFloat = 0
        var height: CGFloat = 0

        for (index, size) in sizes.enumerated() {
            let spacing = index == start ? 0 : horizontalSpacing
            let proposedRowWidth = width + spacing + size.width

            if index > start, proposedRowWidth > finiteWidth {
                rows.append(Row(indices: start..<index, width: width, height: height))
                start = index
                width = size.width
                height = size.height
            } else {
                width = proposedRowWidth
                height = max(height, size.height)
            }
        }

        rows.append(Row(indices: start..<sizes.count, width: width, height: height))
        return rows
    }
}
