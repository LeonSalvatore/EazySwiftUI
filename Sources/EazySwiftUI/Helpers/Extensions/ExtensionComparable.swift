//
//  ExtensionComparable.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 27.12.2025.


import SwiftUI

// MARK: - Comparable Extension

/// Extension providing useful utility methods for `Comparable` types.
///
/// This extension adds convenience methods for common comparison operations,
/// range checking, clamping, and value validation, improving code readability
/// and reducing boilerplate.
public extension Comparable {

    // MARK: - Equality & Comparison

    /// Returns a Boolean value indicating whether two comparable instances are equal.
    ///
    /// This method provides a more readable alternative to the `==` operator
    /// when you want to store or explicitly work with a Boolean result.
    ///
    /// - Parameter other: Another instance of the same type to compare.
    /// - Returns: `true` if the two instances are equal; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = 5
    /// let b = 5
    /// let c = 10
    ///
    /// let isEqual = a.isEqual(to: b)  // true
    /// let isNotEqual = a.isEqual(to: c) // false
    ///
    /// // Equivalent to:
    /// let alsoEqual = (a == b)  // true
    /// ```
    ///
    /// - Note: This method is functionally equivalent to the `==` operator
    ///   but returns the result as a `Bool` value directly.
    /// - SeeAlso: `==` operator, `Equatable` protocol
    func isEqual(to other: Self) -> Bool {
        return self == other
    }

    /// Returns a Boolean value indicating whether the instance is less than another.
    ///
    /// - Parameter other: Another instance of the same type to compare.
    /// - Returns: `true` if this instance is less than `other`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = 5
    /// let b = 10
    ///
    /// let isLess = a.isLess(than: b)  // true
    /// ```
    func isLess(than other: Self) -> Bool {
        return self < other
    }

    /// Returns a Boolean value indicating whether the instance is greater than another.
    ///
    /// - Parameter other: Another instance of the same type to compare.
    /// - Returns: `true` if this instance is greater than `other`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = 15
    /// let b = 10
    ///
    /// let isGreater = a.isGreater(than: b)  // true
    /// ```
    func isGreater(than other: Self) -> Bool {
        return self > other
    }

    /// Returns a Boolean value indicating whether the instance is less than or equal to another.
    ///
    /// - Parameter other: Another instance of the same type to compare.
    /// - Returns: `true` if this instance is less than or equal to `other`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = 5
    /// let b = 5
    /// let c = 10
    ///
    /// let isLessOrEqual1 = a.isLessOrEqual(to: b)  // true
    /// let isLessOrEqual2 = a.isLessOrEqual(to: c)  // true
    /// ```
    func isLessOrEqual(to other: Self) -> Bool {
        return self <= other
    }

    /// Returns a Boolean value indicating whether the instance is greater than or equal to another.
    ///
    /// - Parameter other: Another instance of the same type to compare.
    /// - Returns: `true` if this instance is greater than or equal to `other`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = 10
    /// let b = 10
    /// let c = 5
    ///
    /// let isGreaterOrEqual1 = a.isGreaterOrEqual(to: b)  // true
    /// let isGreaterOrEqual2 = a.isGreaterOrEqual(to: c)  // true
    /// ```
    func isGreaterOrEqual(to other: Self) -> Bool {
        return self >= other
    }

    /// Returns a Boolean value indicating whether the instance is between two other values (inclusive).
    ///
    /// - Parameters:
    ///   - lower: The lower bound of the range.
    ///   - upper: The upper bound of the range.
    /// - Returns: `true` if the instance is between `lower` and `upper` (inclusive); otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let value = 7
    /// let isInRange = value.isBetween(1, and: 10)  // true
    /// let isNotInRange = value.isBetween(10, and: 20)  // false
    /// ```
    func isBetween(_ lower: Self, and upper: Self) -> Bool {
        return self >= lower && self <= upper
    }

    /// Returns a Boolean value indicating whether the instance is between two other values (exclusive).
    ///
    /// - Parameters:
    ///   - lower: The lower bound of the range.
    ///   - upper: The upper bound of the range.
    /// - Returns: `true` if the instance is strictly between `lower` and `upper`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let value = 7
    /// let isInRange = value.isStrictlyBetween(1, and: 10)  // true
    /// let isNotInRange = value.isStrictlyBetween(7, and: 10)  // false (equal to lower bound)
    /// ```
    func isStrictlyBetween(_ lower: Self, and upper: Self) -> Bool {
        return self > lower && self < upper
    }

    // MARK: - Value Clamping

    /// Returns the value clamped to the specified range.
    ///
    /// If the value is less than the lower bound, returns the lower bound.
    /// If the value is greater than the upper bound, returns the upper bound.
    /// Otherwise, returns the value itself.
    ///
    /// - Parameters:
    ///   - lower: The minimum allowed value.
    ///   - upper: The maximum allowed value.
    /// - Returns: The clamped value.
    ///
    /// # Usage Example
    /// ```swift
    /// let value = 15
    /// let clamped = value.clamped(to: 0...10)  // 10
    ///
    /// let negativeValue = -5
    /// let clampedNegative = negativeValue.clamped(to: 0...10)  // 0
    /// ```
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }

    /// Returns the value clamped to the specified range.
    ///
    /// - Parameters:
    ///   - lower: The minimum allowed value.
    ///   - upper: The maximum allowed value.
    /// - Returns: The clamped value.
    ///
    /// # Usage Example
    /// ```swift
    /// let value = 15
    /// let clamped = value.clamped(between: 0, and: 10)  // 10
    /// ```
    func clamped(between lower: Self, and upper: Self) -> Self {
        return min(max(self, lower), upper)
    }

    /// Returns the value clamped to be at least the specified minimum.
    ///
    /// - Parameter min: The minimum allowed value.
    /// - Returns: The value, or `min` if the value is less than `min`.
    ///
    /// # Usage Example
    /// ```swift
    /// let value = -5
    /// let atLeastZero = value.clamped(min: 0)  // 0
    ///
    /// let positiveValue = 5
    /// let stillFive = positiveValue.clamped(min: 0)  // 5
    /// ```
    func clamped(min: Self) -> Self {
        return Swift.max(self, min)
    }

    /// Returns the value clamped to be at most the specified maximum.
    ///
    /// - Parameter max: The maximum allowed value.
    /// - Returns: The value, or `max` if the value is greater than `max`.
    ///
    /// # Usage Example
    /// ```swift
    /// let value = 15
    /// let atMostTen = value.clamped(max: 10)  // 10
    ///
    /// let smallValue = 5
    /// let stillFive = smallValue.clamped(max: 10)  // 5
    /// ```
    func clamped(max: Self) -> Self {
        return Swift.min(self, max)
    }

    // MARK: - Distance & Proximity

    /// Returns the absolute distance between two values.
    ///
    /// - Parameter other: Another instance of the same type.
    /// - Returns: The absolute difference between the two values.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = 10
    /// let b = 7
    /// let distance = a.distance(to: b)  // 3
    ///
    /// let x = -5
    /// let y = 3
    /// let negativeDistance = x.distance(to: y)  // 8
    /// ```
    func distance(to other: Self) -> Self where Self: SignedNumeric {
        return abs(self - other)
    }

    /// Returns a Boolean value indicating whether the instance is within a specified distance of another value.
    ///
    /// - Parameters:
    ///   - other: Another instance of the same type.
    ///   - tolerance: The maximum allowed distance.
    /// - Returns: `true` if the distance between the values is less than or equal to `tolerance`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = 10.0
    /// let b = 10.5
    /// let isClose = a.isWithin(0.6, of: b)  // true
    /// let isNotClose = a.isWithin(0.4, of: b)  // false
    /// ```
    func isWithin(_ tolerance: Self, of other: Self) -> Bool where Self: SignedNumeric {
        return distance(to: other) <= tolerance
    }

    // MARK: - Sorting & Ordering

    /// Returns the minimum of this value and another.
    ///
    /// - Parameter other: Another instance of the same type.
    /// - Returns: The smaller of the two values.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = 5
    /// let b = 10
    /// let minimum = a.minimum(with: b)  // 5
    /// ```
    func minimum(with other: Self) -> Self {
        return Swift.min(self, other)
    }

    /// Returns the maximum of this value and another.
    ///
    /// - Parameter other: Another instance of the same type.
    /// - Returns: The larger of the two values.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = 5
    /// let b = 10
    /// let maximum = a.maximum(with: b)  // 10
    /// ```
    func maximum(with other: Self) -> Self {
        return Swift.max(self, other)
    }

    /// Returns the value sorted relative to another value.
    ///
    /// - Parameter other: Another instance of the same type.
    /// - Returns: A tuple containing the values in sorted order (smaller first).
    ///
    /// # Usage Example
    /// ```swift
    /// let a = 10
    /// let b = 5
    /// let (smaller, larger) = a.sorted(with: b)  // (5, 10)
    /// ```
    func sorted(with other: Self) -> (Self, Self) {
        return self < other ? (self, other) : (other, self)
    }

    // MARK: - Validation

    /// Returns a Boolean value indicating whether the instance is positive.
    ///
    /// - Returns: `true` if the value is greater than zero; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let positive = 5.isPositive()  // true
    /// let negative = (-5).isPositive()  // false
    /// let zero = 0.isPositive()  // false
    /// ```
    func isPositive() -> Bool where Self: SignedNumeric {
        return self > 0
    }

    /// Returns a Boolean value indicating whether the instance is negative.
    ///
    /// - Returns: `true` if the value is less than zero; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let positive = 5.isNegative()  // false
    /// let negative = (-5).isNegative()  // true
    /// let zero = 0.isNegative()  // false
    /// ```
    func isNegative() -> Bool where Self: SignedNumeric {
        return self < 0
    }

    /// Returns a Boolean value indicating whether the instance is zero.
    ///
    /// - Returns: `true` if the value is equal to zero; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let zero = 0.isZero()  // true
    /// let nonZero = 5.isZero()  // false
    /// ```
    func isZero() -> Bool where Self: Numeric {
        return self == 0
    }

    /// Returns a Boolean value indicating whether the instance is not zero.
    ///
    /// - Returns: `true` if the value is not equal to zero; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let zero = 0.isNotZero()  // false
    /// let nonZero = 5.isNotZero()  // true
    /// ```
    func isNotZero() -> Bool where Self: Numeric {
        return self != 0
    }
}

// MARK: - Optional Comparable Extension

extension Optional where Wrapped: Comparable {

    /// Compares two optional comparable values with a fallback for nil values.
    ///
    /// This method compares optional values, treating `nil` as less than any non-nil value.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand optional value.
    ///   - rhs: The right-hand optional value.
    /// - Returns: `true` if `lhs` should be ordered before `rhs`; otherwise, `false`.
    ///
    /// # Comparison Rules
    /// 1. `nil` is always less than any non-nil value
    /// 2. Two `nil` values are equal
    /// 3. Two non-nil values are compared normally
    ///
    /// # Usage Example
    /// ```swift
    /// let a: Int? = 5
    /// let b: Int? = 10
    /// let c: Int? = nil
    ///
    /// let result1 = a < b  // true
    /// let result2 = c < a  // true (nil < 5)
    /// let result3 = b < c  // false (10 is not < nil)
    /// ```
    static func < (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        switch (lhs, rhs) {
        case (nil, _): return true  // nil < anything
        case (_, nil): return false // anything > nil
        case (let left?, let right?): return left < right
        }
    }

    /// Returns a Boolean value indicating whether the optional is nil or satisfies a condition.
    ///
    /// - Parameter condition: A closure that takes an unwrapped value and returns a Boolean.
    /// - Returns: `true` if the optional is nil or the condition returns true; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let value: Int? = 5
    /// let nilValue: Int? = nil
    ///
    /// let isValid = value.isNilOr { $0 > 0 }  // true
    /// let isAlsoValid = nilValue.isNilOr { $0 > 0 }  // true
    /// let isInvalid = value.isNilOr { $0 > 10 }  // false
    /// ```
    func isNilOr(_ condition: (Wrapped) -> Bool) -> Bool {
        switch self {
        case .none: return true
        case .some(let value): return condition(value)
        }
    }
}

// MARK: - Usage Examples & Documentation

#if DEBUG
/// Demonstrates the usage of Comparable extension methods.
public struct ComparableExamples {

    /// Runs all examples to demonstrate the functionality.
    public static func demonstrateAll() {
        print("🔍 Comparable Extension Examples")
        print("=" * 50)

        demonstrateBasicComparisons()
        demonstrateRangeChecking()
        demonstrateClamping()
        demonstrateDistanceAndProximity()
        demonstrateSortingAndValidation()
        demonstrateOptionalComparisons()
    }

    private static func demonstrateBasicComparisons() {
        print("\n📊 Basic Comparisons:")
        let a = 10, b = 20

        print("\(a).isLess(than: \(b)): \(a.isLess(than: b))")
        print("\(a).isGreater(than: \(b)): \(a.isGreater(than: b))")
        print("\(a).isEqual(to: \(b)): \(a.isEqual(to: b))")
        print("\(a).isBetween(5, and: 15): \(a.isBetween(5, and: 15))")
    }

    private static func demonstrateRangeChecking() {
        print("\n🎯 Range Checking:")
        let value = 7.5

        print("\(value).isBetween(0, and: 10): \(value.isBetween(0, and: 10))")
        print("\(value).isStrictlyBetween(0, and: 10): \(value.isStrictlyBetween(0, and: 10))")
        print("\(value).isStrictlyBetween(7.5, and: 10): \(value.isStrictlyBetween(7.5, and: 10))")
    }

    private static func demonstrateClamping() {
        print("\n🔒 Clamping:")
        let values = [-5, 5, 15]

        for value in values {
            let clamped = value.clamped(between: 0, and: 10)
            print("\(value).clamped(between: 0, and: 10) = \(clamped)")
        }

        let doubleValue = 12.7
        let rangeClamped = doubleValue.clamped(to: 0.0...10.0)
        print("\(doubleValue).clamped(to: 0.0...10.0) = \(rangeClamped)")
    }

    private static func demonstrateDistanceAndProximity() {
        print("\n📏 Distance & Proximity:")
        let a = 10.0, b = 12.5

        print("\(a).distance(to: \(b)) = \(a.distance(to: b))")
        print("\(a).isWithin(2.6, of: \(b)): \(a.isWithin(2.6, of: b))")
        print("\(a).isWithin(2.4, of: \(b)): \(a.isWithin(2.4, of: b))")
    }

    private static func demonstrateSortingAndValidation() {
        print("\n📈 Sorting & Validation:")

        // Sorting
        let (smaller, larger) = 15.sorted(with: 10)
        print("15.sorted(with: 10) = (\(smaller), \(larger))")

        // Validation
        print("5.isPositive(): \(5.isPositive())")
        print("(-5).isNegative(): \((-5).isNegative())")
        print("0.isZero(): \(0.isZero())")
        print("5.isNotZero(): \(5.isNotZero())")
    }

    private static func demonstrateOptionalComparisons() {
        print("\n❓ Optional Comparisons:")
        let someValue: Int? = 5
        let otherValue: Int? = 10
        let nilValue: Int? = nil

        print("\(String(describing: someValue)) < \(String(describing: otherValue)): \(someValue < otherValue)")
        print("\(String(describing: nilValue)) < \(String(describing: someValue)): \(nilValue < someValue)")

        print("nilValue.isNilOr { $0 > 0 }: \(nilValue.isNilOr { $0 > 0 })")
        print("someValue.isNilOr { $0 > 0 }: \(someValue.isNilOr { $0 > 0 })")
        print("someValue.isNilOr { $0 > 10 }: \(someValue.isNilOr { $0 > 10 })")
    }
}
#endif
