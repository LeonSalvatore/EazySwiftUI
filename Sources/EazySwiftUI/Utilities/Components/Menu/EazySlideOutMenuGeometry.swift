import SwiftUI

enum EazySlideOutMenuGeometry {
    static let velocityDamping: CGFloat = 5
    static let backSwipeEdgeWidth: CGFloat = 30

    static func menuWidth(
        containerWidth: CGFloat,
        specification: EazySlideOutMenuWidth,
        minimumVisibleContentWidth: CGFloat
    ) -> CGFloat {
        guard containerWidth.isFinite, containerWidth > 0 else { return 0 }

        let availableMenuWidth = max(
            containerWidth - finiteNonnegative(minimumVisibleContentWidth),
            0
        )

        let requestedWidth = switch specification {
        case .fraction(let fraction):
            containerWidth * unitValue(fraction)
        case .fixed(let width):
            finiteNonnegative(width)
        }

        return min(requestedWidth, availableMenuWidth)
    }

    static func progress(offset: CGFloat, menuWidth: CGFloat) -> CGFloat {
        guard menuWidth.isFinite, menuWidth > 0 else { return 0 }
        return unitValue(offset / menuWidth)
    }

    static func menuScale(progress: CGFloat, minimumScale: CGFloat) -> CGFloat {
        let resolvedProgress = unitValue(progress)
        let resolvedMinimum = unitValue(minimumScale)
        return resolvedMinimum + ((1 - resolvedMinimum) * resolvedProgress)
    }

    static func shouldExpand(
        offset: CGFloat,
        projectedVelocity: CGFloat,
        menuWidth: CGFloat
    ) -> Bool {
        guard menuWidth.isFinite, menuWidth > 0 else { return false }
        return offset + projectedVelocity > menuWidth / 2
    }

    static func resizedOffset(
        offset: CGFloat,
        oldMenuWidth: CGFloat,
        newMenuWidth: CGFloat,
        isExpanded: Bool
    ) -> CGFloat {
        let resolvedNewWidth = finiteNonnegative(newMenuWidth)
        if isExpanded {
            return resolvedNewWidth
        }

        guard oldMenuWidth.isFinite, oldMenuWidth > 0, offset > 0 else {
            return 0
        }

        return resolvedNewWidth * progress(offset: offset, menuWidth: oldMenuWidth)
    }

    static func revealDirection(
        edge: HorizontalEdge,
        layoutDirection: LayoutDirection
    ) -> CGFloat {
        switch (edge, layoutDirection) {
        case (.leading, .leftToRight), (.trailing, .rightToLeft):
            1
        case (.leading, .rightToLeft), (.trailing, .leftToRight):
            -1
        @unknown default:
            1
        }
    }

    static func normalizedHorizontalValue(
        _ value: CGFloat,
        edge: HorizontalEdge,
        layoutDirection: LayoutDirection
    ) -> CGFloat {
        value * revealDirection(edge: edge, layoutDirection: layoutDirection)
    }

    static func shouldBeginPan(
        horizontalVelocity: CGFloat,
        verticalVelocity: CGFloat,
        isExpanded: Bool,
        edge: HorizontalEdge,
        layoutDirection: LayoutDirection
    ) -> Bool {
        guard abs(horizontalVelocity) > abs(verticalVelocity) else { return false }
        let normalizedVelocity = normalizedHorizontalValue(
            horizontalVelocity,
            edge: edge,
            layoutDirection: layoutDirection
        )
        return normalizedVelocity > 0 || isExpanded
    }

    static func hasRoomToScrollTowardMenu(
        contentOffset: CGFloat,
        minimumOffset: CGFloat,
        maximumOffset: CGFloat,
        revealDirection: CGFloat
    ) -> Bool {
        if revealDirection > 0 {
            contentOffset > minimumOffset
        } else {
            contentOffset < maximumOffset
        }
    }

    static func unitValue(_ value: CGFloat) -> CGFloat {
        guard value.isFinite else { return 0 }
        return min(max(value, 0), 1)
    }

    static func finiteNonnegative(_ value: CGFloat) -> CGFloat {
        guard value.isFinite else { return 0 }
        return max(value, 0)
    }

    static func finiteNonnegative(_ value: Double) -> Double {
        guard value.isFinite else { return 0 }
        return max(value, 0)
    }
}
