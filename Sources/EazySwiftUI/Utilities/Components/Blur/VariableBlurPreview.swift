//
//  VariableBlurPreview.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 04.09.2026.
//


#if canImport(UIKit)
import SwiftUI

#Preview("Variable blur over content") {
    ZStack {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<16, id: \.self) { index in
                    HStack {
                        Text(verbatim: "Row \(index + 1)")
                            .font(.body)
                        Spacer()
                    }
                    .padding()
                    .frame(minHeight: 72)
                    .background(
                        index.isMultiple(of: 2) ? Color.orange : Color.teal
                    )
                }
            }
        }

        VStack(spacing: 0) {
            VariableBlur(edge: .top, maxRadius: 4)
                .frame(height: 120)
                .overlay(alignment: .bottom) {
                    Text(verbatim: "Top edge")
                        .font(.headline)
                        .padding(.bottom)
                }

            Spacer()

            VariableBlur(edge: .bottom, maxRadius: 4)
                .frame(height: 120)
                .overlay(alignment: .top) {
                    Text(verbatim: "Bottom edge")
                        .font(.headline)
                        .padding(.top)
                }
        }
    }
    .ignoresSafeArea()
}
#endif
