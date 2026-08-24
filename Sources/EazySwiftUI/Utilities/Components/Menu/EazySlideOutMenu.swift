import SwiftUI

/// A configurable edge menu that reveals content beside a primary app surface.
///
/// The caller owns the settled presentation state. The component owns only the
/// interactive offset and derives a clamped reveal progress passed to both
/// builders. Menu and primary content are switched between the accessibility
/// and hit-testing trees as the settled state changes.
///
/// A pan is an accelerator, not an accessible entry point. Always provide a
/// visible control bound to the same `isExpanded` value.
///
/// ```swift
/// @State private var isMenuOpen = false
///
/// EazySlideOutMenu(
///     isExpanded: $isMenuOpen,
///     closeAccessibilityLabel: "Close navigation menu"
/// ) { _ in
///     MenuDestinations()
/// } content: { _ in
///     NavigationStack {
///         HomeView()
///             .toolbar {
///                 Button("Menu", systemImage: "line.3.horizontal") {
///                     isMenuOpen.toggle()
///                 }
///             }
///     }
/// }
/// ```
public struct EazySlideOutMenu<MenuContent: View, Content: View>: View {
    @Binding private var isExpanded: Bool

    private let isGestureEnabled: Bool
    private let configuration: EazySlideOutMenuConfiguration
    private let closeAccessibilityLabel: LocalizedStringResource
    private let menuContent: (_ progress: CGFloat) -> MenuContent
    private let content: (_ progress: CGFloat) -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.layoutDirection) private var layoutDirection

    @State private var offset: CGFloat = 0
    @State private var hapticTrigger = false
    @State private var containerWidth: CGFloat = 0

    /// Creates a slide-out menu.
    ///
    /// - Parameters:
    ///   - isExpanded: The caller-owned settled presentation state.
    ///   - isGestureEnabled: Whether drag gestures may open and close the menu.
    ///   - configuration: Layout, appearance, animation, and feedback settings.
    ///   - closeAccessibilityLabel: Caller-localized text for the dismissing scrim.
    ///   - menuContent: Menu content and its reveal progress from `0` through `1`.
    ///   - content: Primary content and the menu's reveal progress from `0` through `1`.
    public init(
        isExpanded: Binding<Bool>,
        isGestureEnabled: Bool = true,
        configuration: EazySlideOutMenuConfiguration = .init(),
        closeAccessibilityLabel: LocalizedStringResource,
        @ViewBuilder menuContent: @escaping (_ progress: CGFloat) -> MenuContent,
        @ViewBuilder content: @escaping (_ progress: CGFloat) -> Content
    ) {
        self._isExpanded = isExpanded
        self.isGestureEnabled = isGestureEnabled
        self.configuration = configuration
        self.closeAccessibilityLabel = closeAccessibilityLabel
        self.menuContent = menuContent
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: menuAlignment) {
            menuContent(progress)
                .frame(width: resolvedMenuWidth)
                .frame(maxHeight: .infinity, alignment: .topLeading)
                .opacity(progress)
                .scaleEffect(menuScale)
                .accessibilityHidden(!isEffectivelyExpanded)
                .allowsHitTesting(isEffectivelyExpanded)

            content(progress)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .accessibilityHidden(isEffectivelyExpanded)
                .background {
                    EazySlideOutMenuBackground(
                        color: configuration.contentBackground
                    )
                    .ignoresSafeArea()
                }
                .overlay {
                    if isEffectivelyExpanded || progress > 0 {
                        EazySlideOutMenuScrim(
                            shape: contentShape,
                            progress: progress,
                            blocksInteraction: isEffectivelyExpanded || progress > 0,
                            isAccessibilityElement: isEffectivelyExpanded,
                            color: configuration.scrimColor,
                            maximumOpacity: configuration.maximumScrimOpacity,
                            borderColor: configuration.borderColor,
                            borderWidth: configuration.borderWidth,
                            closeAccessibilityLabel: closeAccessibilityLabel,
                            onClose: close
                        )
                    }
                }
                .mask { contentShape.ignoresSafeArea() }
                .compositingGroup()
                .shadow(
                    color: configuration.shadowColor.opacity(Double(progress)),
                    radius: resolvedShadowRadius,
                    x: resolvedShadowOffset,
                    y: 0
                )
                .offset(x: physicalOffset)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .contentShape(.rect)
        .background {
            EazySlideOutMenuBackground(color: configuration.menuBackground)
                .ignoresSafeArea()
        }
        .modifier(
            EazySlideOutMenuPan(
                isEnabled: {
                    isGestureEnabled && resolvedMenuWidth > 0
                },
                isExpanded: { isExpanded },
                edge: configuration.edge,
                layoutDirection: layoutDirection,
                handle: handlePan
            )
        )
        .sensoryFeedback(.impact(weight: .light), trigger: hapticTrigger)
        .accessibilityAction(.escape, close)
        .onChange(of: isExpanded) { _, isNowExpanded in
            withAnimation(revealAnimation) {
                offset = isNowExpanded ? resolvedMenuWidth : 0
            }
        }
        .onChange(of: isGestureEnabled) { _, isNowEnabled in
            guard !isNowEnabled else { return }
            withAnimation(revealAnimation) {
                offset = isExpanded ? resolvedMenuWidth : 0
            }
        }
        .onGeometryChange(for: CGFloat.self) {
            $0.size.width
        } action: { newValue in
            containerWidth = newValue
        }
        .onChange(of: resolvedMenuWidth) { oldWidth, newWidth in
            synchronizeOffset(from: oldWidth, to: newWidth)
        }
    }

    private var menuAlignment: Alignment {
        configuration.edge == .leading ? .leading : .trailing
    }

    private var resolvedMenuWidth: CGFloat {
        EazySlideOutMenuGeometry.menuWidth(
            containerWidth: containerWidth,
            specification: configuration.menuWidth,
            minimumVisibleContentWidth: configuration.minimumVisibleContentWidth
        )
    }

    private var progress: CGFloat {
        EazySlideOutMenuGeometry.progress(
            offset: offset,
            menuWidth: resolvedMenuWidth
        )
    }

    private var menuScale: CGFloat {
        EazySlideOutMenuGeometry.menuScale(
            progress: progress,
            minimumScale: configuration.menuMinimumScale
        )
    }

    private var contentShape: AnyShape {
        switch configuration.contentShape {
        case .automatic:
            if #available(iOS 26.0, macOS 26.0, *) {
                AnyShape(
                    ConcentricRectangle(
                        corners: .concentric,
                        isUniform: true
                    )
                )
            } else {
                AnyShape(
                    RoundedRectangle(
                        cornerRadius: 55,
                        style: .continuous
                    )
                )
            }
        case .roundedRectangle(let cornerRadius):
            AnyShape(
                RoundedRectangle(
                    cornerRadius: EazySlideOutMenuGeometry.finiteNonnegative(
                        cornerRadius
                    ),
                    style: .continuous
                )
            )
        }
    }

    private var revealDirection: CGFloat {
        EazySlideOutMenuGeometry.revealDirection(
            edge: configuration.edge,
            layoutDirection: layoutDirection
        )
    }

    private var physicalOffset: CGFloat {
        offset * revealDirection
    }

    private var resolvedShadowRadius: CGFloat {
        EazySlideOutMenuGeometry.finiteNonnegative(configuration.shadowRadius)
    }

    private var resolvedShadowOffset: CGFloat {
        -revealDirection
            * EazySlideOutMenuGeometry.finiteNonnegative(
                configuration.shadowOffset
            )
    }

    private var isEffectivelyExpanded: Bool {
        isExpanded && resolvedMenuWidth > 0
    }

    private var revealAnimation: Animation? {
        reduceMotion ? nil : configuration.settleAnimation
    }

    private func synchronizeOffset(from oldWidth: CGFloat, to newWidth: CGFloat) {
        offset = EazySlideOutMenuGeometry.resizedOffset(
            offset: offset,
            oldMenuWidth: oldWidth,
            newMenuWidth: newWidth,
            isExpanded: isExpanded
        )
    }

    private func handlePan(_ sample: EazySlideOutMenuPan.Sample) {
        let width = resolvedMenuWidth
        guard width > 0 else { return }

        guard sample.hasEnded else {
            let travelled = sample.translation + (isExpanded ? width : 0)
            offset = min(max(travelled, 0), width)
            return
        }

        settle(
            expanded: EazySlideOutMenuGeometry.shouldExpand(
                offset: offset,
                projectedVelocity: sample.velocity,
                menuWidth: width
            )
        )
    }

    private func settle(expanded: Bool) {
        let didChange = expanded != isExpanded
        withAnimation(revealAnimation) {
            offset = expanded ? resolvedMenuWidth : 0
            isExpanded = expanded
        }

        if didChange && configuration.hapticsEnabled {
            hapticTrigger.toggle()
        }
    }

    private func close() {
        guard isExpanded else { return }
        settle(expanded: false)
    }
}


#Preview("Slide-out menu") {
    EazySlideOutMenuPreview()
}
