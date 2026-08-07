//
//  EazyTab.swift
//  EazySwiftUI
//

import SwiftUI

/// A single item in the tab strip of ``EazyMorphingTabBar``.
public struct EazyTab: Identifiable, Hashable, Sendable {
    /// The stable identity used for selection.
    public let id: String
    /// The SF Symbol drawn in the strip.
    public let systemImage: String
    /// The accessibility label for the tab.
    public let title: LocalizedStringResource

    public init(
        id: String,
        systemImage: String,
        title: LocalizedStringResource
    ) {
        self.id = id
        self.systemImage = systemImage
        self.title = title
    }

    /// Creates a tab that uses its symbol name as identity.
    public init(systemImage: String, title: LocalizedStringResource) {
        self.init(id: systemImage, systemImage: systemImage, title: title)
    }

    public static func == (lhs: EazyTab, rhs: EazyTab) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// A labelled action shown in the panel ``EazyMorphingTabBar`` expands into.
public struct EazyTabBarAction: Identifiable {
    /// The stable identity of the action.
    public let id: String
    /// The SF Symbol drawn on the tile.
    public let systemImage: String
    /// The label shown under the tile.
    public let title: LocalizedStringResource
    /// Whether the action is drawn in the destructive role.
    public let isDestructive: Bool
    /// What the action does. The panel closes after it runs.
    public let handler: () -> Void

    public init(
        id: String,
        systemImage: String,
        title: LocalizedStringResource,
        isDestructive: Bool = false,
        handler: @escaping () -> Void
    ) {
        self.id = id
        self.systemImage = systemImage
        self.title = title
        self.isDestructive = isDestructive
        self.handler = handler
    }

    /// Creates an action that uses its symbol name as identity.
    public init(
        systemImage: String,
        title: LocalizedStringResource,
        isDestructive: Bool = false,
        handler: @escaping () -> Void
    ) {
        self.init(
            id: systemImage,
            systemImage: systemImage,
            title: title,
            isDestructive: isDestructive,
            handler: handler
        )
    }
}
