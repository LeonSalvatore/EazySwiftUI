//
//  BlurFilterProvider.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 04.09.2026.
//


#if canImport(UIKit)
import UIKit

/// Vends the Core Animation filters that back ``VariableBlur``.
///
/// `UIVisualEffectView` already owns live filter objects on its backdrop layer.
/// The implementation reads the class from one of those objects and asks its
/// factory for a variable blur filter. Every lookup is optional and resolved
/// once; if the runtime hierarchy changes, ``VariableBlur`` uses its material
/// fallback instead of crashing or disappearing.
///
/// The approach follows BlurUIKit by Tim Oliver (MIT licensed).
@MainActor
enum BlurFilterProvider {
    private static let filterClass: AnyClass? = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        guard let backdrop = subview(
            of: effectView,
            withClassNameContaining: "backdrop"
        ), let filter = backdrop.layer.filters?.first as? NSObject else {
            return nil
        }
        return type(of: filter)
    }()

    private static let filterSelector: Selector? = {
        let selector = NSSelectorFromString(
            ["Type:", "With", "filter"].reversed().joined()
        )
        guard let filterClass, filterClass.responds(to: selector) else {
            return nil
        }
        return selector
    }()

    static var isSupported: Bool {
        filterClass != nil && filterSelector != nil
    }

    static func makeFilter(named name: String) -> NSObject? {
        guard let filterClass, let filterSelector else { return nil }
        return (filterClass as AnyObject)
            .perform(filterSelector, with: name)?
            .takeUnretainedValue() as? NSObject
    }

    static func subview(
        of view: UIView,
        withClassNameContaining fragment: String
    ) -> UIView? {
        let needle = fragment.lowercased()
        return view.subviews.first {
            NSStringFromClass(type(of: $0)).lowercased().contains(needle)
        }
    }
}
#endif
