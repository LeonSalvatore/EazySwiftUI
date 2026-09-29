import SwiftUI

/// A rounded rectangle with a smooth concave notch on the rail's edge.
/// The container supplies the actual vertical center for any placement.
///
/// `Animatable`: the notch depth, height, center, and shoulder follow the rail.
/// `cornerRadius` remains static.
public struct EazyNotchedCardShape: Shape, Animatable {

    public var cornerRadius: CGFloat
    /// The horizontal depth of the cutout.
    public var notchDepth: CGFloat
    /// The cutout's vertical center as a fraction of the shape's height.
    public var notchCenterYFraction: CGFloat
    /// The cutout's total height, including its shoulders.
    public var notchHeight: CGFloat
    /// The height of each curved shoulder, bounded to a third of the notch.
    public var shoulderHeight: CGFloat
    /// The rail placement. Trailing placements mirror the cutout to the trailing edge.
    public var placement: EazyControlRailPlacement

    /// Creates a notched card shape.
    public init(
        cornerRadius: CGFloat,
        notchDepth: CGFloat,
        notchCenterYFraction: CGFloat,
        notchHeight: CGFloat,
        shoulderHeight: CGFloat,
        placement: EazyControlRailPlacement = .topLeading
    ) {
        self.cornerRadius = cornerRadius
        self.notchDepth = notchDepth
        self.notchCenterYFraction = notchCenterYFraction
        self.notchHeight = notchHeight
        self.shoulderHeight = shoulderHeight
        self.placement = placement
    }

    public var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>> {
        get { AnimatablePair(notchDepth, AnimatablePair(notchHeight, AnimatablePair(notchCenterYFraction, shoulderHeight))) }
        set {
            notchDepth = newValue.first
            notchHeight = newValue.second.first
            notchCenterYFraction = newValue.second.second.first
            shoulderHeight = newValue.second.second.second
        }
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let r = min(cornerRadius, min(rect.width, rect.height) / 2)
        let nd = min(notchDepth, rect.width / 2)
        guard rect.height > 2 * r + 2, nd > 0, notchHeight > 0 else {
            return Path(roundedRect: rect, cornerRadius: r)
        }

        let centerY = rect.minY + rect.height * notchCenterYFraction
        let halfNotch = max(0, notchHeight / 2)
        let notchTop = max(rect.minY + r + 1, centerY - halfNotch)
        let notchBottom = min(rect.maxY - r - 1, centerY + halfNotch)
        // Use the rail's calculated shoulder, bounded by the available notch.
        let upperShoulder = max(0, min(shoulderHeight, (notchBottom - notchTop) / 3))
        let lowerShoulder = max(0, min(shoulderHeight, (notchBottom - notchTop) / 3))

        path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))

        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))

        // Top-right corner
        path.addArc(
            center: CGPoint(x: rect.maxX - r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))

        // Bottom-right corner
        path.addArc(
            center: CGPoint(x: rect.maxX - r, y: rect.maxY - r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))

        // Bottom-left corner
        path.addArc(
            center: CGPoint(x: rect.minX + r, y: rect.maxY - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // Up the left edge to the bottom of the notch
        path.addLine(to: CGPoint(x: rect.minX, y: notchBottom))

        // The lower shoulder returns from the inset wall to the card edge.
        path.addCurve(
            to: CGPoint(x: rect.minX + nd, y: notchBottom - lowerShoulder),
            control1: CGPoint(x: rect.minX, y: notchBottom - lowerShoulder * 0.683),
            control2: CGPoint(x: rect.minX + nd, y: notchBottom - lowerShoulder * 0.314)
        )

        // The long vertical wall gives the rail room to scroll inside the cutout.
        path.addLine(to: CGPoint(x: rect.minX + nd, y: notchTop + upperShoulder))

        // The upper shoulder rounds back to the outer edge.
        path.addCurve(
            to: CGPoint(x: rect.minX, y: notchTop),
            control1: CGPoint(x: rect.minX + nd, y: notchTop + upperShoulder * 0.326),
            control2: CGPoint(x: rect.minX, y: notchTop + upperShoulder * 0.636)
        )

        // Up to the top-left corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))

        // Top-left corner
        path.addArc(
            center: CGPoint(x: rect.minX + r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.closeSubpath()
        if placement.isTrailing {
            return path.applying(CGAffineTransform(
                a: -1, b: 0, c: 0, d: 1, tx: rect.minX + rect.maxX, ty: 0
            ))
        }
        return path
    }
}
