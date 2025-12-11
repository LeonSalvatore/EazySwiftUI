//
//  File.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 11.12.2025.
//

import SwiftUI
import PDFKit

public struct PDFGenerator {

    @MainActor
    static func generate<T: View>(
        _ pageSize: PageSize = .a4(),
        pageCount: Int,
        format: UIGraphicsPDFRendererFormat = .default(),
        fileURL: URL = FileManager.default.temporaryDirectory.appending(path:"\(UUID().uuidString).pdf"),
        @ViewBuilder
        view: @escaping (_ index: Int) -> T) async throws -> URL? {

            let size = pageSize.size
            let rect = CGRect(origin: .zero, size: size)

            let render = UIGraphicsPDFRenderer(bounds: rect, format: format)

             try render.writePDF(to: fileURL) { context in
                 for index in 0..<pageCount {

                     context.beginPage()

                     let pageContent = view(index)

                     let render = ImageRenderer(content: pageContent.frame(width: size.width, height: size.height))

                     render.proposedSize = .init(size)
                     context.cgContext.translateBy(x: .zero, y: size.height)
                     context.cgContext.translateBy(x: 1, y: -1)
                     render.render { _, swiftUIContext in
                         swiftUIContext(context.cgContext)
                     }
                 }
             }

            return fileURL
    }



}

