import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct EazySlideOutMenuPan: ViewModifier {
    struct Sample {
        let translation: CGFloat
        let velocity: CGFloat
        let hasEnded: Bool
    }

    let isEnabled: () -> Bool
    let isExpanded: () -> Bool
    let edge: HorizontalEdge
    let layoutDirection: LayoutDirection
    let handle: (Sample) -> Void

#if !canImport(UIKit)
    @State private var fallbackPanDidBegin = false
#endif

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled() {
#if canImport(UIKit)
            content.gesture(
                Recognizer(
                    isEnabled: isEnabled,
                    isExpanded: isExpanded,
                    edge: edge,
                    layoutDirection: layoutDirection,
                    handle: handle
                )
            )
#else
            content.gesture(fallbackGesture)
#endif
        } else {
            content
        }
    }
}

#if canImport(UIKit)

private extension EazySlideOutMenuPan {
    struct Recognizer: UIGestureRecognizerRepresentable {
        let isEnabled: () -> Bool
        let isExpanded: () -> Bool
        let edge: HorizontalEdge
        let layoutDirection: LayoutDirection
        let handle: (Sample) -> Void

        func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
            let gesture = UIPanGestureRecognizer()
            gesture.delegate = context.coordinator
            gesture.maximumNumberOfTouches = 1
            return gesture
        }

        func updateUIGestureRecognizer(
            _ recognizer: UIGestureRecognizer,
            context: Context
        ) {
            context.coordinator.parent = self
        }

        func handleUIGestureRecognizerAction(
            _ recognizer: UIPanGestureRecognizer,
            context: Context
        ) {
            let parent = context.coordinator.parent
            guard parent.isEnabled() else { return }

            let state = recognizer.state
            let translation = EazySlideOutMenuGeometry.normalizedHorizontalValue(
                recognizer.translation(in: recognizer.view).x,
                edge: parent.edge,
                layoutDirection: parent.layoutDirection
            )
            let velocity = EazySlideOutMenuGeometry.normalizedHorizontalValue(
                recognizer.velocity(in: recognizer.view).x,
                edge: parent.edge,
                layoutDirection: parent.layoutDirection
            ) / EazySlideOutMenuGeometry.velocityDamping

            parent.handle(
                Sample(
                    translation: translation,
                    velocity: velocity,
                    hasEnded: state != .began && state != .changed
                )
            )
        }

        func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
            Coordinator(parent: self)
        }

        final class Coordinator: NSObject, UIGestureRecognizerDelegate {
            var parent: Recognizer

            init(parent: Recognizer) {
                self.parent = parent
            }

            func gestureRecognizerShouldBegin(
                _ gestureRecognizer: UIGestureRecognizer
            ) -> Bool {
                guard parent.isEnabled(),
                      let pan = gestureRecognizer as? UIPanGestureRecognizer
                else { return false }

                let velocity = pan.velocity(in: gestureRecognizer.view)
                return EazySlideOutMenuGeometry.shouldBeginPan(
                    horizontalVelocity: velocity.x,
                    verticalVelocity: velocity.y,
                    isExpanded: parent.isExpanded(),
                    edge: parent.edge,
                    layoutDirection: parent.layoutDirection
                )
            }

            func gestureRecognizer(
                _ gestureRecognizer: UIGestureRecognizer,
                shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
            ) -> Bool {
                guard !parent.isExpanded() else { return false }

                if otherGestureRecognizer is UIScreenEdgePanGestureRecognizer {
                    return parent.edge == .leading
                        && startedAtBackSwipeEdge(gestureRecognizer)
                }

                guard let scrollView = horizontalScroller(otherGestureRecognizer)
                else { return false }

                return hasRoomToScrollTowardMenu(scrollView)
            }

            func gestureRecognizer(
                _ gestureRecognizer: UIGestureRecognizer,
                shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
            ) -> Bool {
                guard let scrollView = horizontalScroller(otherGestureRecognizer)
                else { return false }

                return parent.isExpanded() || !hasRoomToScrollTowardMenu(scrollView)
            }

            private func startedAtBackSwipeEdge(
                _ gestureRecognizer: UIGestureRecognizer
            ) -> Bool {
                guard let view = gestureRecognizer.view,
                      let window = view.window
                else { return false }

                let x = gestureRecognizer.location(in: window).x
                if parent.layoutDirection == .rightToLeft {
                    return x >= window.bounds.width
                        - EazySlideOutMenuGeometry.backSwipeEdgeWidth
                }
                return x <= EazySlideOutMenuGeometry.backSwipeEdgeWidth
            }

            private func horizontalScroller(
                _ otherGestureRecognizer: UIGestureRecognizer
            ) -> UIScrollView? {
                guard let scrollView = otherGestureRecognizer.view as? UIScrollView,
                      scrollView.isScrollEnabled,
                      scrollView.contentSize.width > scrollView.bounds.width
                else { return nil }

                return scrollView
            }

            private func hasRoomToScrollTowardMenu(_ scrollView: UIScrollView) -> Bool {
                let minimumOffset = -scrollView.adjustedContentInset.left
                let maximumOffset = max(
                    minimumOffset,
                    scrollView.contentSize.width
                        - scrollView.bounds.width
                        + scrollView.adjustedContentInset.right
                )
                let direction = EazySlideOutMenuGeometry.revealDirection(
                    edge: parent.edge,
                    layoutDirection: parent.layoutDirection
                )

                return EazySlideOutMenuGeometry.hasRoomToScrollTowardMenu(
                    contentOffset: scrollView.contentOffset.x,
                    minimumOffset: minimumOffset,
                    maximumOffset: maximumOffset,
                    revealDirection: direction
                )
            }
        }
    }
}

#else

private extension EazySlideOutMenuPan {
    var fallbackGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                guard isEnabled() else {
                    fallbackPanDidBegin = false
                    return
                }

                if !fallbackPanDidBegin {
                    guard EazySlideOutMenuGeometry.shouldBeginPan(
                        horizontalVelocity: value.translation.width,
                        verticalVelocity: value.translation.height,
                        isExpanded: isExpanded(),
                        edge: edge,
                        layoutDirection: layoutDirection
                    ) else { return }
                    fallbackPanDidBegin = true
                }

                handle(
                    Sample(
                        translation: normalized(value.translation.width),
                        velocity: 0,
                        hasEnded: false
                    )
                )
            }
            .onEnded { value in
                let didBegin = fallbackPanDidBegin
                fallbackPanDidBegin = false
                guard isEnabled(), didBegin else { return }

                let translation = normalized(value.translation.width)
                let projectedTranslation = normalized(
                    value.predictedEndTranslation.width
                )
                handle(
                    Sample(
                        translation: translation,
                        velocity: projectedTranslation - translation,
                        hasEnded: true
                    )
                )
            }
    }

    func normalized(_ value: CGFloat) -> CGFloat {
        EazySlideOutMenuGeometry.normalizedHorizontalValue(
            value,
            edge: edge,
            layoutDirection: layoutDirection
        )
    }
}

#endif
