//
//  BorderBeamEffectPreview.swift
//  EazySwiftUI
//

import SwiftUI

#Preview("Border beam") {
    @Previewable @State var isEnabled = true

    VStack(spacing: 24) {
        Toggle("Show border beam", isOn: $isEnabled)

        Button("Secure my spot", systemImage: "arrow.right") {}
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 20)
            .frame(height: 50)
            .borderBeamEffect(
                border: .accentColor,
                showsBaseBorder: true,
                beam: [.pink, .purple, .cyan],
                beamBlur: 14,
                cornerRadius: 12,
                isEnabled: isEnabled
            )
    }
    .padding(32)
}
