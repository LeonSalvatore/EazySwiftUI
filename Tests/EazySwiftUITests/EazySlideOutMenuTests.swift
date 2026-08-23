import SwiftUI
import Testing
@testable import EazySwiftUI

@Suite("Slide-out menu geometry")
struct EazySlideOutMenuTests {
    @Test
    func fractionalAndFixedWidthsAreClampedToTheContainer() {
        #expect(
            EazySlideOutMenuGeometry.menuWidth(
                containerWidth: 400,
                specification: .fraction(0.6),
                minimumVisibleContentWidth: 44
            ) == 240
        )
        #expect(
            EazySlideOutMenuGeometry.menuWidth(
                containerWidth: 400,
                specification: .fraction(1.5),
                minimumVisibleContentWidth: 44
            ) == 356
        )
        #expect(
            EazySlideOutMenuGeometry.menuWidth(
                containerWidth: 400,
                specification: .fixed(500),
                minimumVisibleContentWidth: 44
            ) == 356
        )
        #expect(
            EazySlideOutMenuGeometry.menuWidth(
                containerWidth: 400,
                specification: .fraction(1),
                minimumVisibleContentWidth: 0
            ) == 400
        )
        #expect(
            EazySlideOutMenuGeometry.menuWidth(
                containerWidth: 400,
                specification: .fixed(-20),
                minimumVisibleContentWidth: 44
            ) == 0
        )
        #expect(
            EazySlideOutMenuGeometry.menuWidth(
                containerWidth: 40,
                specification: .fixed(20),
                minimumVisibleContentWidth: 44
            ) == 0
        )
    }

    @Test
    func progressAndScaleStayInsideTheirValidRanges() {
        #expect(EazySlideOutMenuGeometry.progress(offset: -20, menuWidth: 200) == 0)
        #expect(EazySlideOutMenuGeometry.progress(offset: 50, menuWidth: 200) == 0.25)
        #expect(EazySlideOutMenuGeometry.progress(offset: 300, menuWidth: 200) == 1)
        #expect(EazySlideOutMenuGeometry.progress(offset: 10, menuWidth: 0) == 0)

        #expect(
            EazySlideOutMenuGeometry.menuScale(
                progress: 0.5,
                minimumScale: 0.9
            ) == 0.95
        )
        #expect(
            EazySlideOutMenuGeometry.menuScale(
                progress: 2,
                minimumScale: -1
            ) == 1
        )
    }

    @Test
    func projectedMotionSettlesAroundTheHalfwayPoint() {
        #expect(
            !EazySlideOutMenuGeometry.shouldExpand(
                offset: 99,
                projectedVelocity: 0,
                menuWidth: 200
            )
        )
        #expect(
            EazySlideOutMenuGeometry.shouldExpand(
                offset: 99,
                projectedVelocity: 2,
                menuWidth: 200
            )
        )
        #expect(
            !EazySlideOutMenuGeometry.shouldExpand(
                offset: 199,
                projectedVelocity: -100,
                menuWidth: 200
            )
        )
    }

    @Test
    func resizingPreservesInteractiveProgressAndSettledState() {
        #expect(
            EazySlideOutMenuGeometry.resizedOffset(
                offset: 100,
                oldMenuWidth: 200,
                newMenuWidth: 300,
                isExpanded: false
            ) == 150
        )
        #expect(
            EazySlideOutMenuGeometry.resizedOffset(
                offset: 100,
                oldMenuWidth: 200,
                newMenuWidth: 300,
                isExpanded: true
            ) == 300
        )
        #expect(
            EazySlideOutMenuGeometry.resizedOffset(
                offset: 0,
                oldMenuWidth: 0,
                newMenuWidth: 300,
                isExpanded: false
            ) == 0
        )
    }

    @Test
    func revealDirectionSupportsBothEdgesAndLayoutDirections() {
        #expect(
            EazySlideOutMenuGeometry.revealDirection(
                edge: .leading,
                layoutDirection: .leftToRight
            ) == 1
        )
        #expect(
            EazySlideOutMenuGeometry.revealDirection(
                edge: .trailing,
                layoutDirection: .leftToRight
            ) == -1
        )
        #expect(
            EazySlideOutMenuGeometry.revealDirection(
                edge: .leading,
                layoutDirection: .rightToLeft
            ) == -1
        )
        #expect(
            EazySlideOutMenuGeometry.revealDirection(
                edge: .trailing,
                layoutDirection: .rightToLeft
            ) == 1
        )
    }

    @Test
    func panPolicyRequiresHorizontalMotionTowardAClosedMenu() {
        #expect(
            EazySlideOutMenuGeometry.shouldBeginPan(
                horizontalVelocity: 100,
                verticalVelocity: 20,
                isExpanded: false,
                edge: .leading,
                layoutDirection: .leftToRight
            )
        )
        #expect(
            !EazySlideOutMenuGeometry.shouldBeginPan(
                horizontalVelocity: -100,
                verticalVelocity: 20,
                isExpanded: false,
                edge: .leading,
                layoutDirection: .leftToRight
            )
        )
        #expect(
            EazySlideOutMenuGeometry.shouldBeginPan(
                horizontalVelocity: -100,
                verticalVelocity: 20,
                isExpanded: true,
                edge: .leading,
                layoutDirection: .leftToRight
            )
        )
        #expect(
            !EazySlideOutMenuGeometry.shouldBeginPan(
                horizontalVelocity: 20,
                verticalVelocity: 100,
                isExpanded: true,
                edge: .leading,
                layoutDirection: .leftToRight
            )
        )
        #expect(
            EazySlideOutMenuGeometry.shouldBeginPan(
                horizontalVelocity: -100,
                verticalVelocity: 20,
                isExpanded: false,
                edge: .trailing,
                layoutDirection: .leftToRight
            )
        )
        #expect(
            EazySlideOutMenuGeometry.shouldBeginPan(
                horizontalVelocity: -100,
                verticalVelocity: 20,
                isExpanded: false,
                edge: .leading,
                layoutDirection: .rightToLeft
            )
        )
        #expect(
            EazySlideOutMenuGeometry.shouldBeginPan(
                horizontalVelocity: 100,
                verticalVelocity: 20,
                isExpanded: false,
                edge: .trailing,
                layoutDirection: .rightToLeft
            )
        )
    }

    @Test
    func scrollPolicyUsesThePhysicalRevealDirection() {
        #expect(
            EazySlideOutMenuGeometry.hasRoomToScrollTowardMenu(
                contentOffset: 40,
                minimumOffset: 0,
                maximumOffset: 100,
                revealDirection: 1
            )
        )
        #expect(
            !EazySlideOutMenuGeometry.hasRoomToScrollTowardMenu(
                contentOffset: 0,
                minimumOffset: 0,
                maximumOffset: 100,
                revealDirection: 1
            )
        )
        #expect(
            EazySlideOutMenuGeometry.hasRoomToScrollTowardMenu(
                contentOffset: 40,
                minimumOffset: 0,
                maximumOffset: 100,
                revealDirection: -1
            )
        )
        #expect(
            !EazySlideOutMenuGeometry.hasRoomToScrollTowardMenu(
                contentOffset: 100,
                minimumOffset: 0,
                maximumOffset: 100,
                revealDirection: -1
            )
        )
    }
}
