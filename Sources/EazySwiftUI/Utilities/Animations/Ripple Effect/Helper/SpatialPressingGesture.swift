//
//  SpatialPressingGesture.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI

/// A UIKit-backed gesture recognizer that detects instantaneous spatial presses
/// and exposes their location to SwiftUI.
struct SpatialPressingGesture: UIGestureRecognizerRepresentable {

    /// Coordinator enabling simultaneous gesture recognition.
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @objc
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }

    /// Binding to the current press location.
    @Binding var location: CGPoint?

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func makeUIGestureRecognizer(
        context: Context
    ) -> UILongPressGestureRecognizer {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = 0
        recognizer.delegate = context.coordinator
        return recognizer
    }

    func handleUIGestureRecognizerAction(
        _ recognizer: UIGestureRecognizerType,
        context: Context
    ) {
        switch recognizer.state {
        case .began:
            location = context.converter.localLocation
        case .ended, .cancelled, .failed:
            location = nil
        default:
            break
        }
    }
}
