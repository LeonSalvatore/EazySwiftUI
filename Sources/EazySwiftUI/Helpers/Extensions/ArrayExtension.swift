//
//  ArrayExtension.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 07.12.2025.
//

import SwiftUI

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


// MARK: - Array Specific Extensions

public extension Array {

    /// Returns `true` if the array contains the specified element.
    ///
    /// This method provides a more readable alternative to `contains(_:)`
    /// when the syntax `array.contains(element)` might be less clear.
    ///
    /// - Parameter element: The element to look for.
    /// - Returns: `true` if the element is found; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let numbers = [1, 2, 3]
    /// print(numbers.has(2))  // true
    /// print(numbers.has(4))  // false
    /// ```
    func has(_ element: Element) -> Bool where Element: Equatable {
        return contains(element)
    }

    /// Returns `true` if the array contains all of the specified elements.
    ///
    /// - Parameter elements: The elements to look for.
    /// - Returns: `true` if all elements are found; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let numbers = [1, 2, 3, 4, 5]
    /// print(numbers.hasAll([1, 3, 5]))  // true
    /// print(numbers.hasAll([1, 6]))     // false
    /// ```
    func hasAll(_ elements: [Element]) -> Bool where Element: Equatable {
        return elements.allSatisfy { contains($0) }
    }

    /// Returns `true` if the array contains any of the specified elements.
    ///
    /// - Parameter elements: The elements to look for.
    /// - Returns: `true` if at least one element is found; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let numbers = [1, 2, 3]
    /// print(numbers.hasAny([3, 4, 5]))  // true
    /// print(numbers.hasAny([4, 5, 6]))  // false
    /// ```
    func hasAny(_ elements: [Element]) -> Bool where Element: Equatable {
        return elements.contains { contains($0) }
    }

    /// Returns the element at the specified index if it exists, otherwise `nil`.
    ///
    /// This method provides a safe alternative to subscripting that won't crash.
    ///
    /// - Parameter index: The position of the element to access.
    /// - Returns: The element at the specified index if it exists; otherwise, `nil`.
    ///
    /// # Usage Example
    /// ```swift
    /// let numbers = [1, 2, 3]
    /// print(numbers[safe: 1])  // Optional(2)
    /// print(numbers[safe: 5])  // nil
    /// ```
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    /// Returns the array if it's not empty, otherwise returns `nil`.
    ///
    /// This property is useful for filtering out empty arrays in collections.
    ///
    /// # Usage Example
    /// ```swift
    /// let numbers = [1, 2, 3]
    /// let empty: [Int] = []
    ///
    /// print(numbers.nilIfEmpty)  // Optional([1, 2, 3])
    /// print(empty.nilIfEmpty)    // nil
    /// ```
    var nilIfEmpty: [Element]? {
        return isEmpty ? nil : self
    }
}
