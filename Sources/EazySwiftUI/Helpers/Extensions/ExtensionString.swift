//
//  ExtensionString.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 27.12.2025.
//

import SwiftUI

// Helper extension for string multiplication (for divider)
public extension String {
    static func * (lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}

// MARK: - String Specific Extensions

public extension String {

    /// Returns `true` if the string is not empty after trimming whitespace and newlines.
    ///
    /// This property is useful when you want to check if a string contains
    /// meaningful content (not just whitespace).
    ///
    /// # Usage Example
    /// ```swift
    /// let text = "   Hello   "
    /// let whitespace = "   "
    /// let empty = ""
    ///
    /// print(text.isNotEmptyAfterTrim)      // true
    /// print(whitespace.isNotEmptyAfterTrim) // false
    /// print(empty.isNotEmptyAfterTrim)     // false
    /// ```
    var isNotEmptyAfterTrim: Bool {
        return !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Returns `true` if the string contains only whitespace characters.
    ///
    /// # Usage Example
    /// ```swift
    /// let text = "Hello"
    /// let whitespace = "   \n\t"
    /// let empty = ""
    ///
    /// print(text.isWhitespaceOnly)   // false
    /// print(whitespace.isWhitespaceOnly) // true
    /// print(empty.isWhitespaceOnly)  // true (empty is considered whitespace)
    /// ```
    var isWhitespaceOnly: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Returns `true` if the string contains at least one letter.
    ///
    /// # Usage Example
    /// ```swift
    /// let text = "Hello123"
    /// let numbers = "123"
    /// let empty = ""
    ///
    /// print(text.containsLetters)  // true
    /// print(numbers.containsLetters) // false
    /// print(empty.containsLetters) // false
    /// ```
    var containsLetters: Bool {
        return rangeOfCharacter(from: .letters) != nil
    }

    /// Returns `true` if the string contains at least one digit.
    ///
    /// # Usage Example
    /// ```swift
    /// let text = "Hello123"
    /// let letters = "Hello"
    /// let empty = ""
    ///
    /// print(text.containsDigits)  // true
    /// print(letters.containsDigits) // false
    /// print(empty.containsDigits) // false
    /// ```
    var containsDigits: Bool {
        return rangeOfCharacter(from: .decimalDigits) != nil
    }

    /// Returns `true` if the string contains at least one letter and one digit.
    ///
    /// # Usage Example
    /// ```swift
    /// let text = "Hello123"
    /// let letters = "Hello"
    /// let numbers = "123"
    ///
    /// print(text.containsLettersAndDigits)  // true
    /// print(letters.containsLettersAndDigits) // false
    /// print(numbers.containsLettersAndDigits) // false
    /// ```
    var containsLettersAndDigits: Bool {
        return containsLetters && containsDigits
    }

    /// Returns the string if it's not empty, otherwise returns `nil`.
    ///
    /// This property is useful for filtering out empty strings in collections.
    ///
    /// # Usage Example
    /// ```swift
    /// let text = "Hello"
    /// let empty = ""
    ///
    /// print(text.nilIfEmpty)  // Optional("Hello")
    /// print(empty.nilIfEmpty) // nil
    ///
    /// // Useful in compactMap:
    /// let strings = ["Hello", "", "World", ""]
    /// let nonEmpty = strings.compactMap { $0.nilIfEmpty }
    /// // Result: ["Hello", "World"]
    /// ```
    var nilIfEmpty: String? {
        return isEmpty ? nil : self
    }

    /// Returns the string if it's not empty after trimming, otherwise returns `nil`.
    ///
    /// # Usage Example
    /// ```swift
    /// let text = "   Hello   "
    /// let whitespace = "   "
    ///
    /// print(text.nilIfEmptyAfterTrim)      // Optional("Hello")
    /// print(whitespace.nilIfEmptyAfterTrim) // nil
    /// ```
    var nilIfEmptyAfterTrim: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
