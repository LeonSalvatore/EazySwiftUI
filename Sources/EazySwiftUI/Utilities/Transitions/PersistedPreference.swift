//
//  PersistedPreference.swift
//  EazySwiftUI
//

import Foundation
import Observation

/// An observable string-backed preference stored in `UserDefaults`.
///
/// This is useful for app themes, display modes, languages, and other
/// `RawRepresentable` selections. The application owns the value type and the
/// storage key; EazySwiftUI owns persistence and observation.
@MainActor
@Observable
public final class PersistedPreference<Value>
where Value: RawRepresentable & Equatable, Value.RawValue == String {
    public private(set) var value: Value

    @ObservationIgnored private let key: String
    @ObservationIgnored private let defaults: UserDefaults

    public init(
        key: String,
        defaultValue: Value,
        defaults: UserDefaults = .standard
    ) {
        self.key = key
        self.defaults = defaults
        if let rawValue = defaults.string(forKey: key),
           let storedValue = Value(rawValue: rawValue) {
            self.value = storedValue
        } else {
            self.value = defaultValue
        }
    }

    /// Selects and persists a new value. Selecting the current value is a no-op.
    public func select(_ value: Value) {
        guard self.value != value else { return }
        self.value = value
        defaults.set(value.rawValue, forKey: key)
    }

    /// Removes the stored value and restores the supplied default.
    public func reset(to defaultValue: Value) {
        defaults.removeObject(forKey: key)
        value = defaultValue
    }
}
