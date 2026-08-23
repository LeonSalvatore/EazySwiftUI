import SwiftUI

struct EazySlideOutMenuScrim<Surface: Shape>: View {
    let shape: Surface
    let progress: CGFloat
    let blocksInteraction: Bool
    let isAccessibilityElement: Bool
    let color: Color
    let maximumOpacity: Double
    let borderColor: Color
    let borderWidth: CGFloat
    let closeAccessibilityLabel: LocalizedStringResource
    let onClose: () -> Void

    var body: some View {
        Button(action: onClose) {
            shape
                .fill(color.opacity(resolvedOpacity))
                .overlay {
                    shape.stroke(
                        borderColor.opacity(Double(progress)),
                        lineWidth: EazySlideOutMenuGeometry.finiteNonnegative(borderWidth)
                    )
                }
                .ignoresSafeArea()
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(blocksInteraction)
        .accessibilityHidden(!isAccessibilityElement)
        .accessibilityLabel(Text(closeAccessibilityLabel))
    }

    private var resolvedOpacity: Double {
        let opacity = min(
            EazySlideOutMenuGeometry.finiteNonnegative(maximumOpacity),
            1
        )
        return opacity * Double(EazySlideOutMenuGeometry.unitValue(progress))
    }
}

/// Handles pointer dismissal without putting the UIKit pan host on the
/// accessible scrim button.
struct EazySlideOutMenuPointerSurface: View {
    let onClose: () -> Void

    var body: some View {
        Button(action: onClose) {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
