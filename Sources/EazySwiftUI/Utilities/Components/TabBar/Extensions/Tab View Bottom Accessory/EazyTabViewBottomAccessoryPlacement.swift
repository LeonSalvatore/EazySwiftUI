//
//  EazyTabViewBottomAccessoryPlacement.swift
//  EazySwiftUI
//

import SwiftUI

/// Where the bottom accessory sits relative to the tab bar.
///
/// The system moves its accessory between two places rather than resizing it in
/// one: above a full-size tab bar, and beside a collapsed one. Reading the
/// placement is how an accessory adapts its own contents to the room it has —
/// a full transport in one, a title and a play button in the other.
///
/// Mirrors `TabViewBottomAccessoryPlacement`, which is iOS 26 only. This one
/// works from iOS 18 and macOS 15, because the surface it is drawn on is the
/// package's own glass rather than the system's.
///
/// ```swift
/// struct NowPlayingAccessory: View {
///     @Environment(\.eazyTabViewBottomAccessoryPlacement) private var placement
///
///     var body: some View {
///         switch placement {
///         case .expanded: FullTransport()
///         case .inline, .none: CompactTransport()
///         }
///     }
/// }
/// ```
public enum EazyTabViewBottomAccessoryPlacement: Hashable, Sendable, CaseIterable {
    /// In line with the tab bar, sharing its row.
    ///
    /// The row is the collapsed bar's: measured on a live `TabView` at 402×874,
    /// the accessory and the minimised bar are both 48 points tall and share the
    /// band the full 62-point bar occupied, centred in it.
    case inline

    /// Above the tab bar, spanning the width the bar is given.
    ///
    /// The bar it sits over may itself be split into a strip and a detached
    /// trailing control — the system's search tab, or ``EazyMorphingTabBar``'s
    /// toggle. The accessory spans both: measured against a `TabView` with a
    /// search tab, the main platter was 290 points wide and the detached button
    /// 62, and the accessory ran the full 360 across both of them.
    case expanded
}
