import Foundation
import SwiftUI
import Testing
@testable import EazySwiftUI

/// A tab list written the way callers write one: a plain constant at file
/// scope.
///
/// This is not decoration. `EazyTab` carries the screen behind it, and a screen
/// is a `View`, which is not `Sendable` — so the obvious way to store it would
/// cost the tab its own `Sendable` conformance and stop this line compiling.
/// The screen is a `@MainActor @Sendable` closure instead, and this constant is
/// what proves the conformance survived. If it stops compiling, that is the
/// regression.
private let fileScopeTabs: [EazyTab] = [
    EazyTab("Home", systemImage: "house.fill", value: "home") { Color.clear },
    EazyTab("Browse", systemImage: "square.grid.2x2.fill", value: "browse") { Color.clear }
]

@Suite("Tab content builder")
struct TabContentBuilderTests {

    @EazyTabContentBuilder
    private func list(includesProfile: Bool, extras: [EazyTab] = []) -> [EazyTab] {
        EazyTab("Home", systemImage: "house.fill", value: "home") { Color.clear }
        EazyTab("Browse", systemImage: "square.grid.2x2.fill", value: "browse") { Color.clear }

        if includesProfile {
            EazyTab("You", systemImage: "person.fill", value: "you") { Color.clear }
        }

        extras
    }

    @Test
    func tabsArriveInTheOrderTheyAreDeclared() {
        #expect(list(includesProfile: false).map(\.id) == ["home", "browse"])
    }

    @Test
    func aConditionalTabIsThereOnlyWhenItsConditionHolds() {
        #expect(list(includesProfile: true).map(\.id) == ["home", "browse", "you"])
        #expect(list(includesProfile: false).map(\.id) == ["home", "browse"])
    }

    @Test
    func anArrayOfTabsSplicesInRatherThanNesting() {
        let extras = [
            EazyTab("Settings", systemImage: "gearshape.fill", value: "settings") { Color.clear }
        ]

        #expect(list(includesProfile: false, extras: extras).map(\.id) == ["home", "browse", "settings"])
    }

    @Test
    func bothBranchesOfAChoiceBuild() {
        @EazyTabContentBuilder
        func choose(_ signedIn: Bool) -> [EazyTab] {
            if signedIn {
                EazyTab("You", systemImage: "person.fill", value: "you") { Color.clear }
            } else {
                EazyTab("Sign in", systemImage: "person.badge.key.fill", value: "signin") { Color.clear }
            }
        }

        #expect(choose(true).map(\.id) == ["you"])
        #expect(choose(false).map(\.id) == ["signin"])
    }

    @Test
    func aLoopOfTabsFlattensIntoOneList() {
        @EazyTabContentBuilder
        func loop(_ names: [String]) -> [EazyTab] {
            for name in names {
                EazyTab("\(name)", systemImage: "circle", value: name) { Color.clear }
            }
        }

        #expect(loop(["a", "b", "c"]).map(\.id) == ["a", "b", "c"])
        #expect(loop([]).isEmpty)
    }
}

@Suite("Tab identity and content")
struct TabIdentityTests {

    @Test
    func aTabDeclaredWithAValueIsIdentifiedByIt() {
        let tab = EazyTab("Home", systemImage: "house.fill", value: "home") { Color.clear }

        #expect(tab.id == "home")
        #expect(tab.systemImage == "house.fill")
    }

    @Test
    func aTabDeclaredWithoutOneFallsBackToItsSymbol() {
        let tab = EazyTab("Home", systemImage: "house.fill") { Color.clear }

        #expect(tab.id == "house.fill")
    }

    @Test
    func aBarItemCarriesNoScreenAndADeclaredTabDoes() {
        // What `EazyMorphingTabBar` takes on its own: an item, and nothing
        // behind it. `Tab` without a content closure is the same thing.
        #expect(EazyTab(systemImage: "house.fill", title: "Home").screen == nil)
        #expect(EazyTab("Home", systemImage: "house.fill", value: "home").screen == nil)
        #expect(EazyTab("Home", systemImage: "house.fill", value: "home") { Color.clear }.screen != nil)
    }

    @Test
    func twoTabsAreTheSameTabWhenTheyShareAnIdentity() {
        // Equality is the id alone, so that carrying a screen — which has no
        // equality of its own — cannot make two views of the same tab differ.
        let one = EazyTab("Home", systemImage: "house.fill", value: "home") { Color.clear }
        let other = EazyTab("Start", systemImage: "star.fill", value: "home") { Color.red }

        #expect(one == other)
        #expect(Set([one, other]).count == 1)
    }

    @Test
    func aFileScopeTabListIsStillWritable() {
        #expect(fileScopeTabs.map(\.id) == ["home", "browse"])
    }

    @MainActor
    @Test
    func aTabWaitsToBeAskedBeforeItBuildsItsScreen() {
        // The reason the screen is a closure. A tab list is rebuilt every time
        // its parent updates; building four screens to show one would undo the
        // laziness the container is careful about everywhere else.
        let counter = TabScreenBuildCounter()
        let tab = EazyTab("Home", systemImage: "house.fill", value: "home") {
            CountedScreen(counter: counter)
        }

        #expect(counter.count == 0)

        _ = tab.screen?()
        #expect(counter.count == 1)

        _ = tab.screen?()
        #expect(counter.count == 2)
    }
}

@Suite("Tab reselection")
struct TabReselectionTests {

    @Test
    func aTabStartsWithNoReselections() {
        #expect(EazyTabReselection().count == 0)
    }

    @Test
    func reselectionsCompareByCountSoContentCanWatchThemForChange() {
        #expect(EazyTabReselection(count: 2) == EazyTabReselection(count: 2))
        #expect(EazyTabReselection(count: 2) != EazyTabReselection(count: 3))
    }

    @MainActor
    @Test
    func theBarsHandlerDoesNothingUntilSomethingOwnsTheContent() {
        // A bar used on its own has nobody to tell, so a reselection has to be
        // safe to report into thin air.
        EazyTabReselectionHandler().handle("home")
    }
}

/// Counts how many times a tab's screen has actually been built.
@MainActor
private final class TabScreenBuildCounter {
    var count = 0
}

@MainActor
private struct CountedScreen: View {
    let counter: TabScreenBuildCounter

    init(counter: TabScreenBuildCounter) {
        self.counter = counter
        counter.count += 1
    }

    var body: some View { Color.clear }
}
