import Foundation
import Metal
import Testing
@testable import EazySwiftUI

/// Guards the packaging of the Metal shaders.
///
/// The shaders have no compile-time tie to the Swift that calls them: a
/// `ShaderFunction` is a library and a string, and a name that resolves to
/// nothing simply draws nothing. So the whole chain - the `.metal` files being
/// compiled at all, the library landing where `Bundle.module` can find it, and
/// every function this package names being in it - is only checked here.
///
/// Run these on a simulator or a device. `swift test` builds no shader library
/// at all, because SwiftPM's own build system has no Metal rule, and the suite
/// skips rather than reporting a failure it cannot distinguish from a real one.
@Suite("Shader library")
struct ShaderLibraryTests {

    /// Whether this build compiled the shaders. False only under `swift test`.
    static let isCompiled = EazyShaderLibrary.libraryURL != nil

    /// Every function `EazyShaderLibrary` and `EazyLiquidGlassShaders` ask for
    /// by name.
    static let expectedFunctions = [
        "chromaKeyEffect",
        "eazyLiquidGlassHighlight",
        "eazyLiquidGlassMask",
        "eazyLiquidLens",
        "gaussianBlur",
        "pixellateEffect",
        "rippleEffect",
        "shakeEffect"
    ]

    @Test(
        "the compiled library is the one the effects resolve",
        .enabled(if: isCompiled)
    )
    func libraryResolves() {
        #expect(EazyShaderLibrary.library != nil)
        #expect(EazyLiquidGlassShaders.library != nil)
    }

    @Test(
        "the compiled library holds every function the package names",
        .enabled(if: isCompiled)
    )
    func libraryHoldsEveryFunction() throws {
        let url = try #require(EazyShaderLibrary.libraryURL)
        let device = try #require(MTLCreateSystemDefaultDevice())

        let names = Set(try device.makeLibrary(URL: url).functionNames)

        for function in Self.expectedFunctions {
            #expect(names.contains(function), "missing \(function)")
        }
    }
}
