//
//  ExtensionCollection.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 27.12.2025.
//

// MARK: - Collection Extension

public extension Collection {

    /// Returns `true` if the collection contains one or more elements.
    ///
    /// This property provides a more readable alternative to `!isEmpty`
    /// when checking for non-empty collections.
    ///
    /// # Performance
    /// - Time: O(1) for collections that have O(1) `isEmpty` checks
    /// - Space: O(1)
    ///
    /// # Usage Examples
    ///
    /// ```swift
    /// let numbers = [1, 2, 3]
    /// print(numbers.isNotEmpty)  // true
    ///
    /// let emptyArray: [String] = []
    /// print(emptyArray.isNotEmpty)  // false
    ///
    /// let text = "Hello"
    /// print(text.isNotEmpty)  // true
    ///
    /// let emptyString = ""
    /// print(emptyString.isNotEmpty)  // false
    ///
    /// // Alternative to:
    /// let alternative = !numbers.isEmpty  // true
    /// ```
    ///
    /// - Note: This property is equivalent to `!isEmpty` but provides
    ///   better readability in certain contexts.
    var isNotEmpty: Bool {
        return !isEmpty
    }

    /// Returns the number of elements in the collection.
    ///
    /// This property is an alias for `count` that can improve readability
    /// in certain contexts, especially when chaining methods.
    ///
    /// # Usage Example
    /// ```swift
    /// let items = [1, 2, 3]
    /// print(items.length)  // 3
    /// ```
    var length: Int {
        return count
    }

    /// Returns `true` if the collection has exactly one element.
    ///
    /// # Usage Example
    /// ```swift
    /// let single = [42]
    /// let multiple = [1, 2, 3]
    /// let empty: [Int] = []
    ///
    /// print(single.hasSingleElement)   // true
    /// print(multiple.hasSingleElement) // false
    /// print(empty.hasSingleElement)    // false
    /// ```
    var hasSingleElement: Bool {
        return count == 1
    }

    /// Returns `true` if the collection has more than one element.
    ///
    /// # Usage Example
    /// ```swift
    /// let single = [42]
    /// let multiple = [1, 2, 3]
    ///
    /// print(single.hasMultipleElements)   // false
    /// print(multiple.hasMultipleElements) // true
    /// ```
    var hasMultipleElements: Bool {
        return count > 1
    }

    /// Returns `true` if the collection has at least the specified number of elements.
    ///
    /// - Parameter minimum: The minimum number of elements required.
    /// - Returns: `true` if `count >= minimum`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let items = [1, 2, 3, 4, 5]
    /// print(items.hasAtLeast(3))  // true
    /// print(items.hasAtLeast(10)) // false
    /// ```
    func hasAtLeast(_ minimum: Int) -> Bool {
        return count >= minimum
    }

    /// Returns `true` if the collection has at most the specified number of elements.
    ///
    /// - Parameter maximum: The maximum number of elements allowed.
    /// - Returns: `true` if `count <= maximum`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let items = [1, 2, 3]
    /// print(items.hasAtMost(3))  // true
    /// print(items.hasAtMost(2))  // false
    /// ```
    func hasAtMost(_ maximum: Int) -> Bool {
        return count <= maximum
    }

    /// Returns `true` if the collection has exactly the specified number of elements.
    ///
    /// - Parameter count: The exact number of elements required.
    /// - Returns: `true` if the collection's count equals the specified count.
    ///
    /// # Usage Example
    /// ```swift
    /// let items = [1, 2, 3]
    /// print(items.hasExactly(3))  // true
    /// print(items.hasExactly(2))  // false
    /// ```
    func hasExactly(_ count: Int) -> Bool {
        return self.count == count
    }

    /// Returns the first element if the collection is not empty, otherwise `nil`.
    ///
    /// This property provides a safe way to access the first element
    /// without needing to check `isEmpty` first.
    ///
    /// # Usage Example
    /// ```swift
    /// let numbers = [1, 2, 3]
    /// let empty: [Int] = []
    ///
    /// print(numbers.firstIfNotEmpty)  // Optional(1)
    /// print(empty.firstIfNotEmpty)    // nil
    /// ```
    var firstIfNotEmpty: Element? {
        return isEmpty ? nil : first
    }

    /// Returns a random element if the collection is not empty, otherwise `nil`.
    ///
    /// # Usage Example
    /// ```swift
    /// let numbers = [1, 2, 3]
    /// let empty: [Int] = []
    ///
    /// print(numbers.randomIfNotEmpty)  // Optional(1 or 2 or 3)
    /// print(empty.randomIfNotEmpty)    // nil
    /// ```
    var randomIfNotEmpty: Element? {
        return isEmpty ? nil : randomElement()
    }
}


// MARK: - Usage Examples

#if DEBUG
public struct CollectionExtensionExamples {

    public static func demonstrate() {
        print("📚 Collection Extension Examples")
        print("=" * 50)

        // Array examples
        print("\n📦 Array Examples:")
        let numbers = [1, 2, 3]
        let emptyArray: [Int] = []

        print("numbers.isNotEmpty: \(numbers.isNotEmpty)") // true
        print("emptyArray.isNotEmpty: \(emptyArray.isNotEmpty)") // false
        print("numbers.hasSingleElement: \(numbers.hasSingleElement)") // false
        print("[42].hasSingleElement: \([42].hasSingleElement)") // true
        print("numbers.hasAtLeast(2): \(numbers.hasAtLeast(2))") // true
        print("numbers[safe: 1]: \(numbers[safe: 1] ?? -1)") // 2
        print("numbers[safe: 10]: \(numbers[safe: 10] ?? -1)") // -1

        // String examples
        print("\n📝 String Examples:")
        let text = "Hello World"
        let emptyString = ""
        let whitespace = "   \n\t"

        print("text.isNotEmpty: \(text.isNotEmpty)") // true
        print("emptyString.isNotEmpty: \(emptyString.isNotEmpty)") // false
        print("text.isNotEmptyAfterTrim: \(text.isNotEmptyAfterTrim)") // true
        print("whitespace.isNotEmptyAfterTrim: \(whitespace.isNotEmptyAfterTrim)") // false
        print("whitespace.isWhitespaceOnly: \(whitespace.isWhitespaceOnly)") // true
        print("text.containsDigits: \(text.containsDigits)") // false
        print("text.containsLetters: \(text.containsLetters)") // true

        // Set examples
        print("\n🎯 Set Examples:")
        let numberSet: Set = [1, 2, 3]
        let emptySet: Set<Int> = []

        print("numberSet.isNotEmpty: \(numberSet.isNotEmpty)") // true
        print("emptySet.isNotEmpty: \(emptySet.isNotEmpty)") // false
        print("numberSet.has(2): \(numberSet.has(2))") // true

        // Dictionary examples
        print("\n📖 Dictionary Examples:")
        let dict:[String: Any] = ["name": "John", "age": 30]
        let emptyDict: [String: Any] = [:]

        print("dict.isNotEmpty: \(dict.isNotEmpty)") // true
        print("emptyDict.isNotEmpty: \(emptyDict.isNotEmpty)") // false
        print("dict.hasKey(\"name\"): \(dict.hasKey("name"))") // true
        print("dict.hasKey(\"city\"): \(dict.hasKey("city"))") // false

        // Method chaining example
        print("\n🔗 Method Chaining Example:")
        let strings = ["Hello", "", "World", "   ", "Swift"]
        let meaningfulStrings = strings
            .compactMap { $0.nilIfEmptyAfterTrim }
            .filter { $0.isNotEmpty && $0.containsLetters }

        print("Original: \(strings)")
        print("Meaningful: \(meaningfulStrings)")
    }
}

#endif
