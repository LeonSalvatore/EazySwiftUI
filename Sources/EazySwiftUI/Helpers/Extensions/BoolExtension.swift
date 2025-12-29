//
//  BoolExtension.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 27.12.2025.
//


public extension Bool {
    
    /// Returns `true` if the boolean value is `false`, and `false` if the boolean value is `true`.
    ///
    /// This property provides a more readable alternative to the `!` (not) operator
    /// when checking for false values, especially in property chains.
    ///
    /// # Usage Examples
    ///
    /// ```swift
    /// let isEmpty = false
    /// print(isEmpty.isNotEmpty)  // true
    ///
    /// let hasContent = true
    /// print(hasContent.isNotEmpty)  // false
    ///
    /// // Alternative to:
    /// let alternative = !isEmpty  // true
    /// ```
    ///
    /// - Note: This property is equivalent to the logical NOT operator (`!self`).
    ///   It's provided for improved readability in certain contexts.
    var isNotEmpty: Bool {
        return !self
    }
    
    /// Returns `true` if the boolean value is `true`.
    ///
    /// This property might seem redundant, but it can improve readability
    /// in method chains and when working with optional booleans.
    ///
    /// # Usage Example
    /// ```swift
    /// let isValid = true
    /// print(isValid.isEmpty)  // false
    ///
    /// // With optional chaining:
    /// optionalBool?.isEmpty  // instead of optionalBool == false
    /// ```
    var isEmpty: Bool {
        return !self
    }
    
    /// Returns the inverted boolean value.
    ///
    /// This property provides a fluent interface for boolean negation.
    ///
    /// # Usage Example
    /// ```swift
    /// let isEnabled = true
    /// let isDisabled = isEnabled.inverted  // false
    ///
    /// // Method chaining:
    /// someCondition
    ///     .inverted
    ///     .isNotEmpty  // etc.
    /// ```
    var inverted: Bool {
        return !self
    }
    
    /// Returns the boolean value unchanged.
    ///
    /// This property can be useful for consistency in method chains
    /// or when you need to reference the value as a property.
    var isTrue: Bool {
        return self
    }
    
    /// Returns the negated boolean value.
    ///
    /// This property can be useful for consistency in method chains
    /// or when you need to reference the negated value as a property.
    var isFalse: Bool {
        return !self
    }
    
    /// Toggles the boolean value and returns the new value.
    ///
    /// This method provides a functional alternative to mutating toggle().
    ///
    /// # Usage Example
    /// ```swift
    /// var flag = true
    /// flag = flag.toggled()  // false
    /// flag = flag.toggled()  // true
    /// ```
    func toggled() -> Bool {
        return !self
    }
    
    /// Returns the result of applying a logical AND operation with another boolean.
    ///
    /// - Parameter other: Another boolean value.
    /// - Returns: `true` if both values are `true`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = true
    /// let b = false
    /// let result = a.and(b)  // false
    /// ```
    func and(_ other: Bool) -> Bool {
        return self && other
    }
    
    /// Returns the result of applying a logical OR operation with another boolean.
    ///
    /// - Parameter other: Another boolean value.
    /// - Returns: `true` if at least one value is `true`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = true
    /// let b = false
    /// let result = a.or(b)  // true
    /// ```
    func or(_ other: Bool) -> Bool {
        return self || other
    }
    
    /// Returns the result of applying a logical XOR (exclusive OR) operation with another boolean.
    ///
    /// - Parameter other: Another boolean value.
    /// - Returns: `true` if exactly one value is `true`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = true
    /// let b = false
    /// let result = a.xor(b)  // true
    ///
    /// let bothTrue = true.xor(true)  // false
    /// let bothFalse = false.xor(false)  // false
    /// ```
    func xor(_ other: Bool) -> Bool {
        return self != other
    }
    
    /// Returns the result of applying a logical NAND operation with another boolean.
    ///
    /// - Parameter other: Another boolean value.
    /// - Returns: `false` if both values are `true`; otherwise, `true`.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = true
    /// let b = false
    /// let result = a.nand(b)  // true
    ///
    /// let bothTrue = true.nand(true)  // false
    /// ```
    func nand(_ other: Bool) -> Bool {
        return !(self && other)
    }
    
    /// Returns the result of applying a logical NOR operation with another boolean.
    ///
    /// - Parameter other: Another boolean value.
    /// - Returns: `true` if both values are `false`; otherwise, `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let a = true
    /// let b = false
    /// let result = a.nor(b)  // false
    ///
    /// let bothFalse = false.nor(false)  // true
    /// ```
    func nor(_ other: Bool) -> Bool {
        return !(self || other)
    }
}

// MARK: - Optional Bool Extension

extension Optional where Wrapped == Bool {
    
    /// Returns `true` if the optional boolean is `true`, `false` if it's `false` or `nil`.
    ///
    /// This property provides safe access to optional booleans with a default of `false`.
    ///
    /// # Usage Example
    /// ```swift
    /// let optionalTrue: Bool? = true
    /// let optionalFalse: Bool? = false
    /// let optionalNil: Bool? = nil
    ///
    /// print(optionalTrue.isTrue)      // true
    /// print(optionalFalse.isTrue)     // false
    /// print(optionalNil.isTrue)       // false
    /// ```
    var isTrue: Bool {
        return self == true
    }
    
    /// Returns `true` if the optional boolean is `false`, `false` if it's `true` or `nil`.
    ///
    /// # Usage Example
    /// ```swift
    /// let optionalTrue: Bool? = true
    /// let optionalFalse: Bool? = false
    /// let optionalNil: Bool? = nil
    ///
    /// print(optionalTrue.isFalse)     // false
    /// print(optionalFalse.isFalse)    // true
    /// print(optionalNil.isFalse)      // false
    /// ```
    var isFalse: Bool {
        return self == false
    }
    
    /// Returns `true` if the optional boolean is `nil`.
    var isNil: Bool {
        return self == nil
    }
    
    /// Returns the boolean value with a default if nil.
    ///
    /// - Parameter defaultValue: The value to return if the optional is `nil`.
    /// - Returns: The boolean value, or `defaultValue` if nil.
    ///
    /// # Usage Example
    /// ```swift
    /// let optionalBool: Bool? = nil
    /// let value = optionalBool.value(or: true)  // true
    /// ```
    func value(or defaultValue: Bool) -> Bool {
        return self ?? defaultValue
    }
}

// MARK: - Usage Examples

#if DEBUG
public struct BoolExtensionExamples {

    public static func demonstrate() {
        print("🔘 Bool Extension Examples")
        print("=" * 50)
        
        // Basic properties
        let trueValue = true
        let falseValue = false
        
        print("true.isNotEmpty: \(trueValue.isNotEmpty)") // false
        print("false.isNotEmpty: \(falseValue.isNotEmpty)") // true
        print("true.isEmpty: \(trueValue.isEmpty)") // false
        print("false.isEmpty: \(falseValue.isEmpty)") // true
        print("true.inverted: \(trueValue.inverted)") // false
        print("false.inverted: \(falseValue.inverted)") // true
        
        // Logical operations
        print("\nLogical Operations:")
        print("true.and(false): \(trueValue.and(falseValue))") // false
        print("true.or(false): \(trueValue.or(falseValue))") // true
        print("true.xor(false): \(trueValue.xor(falseValue))") // true
        print("true.xor(true): \(trueValue.xor(true))") // false
        print("true.nand(false): \(trueValue.nand(falseValue))") // true
        print("true.nor(false): \(trueValue.nor(falseValue))") // false
        
        // Optional bool
        print("\nOptional Bool:")
        let optionalTrue: Bool? = true
        let optionalFalse: Bool? = false
        let optionalNil: Bool? = nil
        
        print("optionalTrue.isTrue: \(optionalTrue.isTrue)") // true
        print("optionalFalse.isTrue: \(optionalFalse.isTrue)") // false
        print("optionalNil.isTrue: \(optionalNil.isTrue)") // false
        print("optionalNil.value(or: true): \(optionalNil.value(or: true))") // true
    }
}
#endif
