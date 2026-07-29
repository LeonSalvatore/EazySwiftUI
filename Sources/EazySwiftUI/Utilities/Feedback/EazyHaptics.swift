//
//  EazyHaptics.swift
//  EazySwiftUI
//

import SwiftUI

#if os(iOS)
import UIKit
#endif

/// Cross-platform haptic feedback helpers.
///
/// Calls are no-ops on platforms without UIKit haptic generators.
@MainActor
public enum EazyHaptics {
    public enum ImpactStyle: Sendable {
        case light
        case medium
        case heavy
        case rigid
        case soft
    }

    public enum NotificationType: Sendable {
        case success
        case warning
        case error
    }

    public static func impact(_ style: ImpactStyle = .medium) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style.uiStyle)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    public static func selection() {
        #if os(iOS)
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        #endif
    }

    public static func notification(_ type: NotificationType) {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type.uiType)
        #endif
    }
}

public extension View {
    /// Produces an impact whenever `value` changes.
    func eazyHapticOnChange<Value: Equatable>(
        of value: Value,
        style: EazyHaptics.ImpactStyle = .light
    ) -> some View {
        onChange(of: value) { _, _ in
            EazyHaptics.impact(style)
        }
    }

    /// Produces an impact when `value` becomes equal to `trigger`.
    func eazyHapticFeedback<Value: Equatable>(
        when value: Value,
        equals trigger: Value,
        style: EazyHaptics.ImpactStyle = .medium
    ) -> some View {
        onChange(of: value) { _, newValue in
            guard newValue == trigger else { return }
            EazyHaptics.impact(style)
        }
    }
}

#if os(iOS)
private extension EazyHaptics.ImpactStyle {
    var uiStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light: .light
        case .medium: .medium
        case .heavy: .heavy
        case .rigid: .rigid
        case .soft: .soft
        }
    }
}

private extension EazyHaptics.NotificationType {
    var uiType: UINotificationFeedbackGenerator.FeedbackType {
        switch self {
        case .success: .success
        case .warning: .warning
        case .error: .error
        }
    }
}
#endif
