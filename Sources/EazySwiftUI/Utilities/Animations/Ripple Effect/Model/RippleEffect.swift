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
struct RippleEffect<T: Equatable>: ViewModifier {

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
            view.modifier(
                RippleModifier(
                    origin: origin,
                    elapsedTime: elapsedTime,
                    duration: duration
                )
            )
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }

    /// Total duration of the ripple animation.
    var duration: TimeInterval { 3 }
}

public extension View {

    /// Applies an interaction effect in response to user input.
    @ViewBuilder
    func interactionEffect<T: Equatable>(
        _ effect: InteractionEffect<T>
    ) -> some View {

        switch effect {

        case let .press(trigger):
            self.modifier(PushEffect(trigger: trigger))

        case let .ripple(origin, trigger):
            self.modifier(RippleEffect(at: origin, trigger: trigger))
        }
    }
}

/// Describes a visual interaction effect applied to a view.
public enum InteractionEffect<T: Equatable> {

    /// A subtle scale compression effect used for press feedback.
    case press(trigger: T)

    /// A ripple distortion originating from a specific point.
    case ripple(origin: CGPoint, trigger: T)

}

//enum InteractionEffect<T: Equatable> {
//    case press(trigger: T)
//    case ripple(origin: CGPoint, trigger: T)
//    case combined([InteractionEffect<T>])
//}


#Preview {
@Previewable @State var bar: Bool = false

    @Previewable @State var counter: Int = 0
    @Previewable @State var origin: CGPoint = .zero

    Group {
        Text("On Press Intercation")
        Image(systemName: "person.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .interactionEffect(.press(trigger: bar))
            .onTapGesture {
                bar.toggle()
            }

        Divider()

        Rectangle()
            .fill(Color.blue)
            .frame(width: 200, height: 200)
            .onPressingChanged { isPressed in
                if let isPressed {
                    origin = origin
                    counter += 1
                }
            }
            .interactionEffect(.ripple(origin: origin, trigger: counter))
    }
}
