//
//  File.swift
//  EazySwiftUI
//
//  Created by Leon Salvatore on 11.12.2025.
//

import SwiftUI
import PDFKit

/// A PDF generator that creates multi-page PDF documents from SwiftUI views.
///
/// `PDFGenerator` provides a simple, declarative API for generating PDF files
/// from SwiftUI content. It handles page setup, rendering, and file management
/// with sensible defaults while offering customization options for advanced use cases.
///
/// ## Key Features
/// - **Multi-page support**: Generate PDFs with any number of pages
/// - **SwiftUI integration**: Use any SwiftUI view as page content
/// - **Thread safety**: Uses `@MainActor` for safe UI operations
/// - **Flexible output**: Control page size, format, and file location
/// - **Automatic cleanup**: Defaults to temporary storage with unique filenames
///
/// ## Usage Example
/// ```swift
/// // Generate a simple 3-page PDF
/// let pdfURL = try await PDFGenerator.generate(pageCount: 3) { pageIndex in
///     VStack {
///         Text("Page \(pageIndex + 1)")
///         MyCustomContentView()
///     }
/// }
///
/// // Generate a custom-sized PDF with specific format
/// let customPDF = try await PDFGenerator.generate(
///     pageSize: .letter(),
///     pageCount: 10,
///     format: .printFormat(),
///     fileURL: documentsDirectory.appending(path: "report.pdf")
/// ) { index in
///     ReportPageView(data: reportData[index])
/// }
/// ```
public struct PDFGenerator {

    /// Generates a PDF document from SwiftUI views.
    ///
    /// This method creates a multi-page PDF where each page is rendered from
    /// a SwiftUI view. The method runs on the main actor to ensure thread safety
    /// for UI operations.
    ///
    /// - Parameters:
    ///   - pageSize: The size of each page in points. Defaults to A4 (595.2 × 841.8 points).
    ///     Use standard sizes like `.a4()` or `.letter()`, or create custom sizes.
    ///   - pageCount: The number of pages to generate. The view builder will be called
    ///     for each page index from `0` to `pageCount - 1`.
    ///   - format: The PDF renderer format specifying metadata and output options.
    ///     Defaults to `UIGraphicsPDFRendererFormat.default()`.
    ///   - fileURL: The destination URL for the generated PDF file.
    ///     Defaults to a unique file in the system's temporary directory.
    ///   - view: A view builder closure that creates the SwiftUI content for each page.
    ///     Receives the page index (0-based) and returns a SwiftUI view.
    ///
    /// - Returns: The URL of the generated PDF file, or `nil` if generation failed.
    ///   The file is saved to the specified location upon successful generation.
    ///
    /// - Throws: An error if PDF generation fails, such as:
    ///   - File permission errors when writing to the destination URL
    ///   - Memory issues when rendering complex views
    ///   - Invalid page size or format configurations
    ///
    /// - Important: This method must be called from the main thread or within a
    ///   `@MainActor` context since it performs UI rendering operations.
    ///
    /// ## Coordinate System Note
    /// The method automatically handles coordinate system adjustments:
    /// - SwiftUI uses a coordinate system with origin at top-left, y-axis increasing downward
    /// - Core Graphics (PDF) uses origin at bottom-left, y-axis increasing upward
    /// - Automatic translation is applied to ensure content renders correctly
    ///
    /// ## Performance Considerations
    /// - Complex views with animations or video may not render correctly
    /// - Large page counts may impact memory usage
    /// - Consider generating in background with appropriate quality-of-service
    ///
    /// ## Example with Error Handling
    /// ```swift
    /// do {
    ///     let pdfURL = try await PDFGenerator.generate(pageCount: 5) { index in
    ///         InvoiceView(invoice: invoices[index])
    ///     }
    ///
    ///     // Share or save the generated PDF
    ///     try await sharePDF(at: pdfURL)
    ///
    /// } catch {
    ///     print("Failed to generate PDF: \(error)")
    ///     // Handle error appropriately
    /// }
    /// ```
    ///
    public init() { }

    // MARK: -
    @MainActor
    /// generates the PDF
    public static func generate<T: View>(
        _ pageSize: PageSize = .a4(),
        pageCount: Int,
        format: UIGraphicsPDFRendererFormat = .default(),
        fileURL: URL = FileManager.default.temporaryDirectory
            .appending(path: "\(UUID().uuidString).pdf"),
        @ViewBuilder
        view: @escaping (_ index: Int) -> T
    ) throws -> URL? {

        // Validate page count
        guard pageCount > 0 else {
            throw PDFGenerationError.invalidPageCount
        }

        let size = pageSize.size
        let rect = CGRect(origin: .zero, size: size)

        // Create PDF renderer with specified bounds and format
        let renderer = UIGraphicsPDFRenderer(bounds: rect, format: format)

        // Generate PDF content
        try renderer.writePDF(to: fileURL) { context in
            for pageIndex in 0..<pageCount {
                // Begin new page
                context.beginPage()

                // Create SwiftUI view for this page
                let pageContent = view(pageIndex)

                // Configure image renderer for SwiftUI-to-CGContext conversion
                let imageRenderer = ImageRenderer(
                    content: pageContent
                        .frame(width: size.width, height: size.height)
                )

                imageRenderer.proposedSize = .init(size)

                // Adjust coordinate system for PDF rendering
                // PDF uses bottom-left origin, SwiftUI uses top-left
                let cgContext = context.cgContext
                cgContext.translateBy(x: .zero, y: size.height)
                cgContext.scaleBy(x: 1, y: -1)

                // Render SwiftUI content into PDF context
                imageRenderer.render { _, swiftUIContext in
                    swiftUIContext(cgContext)
                }
            }
        }

        return fileURL
    }
}

// MARK: - Supporting Types

/// Errors that can occur during PDF generation.
public enum PDFGenerationError: LocalizedError {
    /// The specified page count is invalid (must be > 0).
    case invalidPageCount

    /// Failed to render SwiftUI content to PDF context.
    case renderingFailed

    /// Insufficient memory to complete PDF generation.
    case insufficientMemory

    /// The destination URL is not writable.
    case invalidDestinationURL

    public var errorDescription: String? {
        switch self {
        case .invalidPageCount:
            return "Page count must be greater than zero."
        case .renderingFailed:
            return "Failed to render SwiftUI content to PDF."
        case .insufficientMemory:
            return "Insufficient memory to generate PDF."
        case .invalidDestinationURL:
            return "The destination URL is not writable."
        }
    }
}

public extension Bundle {
    /// The display name of the application.
    var appName: String? {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
