//
//  EazyTabReselection.swift
//  EazySwiftUI
//

import SwiftUI

// MARK: - What the content sees

/// How many times the tab a view belongs to has been tapped while it was
/// already the tab showing.
///
/// ``EazyTabView`` acts on a reselection itself — it takes the tab's scroll view
/// back to the top, as a `TabView` does — so most screens never need to read
/// this. It is here for the screens where that is not enough: a tab holding
/// several scroll views, or one driving its own
/// ``SwiftUICore/View/scrollPosition(_:anchor:)``, which the container will not
/// override.
///
/// ```swift
/// @Environment(\.eazyTabReselection) private var reselection
/// @State private var path = NavigationPath()
///
/// var body: some View {
///     NavigationStack(path: $path) { … }
///         .onChange(of: reselection) { path = NavigationPath() }
/// }
/// ```
///
/// The count only ever grows, and only for the tab whose content is reading it.
/// Compare it for change; the value itself means nothing.
public struct EazyTabReselection: Equatable, Sendable {
    /// How many reselections this tab has had. Zero until the first.
    public var count: Int

    public init(count: Int = 0) {
        self.count = count
    }
}

public extension EnvironmentValues {
    /// Reselections of the tab this view belongs to.
    ///
    /// Always zero outside an ``EazyTabView``, and outside a tab declared with
    /// a screen.
    @Entry var eazyTabReselection = EazyTabReselection()
}

// MARK: - What the bar reports

/// Told when a tab already showing is tapped again.
///
/// The bar cannot act on a reselection: it does not own the content, and has no
/// way to reach the scroll view inside it. So it reports the tap upward and
/// whatever owns the content decides. Travelling by environment rather than by
/// an initialiser parameter keeps ``EazyMorphingTabBar``'s surface the same for
/// everyone using it on its own, who have nothing to do with this.
struct EazyTabReselectionHandler {
    var handle: @MainActor (EazyTab.ID) -> Void = { _ in }
}

extension EnvironmentValues {
    @Entry var eazyTabReselectionHandler = EazyTabReselectionHandler()
}
