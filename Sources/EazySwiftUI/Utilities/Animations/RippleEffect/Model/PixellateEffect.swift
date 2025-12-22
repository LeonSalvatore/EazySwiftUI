//
//  PixellateEffect.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI
// MARK: - Pixellate Effect

/// A view modifier that applies a pixelation effect.
///
/// The pixellate effect creates a retro, blocky appearance by grouping
/// pixels into larger blocks.
struct PixellateEffect: ViewModifier {

    /// The size of each pixel block in points.
    var pixelSize: CGFloat

    /// Creates a pixellate effect modifier.
    /// - Parameter pixelSize: The size of each pixel block.
    init(pixelSize: CGFloat) {
        self.pixelSize = pixelSize
    }

    func body(content: Content) -> some View {

        content
            .drawingGroup()  // Forces rasterization
            .scaleEffect(1 / pixelSize)
            .scaleEffect(pixelSize)

    }
}

#Preview("Pixellate Effect") {
    struct PixellatePreview: View {
        @State private var pixelSize: CGFloat = 8.0
        @State private var useColorImage = false

        var body: some View {
            ScrollView {
                VStack(spacing: 25) {
                    // Title
                    Text("🔳 Pixellate Effect")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue.gradient)
                        .padding(.top)
                    
                    // Image Toggle
                    Picker("Image Type", selection: $useColorImage) {
                        Text("Color Gradient").tag(true)
                        Text("SF Symbol").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Content with pixellate effect
                    if useColorImage {
                        // Color gradient rectangle
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 250, height: 250)
                            .overlay(
                                Text("Pixel Art")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 8)
                            .visualEffect { content, proxy in
                                let s = Float(pixelSize)
                               return content
                                    .layerEffect(
                                        EazyShaderLibrary.pixellate(pixelSize: s),
                                        maxSampleOffset: .zero
                                    )
                            }
                    } else {
                        // SF Symbol
                        Image(systemName: "photo.artframe")
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 80))
                            .foregroundStyle(.blue, .purple, .pink)
                            .frame(width: 250, height: 250)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.blue.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(radius: 8)
                            .visualEffect { content, proxy in
                                content
                                    .layerEffect(
                                        EazyShaderLibrary.pixellate(pixelSize: Float(pixelSize)),
                                        maxSampleOffset: .zero
                                    )
                            }
                    }
                    
                    // Controls
                    VStack(spacing: 15) {
                        // Pixel size slider
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Pixel Size:")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text("\(pixelSize, specifier: "%.1f")")
                                    .font(.body.monospacedDigit())
                                    .foregroundColor(.blue)
                            }
                            
                            Slider(value: $pixelSize, in: 1...30, step: 0.5)
                                .tint(.blue)
                        }
                        .padding(.horizontal)
                        
                        // Quick size buttons
                        HStack(spacing: 20) {
                            ForEach([0.1,4.0, 8.0, 16.0, 24.0], id: \.self) { size in
                                Button {
                                    withAnimation(.spring) {
                                        pixelSize = size
                                    }
                                } label: {
                                    Text("\(Int(size))px")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            pixelSize == size ? Color.blue : Color.gray.opacity(0.2)
                                        )
                                        .foregroundColor(pixelSize == size ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.top, 5)
                    }
                    
                    // Comparison section
                    VStack(spacing: 15) {
                        Text("Comparison")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            // Original
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                
                                Rectangle()
                                    .fill(.blue.gradient)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Text("Original")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Arrow
                            Image(systemName: "arrow.right")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .frame(height: 80)
                            
                            // Pixelated
                            VStack(spacing: 8) {
                                Image(systemName: "square.grid.3x3")
                                    .font(.title)
                                    .foregroundColor(.purple)
                                
                                Rectangle()
                                    .fill(.blue.gradient)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .visualEffect { content, proxy in
                                        content
                                            .layerEffect(
                                                EazyShaderLibrary.pixellate(pixelSize: Float(pixelSize)),
                                                maxSampleOffset: .zero
                                            )
                                    }
                                
                                Text("Pixelated")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.top)
                    
                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Pixelation creates retro, blocky effects", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("Higher values = larger pixels", systemImage: "square.grid.3x3")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.systemGray6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            }
        }
    }

    return PixellatePreview()
}

#Preview("Simple Pixellate") {
    VStack(spacing: 20) {
        Text("Simple Pixellate Demo")
            .font(.headline)

        Image(systemName: "swift")
            .font(.system(size: 60))
            .foregroundStyle(.orange.gradient)
            .frame(width: 200, height: 200)
            .background(.blue.opacity(0.1))
            .clipShape(Circle())
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        EazyShaderLibrary.pixellate(pixelSize: 12),
                        maxSampleOffset: .zero
                    )
            }

        Text("Swift Logo Pixelated")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}

#Preview("Pixelation Examples") {
    ScrollView {
        VStack(spacing: 30) {
            Text("Pixelation Examples")
                .font(.title)
                .fontWeight(.bold)

            Grid(horizontalSpacing: 20, verticalSpacing: 20) {
                GridRow {
                    pixelExample(icon: "face.smiling", size: 4, color: .blue)
                    pixelExample(icon: "heart.fill", size: 8, color: .red)
                }

                GridRow {
                    pixelExample(icon: "star.fill", size: 12, color: .yellow)
                    pixelExample(icon: "flag.fill", size: 16, color: .green)
                }
            }
        }
        .padding()
    }
}

private func pixelExample(icon: String, size: Float, color: Color) -> some View {
    VStack {
        Image(systemName: icon)
            .font(.system(size: 40))
            .foregroundStyle(color.gradient)
            .frame(width: 120, height: 120)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        EazyShaderLibrary.pixellate(pixelSize: size),
                        maxSampleOffset: .zero
                    )
            }

        Text("\(Int(size))px")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
