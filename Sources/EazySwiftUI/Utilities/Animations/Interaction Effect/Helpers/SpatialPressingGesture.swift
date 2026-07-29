//
//  SpatialPressingGesture.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI

/// The current state of a spatial press gesture.
public enum PressingPhase: Equatable, Sendable {
    case began(CGPoint)
    case changed(CGPoint)
    case ended
    case cancelled
}

#if os(iOS)

/// A UIKit-backed gesture recognizer that detects spatial presses and exposes
/// their location to SwiftUI.
public struct SpatialPressingGesture: UIGestureRecognizerRepresentable {

    /// Binding to the current press location.
    @Binding private var location: CGPoint?

    /// Binding to the current press phase.
    @Binding private var phase: PressingPhase?

    private let minimumDuration: TimeInterval

    public init(
        location: Binding<CGPoint?>,
        minimumDuration: TimeInterval = 0
    ) {
        self._location = location
        self._phase = .constant(nil)
        self.minimumDuration = minimumDuration
    }

    public init(
        phase: Binding<PressingPhase?>,
        minimumDuration: TimeInterval = 0
    ) {
        self._location = .constant(nil)
        self._phase = phase
        self.minimumDuration = minimumDuration
    }

    /// Coordinator enabling simultaneous gesture recognition.
    public final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @objc
        public func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }

    public func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    public func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = minimumDuration
        recognizer.delegate = context.coordinator
        return recognizer
    }

    public func handleUIGestureRecognizerAction(
        _ recognizer: UIGestureRecognizerType,
        context: Context
    ) {
        updatePressState(for: recognizer.state, location: context.converter.localLocation)
    }

    private func updatePressState(for state: UIGestureRecognizer.State, location point: CGPoint) {
        switch state {
        case .began:
            location = point
            phase = .began(point)
        case .changed:
            location = point
            phase = .changed(point)
        case .ended:
            location = nil
            phase = .ended
        case .cancelled, .failed:
            location = nil
            phase = .cancelled
        default:
            break
        }
    }
}

#elseif os(macOS)

/// An AppKit-backed gesture recognizer that detects spatial presses and exposes
/// their location to SwiftUI.
@available(macOS 26.0, *)
public struct SpatialPressingGesture: NSGestureRecognizerRepresentable {

    /// Binding to the current press location.
    @Binding private var location: CGPoint?

    /// Binding to the current press phase.
    @Binding private var phase: PressingPhase?

    private let minimumDuration: TimeInterval

    public init(
        location: Binding<CGPoint?>,
        minimumDuration: TimeInterval = 0
    ) {
        self._location = location
        self._phase = .constant(nil)
        self.minimumDuration = minimumDuration
    }

    public init(
        phase: Binding<PressingPhase?>,
        minimumDuration: TimeInterval = 0
    ) {
        self._location = .constant(nil)
        self._phase = phase
        self.minimumDuration = minimumDuration
    }

    /// Coordinator enabling simultaneous gesture recognition.
    public final class Coordinator: NSObject, NSGestureRecognizerDelegate {
        public func gestureRecognizer(
            _ gestureRecognizer: NSGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: NSGestureRecognizer
        ) -> Bool {
            true
        }
    }

    public func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    public func makeNSGestureRecognizer(context: Context) -> NSPressGestureRecognizer {
        let recognizer = NSPressGestureRecognizer()
        recognizer.minimumPressDuration = minimumDuration
        recognizer.delegate = context.coordinator
        return recognizer
    }

    public func handleNSGestureRecognizerAction(
        _ recognizer: NSGestureRecognizerType,
        context: Context
    ) {
        updatePressState(for: recognizer.state, location: context.converter.localLocation)
    }

    private func updatePressState(for state: NSGestureRecognizer.State, location point: CGPoint) {
        switch state {
        case .began:
            location = point
            phase = .began(point)
        case .changed:
            location = point
            phase = .changed(point)
        case .ended, .recognized:
            location = nil
            phase = .ended
        case .cancelled, .failed:
            location = nil
            phase = .cancelled
        default:
            break
        }
    }
}

#endif
