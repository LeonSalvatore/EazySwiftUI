//
//  RippleEffect.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//


import SwiftUI

/// A view modifier that produces a ripple animation originating from a specific point
/// whenever a trigger value changes.
///
/// The ripple propagates outward from the provided origin and fades naturally over time,
/// making it ideal for spatial touch feedback or press interactions.
///
/// ## Example
/// ```swift
/// Rectangle()
///     .modifier(RippleEffect(at: touchLocation, trigger: isPressed))
/// ```
///
/// - Parameters:
///   - origin: The point from which the ripple originates, in local coordinates.
///   - trigger: A value whose change triggers the ripple animation.
struct RippleEffect<T: Equatable>: ViewModifier where T: Sendable {

    /// The origin point of the ripple effect.
    var origin: CGPoint

    /// A value that triggers the ripple animation when it changes.
    var trigger: T

    init(at origin: CGPoint, trigger: T) {
        self.origin = origin
        self.trigger = trigger
    }

    func body(content: Content) -> some View {
        let origin = origin
        let duration = duration

        content.keyframeAnimator(
            initialValue: 0,
            trigger: trigger
        ) { view, elapsedTime in
            let mod =  RippleModifier(
                origin: origin,
                elapsedTime: elapsedTime,
                duration: duration
            )
        return  view.modifier(mod)

        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }

    /// Total duration of the ripple animation.
    var duration: TimeInterval { 3 }
}



#Preview("Ripple Effect") {

    @Previewable @State var counter: Int = 0
    @Previewable @State var origin: CGPoint = .zero

    Text("Ripple Effect")
    Rectangle()
        .fill(Color.blue)
        .frame(width: 200, height: 200)
        .onPressingChanged { isPressed in
            if let isPressed {
                origin = isPressed
                counter += 1
            }
        }
        .interactionEffect(.ripple(origin: origin, trigger: counter))

}
