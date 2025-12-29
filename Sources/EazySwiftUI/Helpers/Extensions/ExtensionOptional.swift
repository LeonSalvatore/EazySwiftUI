//
//  ExtensionOptional.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 29.12.2025.
//

import SwiftUI

public extension Optional {
    /// A Boolean value indicating whether the optional contains a non-nil value.
    ///
    /// This can be used for filtering collections of optionals or for cleaner conditional checks.
    var isNotNil: Bool {
        return self != nil
    }
    /// A Boolean value indicating whether the optional contains a nil value.
    ///
    /// This can be used for filtering collections of optionals or for cleaner conditional checks.
    var isNil: Bool {
        return self == nil
    }
}

public extension Binding where Value == Bool  {

    init<T: Sendable>(optionValue: Binding<T?>) {
        self.init(
            get: {optionValue.wrappedValue.isNotNil },
            set: { if !$0 { optionValue.wrappedValue = nil } })
    }
}
