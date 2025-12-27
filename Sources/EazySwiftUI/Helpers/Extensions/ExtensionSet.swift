//
//  ExtensionSet.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 27.12.2025.
//

import SwiftUI

// MARK: - Set Specific Extensions

public extension Set {

    /// Returns `true` if the set contains the specified element.
    ///
    /// - Parameter element: The element to look for.
    /// - Returns: `true` if the element is found; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let numbers: Set = [1, 2, 3]
    /// print(numbers.has(2))  // true
    /// print(numbers.has(4))  // false
    /// ```
    func has(_ element: Element) -> Bool {
        return contains(element)
    }

    /// Returns the set if it's not empty, otherwise returns `nil`.
    ///
    /// # Usage Example
    /// ```swift
    /// let numbers: Set = [1, 2, 3]
    /// let empty: Set<Int> = []
    ///
    /// print(numbers.nilIfEmpty)  // Optional([1, 2, 3])
    /// print(empty.nilIfEmpty)    // nil
    /// ```
    var nilIfEmpty: Set<Element>? {
        return isEmpty ? nil : self
    }
}
