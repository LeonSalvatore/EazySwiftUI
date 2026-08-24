//
//  EazyTab.swift
//  EazySwiftUI
//

import SwiftUI

/// A single item in the tab strip of ``EazyMorphingTabBar``, and — when it is
/// declared with one — the screen behind it.
///
/// ```swift
/// EazyTabView(selection: $selection) {
///     EazyTab("Home", systemImage: "house.fill", value: "home") {
///         HomeScreen()
///     }
///     EazyTab("Library", systemImage: "books.vertical.fill", value: "library") {
///         LibraryScreen()
///     }
/// }
/// ```
///
/// Mirrors `Tab`, which is the same two things in one value: what the bar draws,
/// and what the tab view shows. A tab declared without content is just the bar
/// item, which is what ``EazyMorphingTabBar`` takes on its own.
///
/// Identity, equality and hashing are all the ``id`` alone, so a tab is cheap to
/// compare and to key by however large the screen behind it is.
public struct EazyTab: Identifiable, Hashable, Sendable {
    /// The stable identity used for selection.
    public let id: String
    /// The SF Symbol drawn in the strip.
    public let systemImage: String
    /// The accessibility label for the tab.
    public let title: LocalizedStringResource
    /// The screen this tab shows, for tabs declared with one.
    ///
    /// A closure rather than a view, for two reasons. The screen is then built
    /// where it is drawn instead of where it is declared, so a tab list rebuilt
    /// on every parent update does not rebuild four screens to show one. And a
    /// closure can be `Sendable` where an `AnyView` cannot, which is what keeps
    /// a tab list writable as a plain `let` at file scope.
    ///
    /// `@MainActor` because it makes a `View`, and views are the main actor's.
    let screen: (@MainActor @Sendable () -> AnyView)?

    public init(
        id: String,
        systemImage: String,
        title: LocalizedStringResource
    ) {
        self.init(id: id, systemImage: systemImage, title: title, screen: nil)
    }

    /// Creates a tab that uses its symbol name as identity.
    public init(systemImage: String, title: LocalizedStringResource) {
        self.init(id: systemImage, systemImage: systemImage, title: title)
    }

    private init(
        id: String,
        systemImage: String,
        title: LocalizedStringResource,
        screen: (@MainActor @Sendable () -> AnyView)?
    ) {
        self.id = id
        self.systemImage = systemImage
        self.title = title
        self.screen = screen
    }

    // MARK: - Declared with a screen

    /// Creates a tab and the screen it shows.
    ///
    /// The argument order is `Tab`'s, so a `TabView` body reads the same here.
    ///
    /// - Parameters:
    ///   - title: The tab's label, which is also its accessibility label.
    ///   - systemImage: The SF Symbol drawn in the strip.
    ///   - value: The identity selection is expressed in. Defaults to
    ///     `systemImage`, which is enough whenever no two tabs share a symbol.
    ///   - content: The screen the tab shows.
    public init<Content: View>(
        _ title: LocalizedStringResource,
        systemImage: String,
        value: String,
        @ViewBuilder content: @escaping @MainActor @Sendable () -> Content
    ) {
        self.init(
            id: value,
            systemImage: systemImage,
            title: title,
            screen: { AnyView(content()) }
        )
    }

    /// Creates a tab and the screen it shows, using the symbol name as identity.
    public init<Content: View>(
        _ title: LocalizedStringResource,
        systemImage: String,
        @ViewBuilder content: @escaping @MainActor @Sendable () -> Content
    ) {
        self.init(title, systemImage: systemImage, value: systemImage, content: content)
    }

    // MARK: - Declared without one

    /// Creates a bar item, in the argument order tabs with screens use.
    public init(
        _ title: LocalizedStringResource,
        systemImage: String,
        value: String
    ) {
        self.init(id: value, systemImage: systemImage, title: title)
    }

    /// Creates a bar item using the symbol name as identity, in the argument
    /// order tabs with screens use.
    public init(_ title: LocalizedStringResource, systemImage: String) {
        self.init(id: systemImage, systemImage: systemImage, title: title)
    }

    public static func == (lhs: EazyTab, rhs: EazyTab) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Builds the list of tabs in an ``EazyTabView``'s body.
///
/// Mirrors `TabContentBuilder`, down to supporting the things a tab list
/// actually needs: `if`, `if`–`else`, `if #available`, and loops over a
/// collection of tabs.
///
/// ```swift
/// EazyTabView(selection: $selection) {
///     EazyTab("Home", systemImage: "house.fill", value: "home") { HomeScreen() }
///
///     if account.isSignedIn {
///         EazyTab("You", systemImage: "person.fill", value: "you") { ProfileScreen() }
///     }
/// }
/// ```
@resultBuilder
public enum EazyTabContentBuilder {
    public static func buildExpression(_ expression: EazyTab) -> [EazyTab] {
        [expression]
    }

    public static func buildExpression(_ expression: [EazyTab]) -> [EazyTab] {
        expression
    }

    public static func buildBlock(_ components: [EazyTab]...) -> [EazyTab] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [EazyTab]?) -> [EazyTab] {
        component ?? []
    }

    public static func buildEither(first component: [EazyTab]) -> [EazyTab] {
        component
    }

    public static func buildEither(second component: [EazyTab]) -> [EazyTab] {
        component
    }

    public static func buildArray(_ components: [[EazyTab]]) -> [EazyTab] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [EazyTab]) -> [EazyTab] {
        component
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
    /// What the action does. The panel starts closing before it runs.
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
