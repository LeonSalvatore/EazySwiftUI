//
//  BorderBeamStroke.swift
//  EazySwiftUI
//

import SwiftUI

struct BorderBeamStroke: View {
    let progress: Double
    let border: Color
    let beam: [Color]
    let beamBlur: CGFloat
    let cornerRadius: CGFloat

    var body: some View {

        let rotation = progress * 360
        let blurRadius = max(beamBlur, 0)
        let radius = max(cornerRadius, 0)
        let beamColors = beam.isEmpty ? [border, border] : beam

        let borderGradient = AngularGradient(
            colors: [.clear, border, .clear],
            center: .center,
            startAngle: .degrees(140 + rotation),
            endAngle: .degrees(270 + rotation)
        )
        let beamGradient = LinearGradient(
            colors: beamColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        RoundedRectangle(cornerRadius: radius)
            .fill(beamGradient)
            .mask {
                Rectangle()
                    .overlay {
                        RoundedRectangle(cornerRadius: radius)
                            .blur(radius: blurRadius)
                            .blendMode(.destinationOut)
                    }
            }
            .mask {
                RoundedRectangle(cornerRadius: radius)
                    .fill(borderGradient)
                    .blur(radius: blurRadius / 1.5)
                    .padding(-blurRadius * 2)
            }

        RoundedRectangle(cornerRadius: radius)
            .strokeBorder(borderGradient, lineWidth: 0.6)

    }
}

#Preview("Border beam border") {
    RoundedRectangle(cornerRadius: 20)
        .fill(.clear)
        .frame(width: 280, height: 120)
        .borderBeamEffect(
            border: .cyan,
            showsBaseBorder: false,
            beam: [.pink, .purple, .cyan],
            beamBlur: 15, cornerRadius: 20,
            isEnabled: true)

}


