//
//  ArrayExtension.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 07.12.2025.
//


public extension Array where Element: Identifiable & Hashable {

    /// Returns the first element in the array whose identifier matches the
    /// specified value.
    ///
    /// This method is a convenience wrapper around `first(where:)` and makes
    /// code more expressive when working with `Identifiable` collections.
    ///
    /// - Parameter matchingID: The identifier of the element to search for.
    /// - Returns: The first element with a matching `id`, or `nil` if none exists.
    @inlinable
    func find(matching matchingID: Element.ID) -> Element? {
        first { $0.id == matchingID }
    }

    /// Returns the index of the first element in the array whose identifier
    /// matches the specified value.
    ///
    /// This is especially useful when you need to update or remove an element
    /// in place.
    ///
    /// - Parameter matchingID: The identifier of the element to search for.
    /// - Returns: The index of the matching element, or `nil` if not found.
    @inlinable
    func firstIndex(matching matchingID: Element.ID) -> Int? {
        firstIndex { $0.id == matchingID }
    }
}
