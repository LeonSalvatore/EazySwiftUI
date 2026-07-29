//
//  PixellateEffect.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//

import SwiftUI

/// A view modifier that applies a pixelation effect.
struct PixellateEffect: ViewModifier {
    let pixelSize: CGFloat

    func body(content: Content) -> some View {
        content
            .drawingGroup()
            .scaleEffect(1 / max(pixelSize, 1))
            .scaleEffect(max(pixelSize, 1))
    }
}
