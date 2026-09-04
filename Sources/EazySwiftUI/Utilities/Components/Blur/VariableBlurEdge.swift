//
//  VariableBlurEdge.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 04.09.2026.
//


#if canImport(UIKit)
/// The edge where a variable blur reaches its full radius.
public enum VariableBlurEdge: String, Sendable, Hashable {
    /// Strongest at the top, fading to clear at the bottom.
    case top

    /// Strongest at the bottom, fading to clear at the top.
    case bottom
}
#endif
