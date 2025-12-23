//
//  ChromaKeyEffect.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI

// MARK: - Chroma Key Effect

/// A view modifier that applies a chroma key (green screen) effect.
///
/// The chroma key effect removes a specific color from the content,
/// making it transparent. Commonly used for green screen backgrounds.
struct ChromaKeyEffect: ViewModifier {
    let keyColor: Color
    let threshold: CGFloat

    @Environment(\.self) var environment

    func body(content: Content) -> some View {
        // Resolve the Color in the current environment
        let components = keyColor.resolve(in: environment)

        // SIMD4 for RGBA (4 components)
        let simdColor = SIMD4<Float>(
            Float(components.red),
            Float(components.green),
            Float(components.blue),
            Float(components.opacity)  // Alpha
        )

        return content
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        EazyShaderLibrary.chromaKey(
                            keyColor: simdColor,  // SIMD4
                            threshold: Float(threshold)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}

#Preview("ChromaKey Effect") {

    @Previewable @State var threshold: CGFloat = 0
    @Previewable @State var colorToRemove: Color = .red
    let colors: [Color] = [.red, .green, .blue, .yellow, .purple, .pink]
    Form {
        Section("ChromaKey Effect") {

            Slider(value: $threshold, in: 0.0...1.0)

            Picker("Color to Remove:", selection: $colorToRemove) {
                ForEach(colors, id: \.self) {
                    Text($0.description)
                }
            }.pickerStyle(.segmented)

            Group {
                Text("Amount: \(threshold, specifier: "%.2f")")
                LazyHGrid(rows: [GridItem(), GridItem()], alignment: .center) {
                    ForEach(0..<6) { index in

                        RoundedRectangle(cornerRadius: 26)
                            .fill(colors[index])
                            .frame(width: 90, height: 90)
                            .hSpacing(.center)
                            .interactionEffect(.chromaKey(keyColor: colorToRemove, threshold: threshold))
                    }
                }
            }
        }
    }
}
