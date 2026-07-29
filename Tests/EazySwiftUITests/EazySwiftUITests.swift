import Foundation
import SwiftUI
import Testing
@testable import EazySwiftUI

@Suite("Collection helpers")
struct CollectionHelperTests {
    @Test
    func safeSubscriptHandlesValidAndInvalidIndices() {
        let values = ["a", "b", "c"]

        #expect(values[safe: 1] == "b")
        #expect(values[safe: -1] == nil)
        #expect(values[safe: 3] == nil)
    }

    @Test
    func stableGroupingPreservesFirstKeyAndElementOrder() {
        struct Person {
            let team: String
            let name: String
        }

        let people = [
            Person(team: "B", name: "Bea"),
            Person(team: "A", name: "Ana"),
            Person(team: "B", name: "Ben")
        ]

        let groups = people.groupedStable(by: \.team)

        #expect(groups.map(\.key) == ["B", "A"])
        #expect(groups[0].values.map(\.name) == ["Bea", "Ben"])
        #expect(groups[1].values.map(\.name) == ["Ana"])
    }

    @Test
    func comparableClampingHonorsBothBounds() {
        #expect((-2).clamped(to: 0...10) == 0)
        #expect(5.clamped(to: 0...10) == 5)
        #expect(12.clamped(to: 0...10) == 10)
    }
}

@Suite("Binding helpers")
@MainActor
struct BindingHelperTests {
    private final class Box<Value> {
        var value: Value

        init(_ value: Value) {
            self.value = value
        }
    }

    @Test
    func optionalBindingUsesFallbackAndWritesThrough() {
        let box = Box<Int?>(nil)
        let source = Binding<Int?>(
            get: { box.value },
            set: { box.value = $0 }
        )
        let fallback = source.defaulting(7)

        #expect(fallback.wrappedValue == 7)
        fallback.wrappedValue = 12
        #expect(box.value == 12)
    }

    @Test
    func mappedBindingTransformsInBothDirections() {
        let box = Box(4)
        let source = Binding<Int>(
            get: { box.value },
            set: { box.value = $0 }
        )
        let mapped = source.mapped(
            get: String.init,
            set: { Int($0) ?? 0 }
        )

        #expect(mapped.wrappedValue == "4")
        mapped.wrappedValue = "9"
        #expect(box.value == 9)
    }

    @Test
    func referenceKeyPathBindingWritesObjectProperty() {
        let box = Box(false)
        let binding = Binding<Bool>(object: box, keyPath: \.value)

        binding.wrappedValue = true

        #expect(box.value)
    }
}

@Suite("Color helpers")
struct ColorHelperTests {
    @Test
    func rgbAndRgbaStringsRoundTrip() {
        #expect(Color(hex: "#336699").hexString == "#336699")
        #expect(Color(hex: "#CC336699").hexString == "#336699CC")
    }

    @Test
    func shorthandHexExpandsChannels() {
        #expect(Color(hex: "#3A7").hexString == "#33AA77")
    }

    @Test
    func integerHexSupportsRgbAndRgba() {
        #expect(Color(hex: 0x336699).hexString == "#336699")
        #expect(Color(hex: 0x336699CC).hexString == "#336699CC")
    }
}

@Suite("Page sizes")
struct PageSizeTests {
    @Test
    func orientationSwapPreservesDimensions() {
        let portrait = PageSize(width: 600, height: 800)
        let landscape = portrait.swappedOrientation()

        #expect(portrait.isPortrait)
        #expect(landscape.isLandscape)
        #expect(landscape.width == 800)
        #expect(landscape.height == 600)
    }

    @Test
    func standardSizesHaveExpectedOrientation() {
        #expect(PageSize.a4().isPortrait)
        #expect(PageSize.letter().isPortrait)
    }
}

@Suite("Flow layout engine")
struct FlowLayoutEngineTests {
    @Test
    func wrapsWithoutTrailingSpacing() {
        let rows = EazyFlowLayoutEngine.rows(
            for: [
                CGSize(width: 40, height: 10),
                CGSize(width: 40, height: 20),
                CGSize(width: 30, height: 15)
            ],
            maxWidth: 90,
            horizontalSpacing: 10
        )

        #expect(rows.count == 2)
        #expect(rows[0].indices == 0..<2)
        #expect(rows[0].width == 90)
        #expect(rows[0].height == 20)
        #expect(rows[1].indices == 2..<3)
        #expect(rows[1].width == 30)
    }

    @Test
    func emptyInputProducesNoRows() {
        #expect(
            EazyFlowLayoutEngine.rows(
                for: [],
                maxWidth: 100,
                horizontalSpacing: 8
            ).isEmpty
        )
    }

    @Test
    func oversizedFirstItemDoesNotCreateEmptyRow() {
        let rows = EazyFlowLayoutEngine.rows(
            for: [CGSize(width: 140, height: 20)],
            maxWidth: 100,
            horizontalSpacing: 8
        )

        #expect(rows.count == 1)
        #expect(rows[0].indices == 0..<1)
        #expect(rows[0].width == 140)
    }
}

@Suite("Persisted preferences")
@MainActor
struct PersistedPreferenceTests {
    private enum Theme: String, Equatable {
        case blue
        case green
    }

    @Test
    func selectionPersistsAndRestores() {
        let suiteName = "EazySwiftUI.PersistedPreferenceTests.\(UUID())"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let preference = PersistedPreference(
            key: "theme",
            defaultValue: Theme.blue,
            defaults: defaults
        )
        #expect(preference.value == .blue)

        preference.select(.green)
        #expect(defaults.string(forKey: "theme") == "green")

        let restored = PersistedPreference(
            key: "theme",
            defaultValue: Theme.blue,
            defaults: defaults
        )
        #expect(restored.value == .green)
    }

    @Test
    func resetRemovesStoredValue() {
        let suiteName = "EazySwiftUI.PersistedPreferenceResetTests.\(UUID())"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let preference = PersistedPreference(
            key: "theme",
            defaultValue: Theme.blue,
            defaults: defaults
        )
        preference.select(.green)
        preference.reset(to: .blue)

        #expect(preference.value == .blue)
        #expect(defaults.object(forKey: "theme") == nil)
    }
}

@Suite("Localized text highlighting")
struct TextHighlightTests {
    @Test
    func highlightingPreservesLocalizedText() {
        let attributed = eazyHighlightedAttributedString(
            localized: "Hello Leon, Leon",
            highlights: [TextHighlight("Leon", color: .orange)]
        )

        #expect(String(attributed.characters) == "Hello Leon, Leon")
    }

    @Test
    func emptyAndMissingHighlightsLeaveTextUntouched() {
        let attributed = eazyHighlightedAttributedString(
            localized: "Welcome",
            highlights: [
                TextHighlight("", color: .red),
                TextHighlight("Missing", color: .blue)
            ]
        )

        #expect(String(attributed.characters) == "Welcome")
    }
}

@Suite("Async phase")
struct AsyncPhaseTests {
    private enum Failure: Error, Equatable, Sendable {
        case unavailable
    }

    @Test
    func loadingAndFailureRetainPreviousValue() {
        let loading = AsyncPhase<Int, Failure>.loading(previous: 4)
        let failure = AsyncPhase<Int, Failure>.failure(.unavailable, previous: 4)

        #expect(loading.isLoading)
        #expect(loading.value == 4)
        #expect(failure.value == 4)
        #expect(failure.error == .unavailable)
    }

    @Test
    func mapTransformsCurrentAndPreviousValues() {
        let success = AsyncPhase<Int, Failure>.success(3).map(String.init)
        let loading = AsyncPhase<Int, Failure>.loading(previous: 2).map(String.init)

        #expect(success == .success("3"))
        #expect(loading == .loading(previous: "2"))
    }

    @Test
    func emptyHasNeitherValueNorError() {
        let phase = AsyncPhase<Int, Failure>.empty

        #expect(phase.value == nil)
        #expect(phase.error == nil)
        #expect(!phase.isLoading)
    }
}

@Suite("Transient presentation center")
@MainActor
struct TransientPresentationCenterTests {
    @Test
    func newerPresentationSurvivesOlderTimer() async throws {
        let center = TransientPresentationCenter<String>()

        center.show("first", duration: .milliseconds(5))
        center.show("second", duration: nil)
        try await Task.sleep(for: .milliseconds(20))

        #expect(center.current == "second")
    }

    @Test
    func actionDismissesBeforeRunning() {
        final class Recorder {
            var currentWasNil = false
        }

        let center = TransientPresentationCenter<String>()
        let recorder = Recorder()

        center.show("saved", duration: nil) { @MainActor in
            recorder.currentWasNil = center.current == nil
        }
        #expect(center.hasAction)

        center.performAction()

        #expect(recorder.currentWasNil)
        #expect(center.current == nil)
        #expect(!center.hasAction)
    }

    @Test
    func explicitDismissClearsPresentation() {
        let center = TransientPresentationCenter<String>()
        center.show("message", duration: nil)

        center.dismiss()

        #expect(center.current == nil)
        #expect(!center.hasAction)
    }
}
