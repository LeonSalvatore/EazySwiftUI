//
//  BorderBeamBorder.swift
//  EazySwiftUI
//

import SwiftUI

struct BorderBeamBorder: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let border: Color
    let showsBaseBorder: Bool
    let beam: [Color]
    let beamBlur: CGFloat
    let cornerRadius: CGFloat
    let duration: Double
    let isEnabled: Bool

    var body: some View {
        if isEnabled {
            ZStack {
                RoundedRectangle(cornerRadius: max(cornerRadius, 0))
                    .strokeBorder(border.tertiary, lineWidth: 0.6)
                    .opacity(showsBaseBorder ? 1 : 0)

                if reduceMotion {
                    BorderBeamStroke(
                        progress: 0,
                        border: border,
                        beam: beam,
                        beamBlur: beamBlur,
                        cornerRadius: cornerRadius
                    )
                } else {
                    KeyframeAnimator(initialValue: 0.0, repeating: true) { progress in
                        BorderBeamStroke(
                            progress: progress,
                            border: border,
                            beam: beam,
                            beamBlur: beamBlur,
                            cornerRadius: cornerRadius
                        )
                    } keyframes: { _ in
                        LinearKeyframe(1, duration: max(duration, 0.01))
                    }
                }
            }
            .padding(0.5)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
