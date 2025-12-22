//
//  SpatialPressingGestureModifier.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI

/// A view modifier that tracks spatial press gestures and reports their location.
struct SpatialPressingGestureModifier: ViewModifier {

    /// Callback invoked when the pressing location changes.
    var onPressingChanged: (CGPoint?) -> Void

    /// Current press location in local coordinates.
    @State var currentLocation: CGPoint?

    init(action: @escaping (CGPoint?) -> Void) {
        self.onPressingChanged = action
    }

    func body(content: Content) -> some View {
        let gesture = SpatialPressingGesture(location: $currentLocation)

        content
            .gesture(gesture)
            .onChange(of: currentLocation, initial: false) { _, location in
                onPressingChanged(location)
            }
    }
}
