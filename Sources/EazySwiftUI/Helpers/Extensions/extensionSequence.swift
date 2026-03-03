//
//  extension Sequence.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 25.02.2026.
//

import Foundation


public extension Sequence {

    /// Groups the elements of this sequence into a dictionary,
    /// keyed by the value at the specified key path.
    ///
    /// - Parameter keyPath: A key path from an element to a hashable key
    ///   used to determine the grouping.
    ///
    /// - Returns: A dictionary where each key is a distinct value
    ///   extracted from the sequence, and the value is an array
    ///   of elements that share that key.
    ///
    /// - Complexity: O(*n*), where *n* is the number of elements.
    ///
    /// - Note: The order of keys in the resulting dictionary is not guaranteed.
    func grouped<Key: Hashable>(
        by keyPath: KeyPath<Element, Key>
    ) -> [Key: [Element]] {
        Dictionary(grouping: self) { element in
            element[keyPath: keyPath]
        }
    }

    /// Groups the elements of this sequence and returns the result
    /// sorted by key in ascending order.
    ///
    /// - Parameter keyPath: A key path from an element to a hashable
    ///   and comparable key used for grouping and sorting.
    ///
    /// - Returns: An array of `(key, values)` tuples sorted by key.
    ///
    /// - Complexity:
    ///   - Grouping: O(*n*)
    ///   - Sorting: O(*k* log *k*)
    ///   where *n* is the number of elements and *k* is the number of distinct keys.
    ///
    /// - Important: This method returns an ordered array instead of a dictionary
    ///   to guarantee deterministic ordering.
    func groupedSorted<Key: Hashable & Comparable>(
        by keyPath: KeyPath<Element, Key>
    ) -> [(key: Key, values: [Element])] {

        let dictionary = grouped(by: keyPath)

        return dictionary
            .sorted { $0.key < $1.key }
            .map { (key: $0.key, values: $0.value) }
    }

    /// Groups the elements of this sequence while preserving
    /// the order of first key appearance.
    ///
    /// - Parameter keyPath: A key path from an element to a hashable key
    ///   used to determine grouping.
    ///
    /// - Returns: An array of `(key, values)` tuples where:
    ///   - Keys appear in the order they are first encountered.
    ///   - Elements inside each group preserve their original order.
    ///
    /// - Complexity: O(*n*)
    ///
    /// - Use Case: Particularly useful for UI section rendering
    ///   (e.g., SwiftUI `ForEach`) when stable ordering is required.
    func groupedStable<Key: Hashable>(
        by keyPath: KeyPath<Element, Key>
    ) -> [(key: Key, values: [Element])] {

        var dict: [Key: [Element]] = [:]
        var order: [Key] = []

        for element in self {
            let key = element[keyPath: keyPath]

            if dict[key] == nil {
                order.append(key)
                dict[key] = []
            }

            dict[key]?.append(element)
        }

        return order.map { key in
            (key: key, values: dict[key]!)
        }
    }
}

public extension AsyncSequence {
    /// Groups the elements of the asynchronous sequence by a key path, preserving the original order of first occurrence for each key.
    ///
    /// This method collects all elements from the asynchronous sequence and groups them by the specified key path.
    /// Unlike a standard dictionary-based grouping, this method maintains the order of keys based on their first
    /// appearance in the sequence, making it "stable" and predictable.
    ///
    /// - Parameter keyPath: A key path that provides a hashable key for each element in the sequence.
    /// - Returns: An array of tuples where each tuple contains a unique key and an array of elements that share that key.
    ///            The keys are ordered by their first occurrence in the original sequence.
    /// - Throws: Rethrows any errors encountered while iterating the asynchronous sequence.
    ///
    /// - Complexity: O(n) where n is the number of elements in the sequence.
    ///
    /// # Example #
    /// ```swift
    /// struct Person {
    ///     let name: String
    ///     let department: String
    /// }
    ///
    /// let people = [
    ///     Person(name: "Alice", department: "Engineering"),
    ///     Person(name: "Bob", department: "Marketing"),
    ///     Person(name: "Charlie", department: "Engineering")
    /// ].async
    ///
    /// let grouped = await people.groupedStable(by: \.department)
    /// // Result: [
    /// //   (key: "Engineering", values: [Alice, Charlie]),
    /// //   (key: "Marketing", values: [Bob])
    /// // ]
    /// // Note: "Engineering" appears first because Alice was encountered before Bob
    /// ```
    ///
    /// - Note: This method collects all elements into memory before returning. For very large sequences,
    ///         consider using incremental processing to manage memory usage.
    /// - Important: The grouping is "stable" meaning the order of keys in the returned array matches
    ///              the order of their first appearance in the original sequence.
    func groupedStable<Key: Hashable>(
        by keyPath: KeyPath<Element, Key>
    ) async rethrows -> [(key: Key, values: [Element])] {

        var dict: [Key: [Element]] = [:]
        var order: [Key] = []

        for try await element in self {
            let key = element[keyPath: keyPath]

            if dict[key] == nil {
                order.append(key)
                dict[key] = []
            }

            dict[key]?.append(element)
        }

        return order.map { key in
            (key: key, values: dict[key]!)
        }
    }
}
