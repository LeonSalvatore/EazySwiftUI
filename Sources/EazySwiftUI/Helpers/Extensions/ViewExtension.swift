//
//  ViewExtension.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 22.12.2025.
//


import SwiftUI

public extension View {

    @ViewBuilder
    func hSpacing(_ alignment: Alignment)-> some View {
        frame(maxWidth: .infinity, alignment: alignment)
    }
    @ViewBuilder
    func vSpacing(_ alignment: Alignment)-> some View {
        frame(maxHeight: .infinity, alignment: alignment)
    }
}
