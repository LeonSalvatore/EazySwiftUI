//
//  StatefulPreview.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 29.12.2025.
//


import SwiftUI

/// A container capable of give state capabilities to PreviewProvider.
///
/// You just need to add it at the root of your preview with a initial value and
/// you will receive a real binding value to your componente like if you are
/// using it inside an actual View.
///```swift
///     struct ExampleView_Preview: PreviewProvider {
///         static var previews: some View {
///             ZiyonStatefulPreview("Value") { binding in
///                 ExampleView(value: binding)
///             }
///         }
///     }
///```
public struct StatefulPreview<Value, Content: View>: View {
    
    @State private var value: Value
    private var content: (Binding<Value>) -> Content
    
    public init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
    
    public var body: some View {
        content($value)
    }
}


#Preview {
    StatefulPreview("Binding Text"){ bindingText in
        Text(bindingText.wrappedValue)
    }
}
