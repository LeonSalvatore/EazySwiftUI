//
//  ExtensionDictionary.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 27.12.2025.
//

import SwiftUI

// MARK: - Dictionary Specific Extensions

extension Dictionary {

    /// Returns `true` if the dictionary contains the specified key.
    ///
    /// - Parameter key: The key to look for.
    /// - Returns: `true` if the key exists; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let dict = ["a": 1, "b": 2]
    /// print(dict.hasKey("a"))  // true
    /// print(dict.hasKey("c"))  // false
    /// ```
    func hasKey(_ key: Key) -> Bool {
        return keys.contains(key)
    }

    /// Returns the dictionary if it's not empty, otherwise returns `nil`.
    ///
    /// # Usage Example
    /// ```swift
    /// let dict = ["a": 1, "b": 2]
    /// let empty: [String: Int] = [:]
    ///
    /// print(dict.nilIfEmpty)  // Optional(["a": 1, "b": 2])
    /// print(empty.nilIfEmpty) // nil
    /// ```
    var nilIfEmpty: [Key: Value]? {
        return isEmpty ? nil : self
    }
}
