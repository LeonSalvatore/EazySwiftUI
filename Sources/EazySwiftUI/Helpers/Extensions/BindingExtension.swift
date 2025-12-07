//
//  BindingExtension.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 07.12.2025.
//

import SwiftUI

public extension Binding where Value: Hashable {
    /// Creates a `Binding` to a reference type’s writable key path.
    ///
    /// This initializer allows you to bind SwiftUI state directly to a property
    /// of a reference type (`class`) by providing both the object instance and
    /// the `ReferenceWritableKeyPath` that points to the target value.
    ///
    /// Use this when you need a `Binding<Value>` but the underlying storage
    /// lives in an object rather than a SwiftUI `@State` or `@Observable`.
    ///
    /// - Parameters:
    ///   - object: The reference-type instance whose property you want to bind.
    ///   - target: A `ReferenceWritableKeyPath` specifying the property on `object`
    ///     to read and write.
    ///
    /// - Note: `Value` must conform to both `Hashable` and `Sendable`.
    ///
    /// - Example:
    ///   ```swift
    ///   @Observable
    ///   class Settings {
    ///       var isEnabled: Bool = false
    ///   }
    ///
    ///   let settings = Settings()
    ///   let binding = Binding(object: settings, target: \.isEnabled)
    ///   ```
    ///
    /// This binding will now stay in sync with `settings.isEnabled`.
    init<T: AnyObject & Sendable>(object: T, keyPath: ReferenceWritableKeyPath<T, Value>) {
        self.init(
            get: { object[keyPath: keyPath] },
            set: { object[keyPath: keyPath] = $0 }
        )
    }
}

public extension Binding {

    /// Creates a `Binding` to a nested optional value inside an optional model,
    /// providing a default value when the source or nested property is `nil`.
    ///
    /// This initializer is useful when you want to bind to a property located
    /// inside an optional container (`Binding<T?>`). If the container or the
    /// nested property is `nil`, the binding falls back to a supplied default
    /// value. Optionally, you can provide a `defaultInstance` to automatically
    /// create the container if it does not exist when writing.
    ///
    /// - Parameters:
    ///   - optionalSource: A binding to an optional root model (`T?`) that may or may not exist.
    ///   - keyPath: The writable key path from `T` to an optional property of type `Value`.
    ///   - defaultValue: The value returned when either the source model or the nested
    ///     property is `nil`.
    ///   - defaultInstance: An optional closure that creates a new instance of `T` when
    ///     writing to a `nil` source. If omitted, write operations are ignored when the
    ///     source is `nil`.
    ///
    /// - Discussion:
    ///   Use this initializer when you want to work with optional structured data
    ///   while maintaining SwiftUI bindings. It helps avoid rewriting complex optional
    ///   unwrapping logic and keeps the UI consistent even when the backing model
    ///   hasn't been initialized yet.
    ///
    /// - Example:
    ///   ```swift
    ///   struct Profile {
    ///       var nickname: String?
    ///   }
    ///
    ///   @State private var profile: Profile? = nil
    ///
    ///   let nicknameBinding = Binding(
    ///       from: $profile,
    ///       keyPath: \.nickname,
    ///       default: "Guest",
    ///       defaultInstance: { Profile() }
    ///   )
    ///   ```
    ///   In this example, editing the nickname will automatically create a new
    ///   `Profile` instance if `profile` is initially `nil`.
        init<T>(
            from optionalSource: Binding<T?>,
            keyPath: WritableKeyPath<T, Value?>,
            default defaultValue: Value,
            defaultInstance: (() -> T)? = nil
        ) {
            self.init(
                get: {
                    optionalSource.wrappedValue?[keyPath: keyPath] ?? defaultValue
                },
                set: { newValue in
                    if var source = optionalSource.wrappedValue {
                        source[keyPath: keyPath] = newValue
                        optionalSource.wrappedValue = source
                    } else if let defaultInstance = defaultInstance {
                        // Create new instance if provider exists
                        var newInstance = defaultInstance()
                        newInstance[keyPath: keyPath] = newValue
                        optionalSource.wrappedValue = newInstance
                    }
                    // If no provider, changes are ignored when source is nil
                }
            )
        }

}

