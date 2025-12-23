//
//  BlurEffect.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI

// MARK: - Blur Effect

/// A view modifier that applies a blur effect.
///
/// The blur effect softens the content by averaging neighboring pixels.
struct BlurEffect: ViewModifier {

    /// The blur strength.
    var intensity: CGFloat

    /// Creates a blur effect modifier.
    /// - Parameter intensity: The blur strength.
    init(intensity: CGFloat) {
        self.intensity = intensity
    }

    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        EazyShaderLibrary.blur(intensity: Float(intensity)),
                        maxSampleOffset: .zero
                    )
            }
    }
}


#Preview("Blur Effect") {

    @Previewable @State var intensity: CGFloat = 1.5

    Form {
        Section("Blur Effect") {

            Slider(value: $intensity, in: 0.0...3.0)

            Group {
                Text("Blurred Content strengh: \(intensity, specifier: "%.2f")")
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.blue)
                    .frame(width: 200, height: 200)
                    .hSpacing(.center)

            }.interactionEffect(.blur(intensity: intensity))
        }
    }
}
