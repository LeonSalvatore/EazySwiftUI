import SwiftUI

/// Size, timing, and appearance settings for ``EazyControlRail``.
public struct EazyControlRailConfiguration {
    public let itemWidth: CGFloat
    public let itemHeight: CGFloat
    /// The vertical distance between neighbouring items on the wheel.
    public let itemSpacing: CGFloat
    public let visibleItemCount: Int
    /// How long the selected item's title stays visible in the expanded pill.
    public let selectionDisplayDuration: Duration
    public let selectionTint: Color
    public let selectionPillWidth: CGFloat
    /// The expanded pill's height as a multiple of `itemHeight`.
    public let expandedHeightMultiple: CGFloat
    /// The gap kept around the expanded pill.
    public let expandedSpacing: CGFloat
    /// The horizontal depth of the notch the rail sits in.
    public let notchDepth: CGFloat

    /// Creates rail settings. Values are clamped to usable ranges.
    public init(
        itemWidth: CGFloat = 42,
        itemHeight: CGFloat = 32,
        itemSpacing: CGFloat? = nil,
        visibleItemCount: Int = 5,
        selectionDisplayDuration: Duration = .seconds(2),
        selectionTint: Color = .accentColor,
        selectionPillWidth: CGFloat? = nil,
        expandedHeightMultiple: CGFloat = 2.2,
        expandedSpacing: CGFloat = 8,
        notchDepth: CGFloat? = nil
    ) {
        self.itemWidth = max(itemWidth, 1)
        self.itemHeight = max(itemHeight, 1)
        self.itemSpacing = max(itemSpacing ?? itemHeight - 2, 1)
        self.visibleItemCount = max(visibleItemCount, 1)
        self.selectionDisplayDuration = selectionDisplayDuration
        self.selectionTint = selectionTint
        self.selectionPillWidth = min(max(selectionPillWidth ?? itemWidth, 1), max(itemWidth, 1))
        self.expandedHeightMultiple = max(expandedHeightMultiple, 1)
        self.expandedSpacing = max(expandedSpacing, 0)
        self.notchDepth = min(max(notchDepth ?? itemWidth * 0.825, 1), max(itemWidth, 1))
    }

    public var railHeight: CGFloat { itemHeight * CGFloat(visibleItemCount) }
    public var centerY: CGFloat { railHeight / 2 }
    public var expandedHeight: CGFloat { itemHeight * expandedHeightMultiple }
    public var shoulderHeight: CGFloat {
        min(itemHeight + 2 * expandedSpacing, railHeight / 3)
    }
}
