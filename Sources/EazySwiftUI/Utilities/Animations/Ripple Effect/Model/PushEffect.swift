//
//  PushEffect.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//


import SwiftUI

/// A view modifier that applies a subtle “push” scale animation whenever a trigger value changes.
///
/// `PushEffect` is useful for providing tactile feedback on interactions such as button taps
/// or selection changes. The animation uses keyframe-based springs to briefly compress and
/// then restore the view’s scale.
///
/// ## Example
/// ```swift
/// Text("Save")
///     .modifier(PushEffect(trigger: isPressed))
/// ```
///
/// - Parameter trigger: A value whose change triggers the animation.
struct PushEffect<T: Equatable>: ViewModifier {

    /// A value that triggers the push animation when it changes.
    var trigger: T

    func body(content: Content) -> some View {
        content.keyframeAnimator(
            initialValue: 1.0,
            trigger: trigger
        ) { view, value in
            view.visualEffect { view, _ in
                view.scaleEffect(value)
            }
        } keyframes: { _ in
            SpringKeyframe(0.95, duration: 0.2, spring: .snappy)
            SpringKeyframe(1.0, duration: 0.2, spring: .bouncy)
        }
    }
}