//
//  SpatialPressingGestureModifier.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI

#if os(iOS) || os(macOS)

/// A view modifier that tracks spatial press gestures and reports their location.
struct SpatialPressingGestureModifier: ViewModifier {

    /// Callback invoked when the pressing location changes.
    var onPressingChanged: (CGPoint?) -> Void

    /// The minimum time required before the press begins.
    var minimumDuration: TimeInterval

    /// Current press location in local coordinates.
    @State private var currentLocation: CGPoint?

    #if os(macOS)
    @State private var pendingLocation: CGPoint?
    @State private var activationTask: Task<Void, Never>?
    #endif

    init(
        minimumDuration: TimeInterval = 0,
        action: @escaping (CGPoint?) -> Void
    ) {
        self.minimumDuration = minimumDuration
        self.onPressingChanged = action
    }

    func body(content: Content) -> some View {
        #if os(iOS)
        let gesture = SpatialPressingGesture(
            location: $currentLocation,
            minimumDuration: minimumDuration
        )

        content
            .gesture(gesture)
            .onChange(of: currentLocation, initial: false) { _, location in
                onPressingChanged(location)
            }
        #elseif os(macOS)
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        updateMacPress(at: value.location)
                    }
                    .onEnded { _ in
                        endMacPress()
                    }
            )
            .onDisappear(perform: endMacPress)
        #endif
    }

    #if os(macOS)
    private func updateMacPress(at location: CGPoint) {
        pendingLocation = location

        if currentLocation != nil {
            currentLocation = location
            onPressingChanged(location)
            return
        }

        guard activationTask == nil else { return }
        guard minimumDuration > 0 else {
            currentLocation = location
            onPressingChanged(location)
            return
        }

        activationTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(minimumDuration))
            guard !Task.isCancelled, let pendingLocation else { return }
            currentLocation = pendingLocation
            onPressingChanged(pendingLocation)
            activationTask = nil
        }
    }

    private func endMacPress() {
        activationTask?.cancel()
        activationTask = nil
        pendingLocation = nil
        guard currentLocation != nil else { return }
        currentLocation = nil
        onPressingChanged(nil)
    }
    #endif
}

/// A view modifier that tracks spatial press gesture phases.
struct SpatialPressingPhaseModifier: ViewModifier {

    /// Callback invoked when the pressing phase changes.
    var onPhaseChanged: (PressingPhase) -> Void

    /// The minimum time required before the press begins.
    var minimumDuration: TimeInterval

    /// Current press phase.
    @State private var currentPhase: PressingPhase?

    #if os(macOS)
    @State private var pendingLocation: CGPoint?
    @State private var activationTask: Task<Void, Never>?
    #endif

    init(
        minimumDuration: TimeInterval = 0,
        action: @escaping (PressingPhase) -> Void
    ) {
        self.minimumDuration = minimumDuration
        self.onPhaseChanged = action
    }

    func body(content: Content) -> some View {
        #if os(iOS)
        let gesture = SpatialPressingGesture(
            phase: $currentPhase,
            minimumDuration: minimumDuration
        )

        content
            .gesture(gesture)
            .onChange(of: currentPhase, initial: false) { _, phase in
                guard let phase else { return }
                onPhaseChanged(phase)
            }
        #elseif os(macOS)
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        updateMacPress(at: value.location)
                    }
                    .onEnded { _ in
                        endMacPress(cancelled: false)
                    }
            )
            .onDisappear {
                endMacPress(cancelled: true)
            }
        #endif
    }

    #if os(macOS)
    private func updateMacPress(at location: CGPoint) {
        pendingLocation = location

        if currentPhase != nil {
            currentPhase = .changed(location)
            onPhaseChanged(.changed(location))
            return
        }

        guard activationTask == nil else { return }
        guard minimumDuration > 0 else {
            currentPhase = .began(location)
            onPhaseChanged(.began(location))
            return
        }

        activationTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(minimumDuration))
            guard !Task.isCancelled, let pendingLocation else { return }
            currentPhase = .began(pendingLocation)
            onPhaseChanged(.began(pendingLocation))
            activationTask = nil
        }
    }

    private func endMacPress(cancelled: Bool) {
        activationTask?.cancel()
        activationTask = nil
        pendingLocation = nil
        guard currentPhase != nil else { return }
        let finalPhase: PressingPhase = cancelled ? .cancelled : .ended
        currentPhase = nil
        onPhaseChanged(finalPhase)
    }
    #endif
}

#endif
