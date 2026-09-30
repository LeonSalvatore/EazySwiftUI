import SwiftUI
import Testing
@testable import EazySwiftUI

@Suite("Notched rail")
struct EazyNotchedRailTests {
    @Test
    func placementCentersInsideTheNotchOnItsEdge() {
        let size = CGSize(width: 400, height: 1000)

        let leading = EazyControlRailPlacement.topLeading.center(in: size, notchDepth: 36)
        #expect(leading.x == 18)
        #expect(abs(leading.y - 298) < 0.001)

        let trailing = EazyControlRailPlacement.bottomTrailing.center(in: size, notchDepth: 36)
        #expect(trailing.x == 382)
        #expect(abs(trailing.y - 702) < 0.001)
    }

    @Test
    func placementClampsToVerticalBounds() {
        let size = CGSize(width: 400, height: 1000)
        let center = EazyControlRailPlacement.topLeading.center(
            in: size,
            notchDepth: 36,
            verticalBounds: 400...600
        )
        #expect(center.y == 400)
    }

    @Test
    func placementRawValuesAreStable() {
        #expect(EazyControlRailPlacement.allCases.map(\.rawValue)
            == ["topLeading", "topTrailing", "bottomLeading", "bottomTrailing"])
    }

    @Test
    func expansionFitsExtentsProportionally() {
        let expansion = EazyControlRailExpansion(topExtent: 100, bottomExtent: 300)
        #expect(expansion.activeRailHeight == 400)
        #expect(expansion.notchCenterOffset == 100)

        let fitted = expansion.fittedExtents(maxHeight: 200)
        #expect(fitted.top == 50)
        #expect(fitted.bottom == 150)

        let unscaled = expansion.fittedExtents(maxHeight: 1000)
        #expect(unscaled.top == 100)
        #expect(unscaled.bottom == 300)
    }

    @Test
    func configurationClampsValues() {
        let configuration = EazyControlRailConfiguration(
            itemWidth: 40,
            itemHeight: 40,
            visibleItemCount: 0,
            selectionPillWidth: 100,
            expandedHeightMultiple: 0.5,
            expandedSpacing: -4
        )
        #expect(configuration.visibleItemCount == 1)
        #expect(configuration.selectionPillWidth == 40)
        #expect(configuration.expandedHeightMultiple == 1)
        #expect(configuration.expandedSpacing == 0)
        #expect(configuration.itemSpacing == 38)
        #expect(configuration.notchDepth == 33)
    }

    @Test
    func contentRegionIntersectsOnlyOverlappingFrames() {
        let region = EazyNotchedRailContentRegion(top: 100, bottom: 300, depth: 36, isTrailing: false)
        #expect(region.intersects(CGRect(x: 0, y: 250, width: 10, height: 100)))
        #expect(!region.intersects(CGRect(x: 0, y: 300, width: 10, height: 50)))
        #expect(!region.intersects(CGRect(x: 0, y: 0, width: 10, height: 100)))

        let empty = EazyNotchedRailContentRegion(top: 100, bottom: 100, depth: 36, isTrailing: false)
        #expect(!empty.intersects(CGRect(x: 0, y: 50, width: 10, height: 100)))
    }

    @Test
    func bottomOverlapOnlyCountsContentBelowTheBoundary() {
        #expect(eazyNotchedRailBottomOverlap(contentBottom: 800, bottomBoundary: 700) == 100)
        #expect(eazyNotchedRailBottomOverlap(contentBottom: 600, bottomBoundary: 700) == 0)
        #expect(eazyNotchedRailBottomOverlap(contentBottom: 800, bottomBoundary: nil) == 0)
    }

    @Test
    func emptyBottomBarReservesNoSpace() {
        let padding = EdgeInsets(top: 12, leading: 12, bottom: 8, trailing: 12)
        #expect(eazyNotchedRailBottomBarHeight(contentHeight: 0, padding: padding) == 0)
        #expect(eazyNotchedRailBottomBarHeight(contentHeight: 50, padding: padding) == 70)
    }

    @Test
    func shapeWithoutNotchIsARoundedRectangle() {
        let rect = CGRect(x: 0, y: 0, width: 300, height: 600)
        let shape = EazyNotchedCardShape(
            cornerRadius: 20,
            notchDepth: 36,
            notchCenterYFraction: 0.5,
            notchHeight: 0,
            shoulderHeight: 40
        )
        #expect(shape.path(in: rect) == Path(roundedRect: rect, cornerRadius: 20))
    }

    @Test
    func notchIsCutIntoTheRailEdge() {
        let rect = CGRect(x: 0, y: 0, width: 300, height: 600)
        let point = CGPoint(x: 10, y: 300)
        let mirrored = CGPoint(x: 290, y: 300)

        let leading = EazyNotchedCardShape(
            cornerRadius: 0,
            notchDepth: 36,
            notchCenterYFraction: 0.5,
            notchHeight: 200,
            shoulderHeight: 40
        ).path(in: rect)
        #expect(!leading.contains(point))
        #expect(leading.contains(mirrored))
        #expect(leading.boundingRect == rect)

        let trailing = EazyNotchedCardShape(
            cornerRadius: 0,
            notchDepth: 36,
            notchCenterYFraction: 0.5,
            notchHeight: 200,
            shoulderHeight: 40,
            placement: .topTrailing
        ).path(in: rect)
        #expect(trailing.contains(point))
        #expect(!trailing.contains(mirrored))
    }
}
