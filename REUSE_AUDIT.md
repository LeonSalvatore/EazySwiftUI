# EazySwiftUI Reuse Audit and Roadmap

This roadmap is based on reusable Swift and SwiftUI patterns found in the
current EazySwiftUI package and four active application codebases:

- Sanctum / EcclesiaKit
- Campzone
- WorshipPlus
- Eden Match

The goal is not to move every shared-looking view into a package. The goal is
to extract stable mechanics that repeatedly cost time to rebuild, while each
application keeps its own visual language and product behavior.

> Implementation status: all Priority 1 items in this audit were implemented
> for the `0.2.0` release. Priority 2 and incubator items remain intentionally
> deferred until they have another proven production use.

## Package boundary

EazySwiftUI should own:

- layout algorithms
- presentation infrastructure
- interaction and feedback mechanics
- generic async and view state
- localization-safe text utilities
- platform-neutral value helpers
- preview and test support

Applications should continue to own:

- semantic colors, typography, spacing, and branding
- product-specific buttons, cards, fields, and empty states
- navigation destinations and deep-link contracts
- Firebase, Supabase, Cloudinary, and other service integrations
- business validation and domain models
- feature copy and localized strings

A useful extraction test is:

> Can two apps use the API without importing either app's models, tokens,
> assets, strings, or service layer?

If the answer is no, the candidate is not ready for EazySwiftUI.

## What the audit found

EazySwiftUI is already used directly by 41 Campzone source files and 115
WorshipPlus source files. EcclesiaKit also declares it as a package dependency.
This makes the package a real shared dependency rather than an experimental
utility folder.

The package currently contains roughly 4,900 lines of Swift, but its test
target still contains only the generated placeholder test. Before the API
surface grows substantially, the package needs a reliable test and platform
compatibility baseline.

The following table counts Swift files containing each pattern. It is a
directional measure of recurrence, not a count of individual call sites.

| Candidate | Total files | Sanctum | Campzone | WorshipPlus | Eden Match |
| --- | ---: | ---: | ---: | ---: | ---: |
| Progress/loading presentation | 135 | 74 | 55 | 6 | 0 |
| Haptic feedback | 241 | 56 | 185 | 0 | 0 |
| Global overlay infrastructure | 70 | 9 | 58 | 3 | 0 |
| Transient toast feedback | 63 | 13 | 48 | 2 | 0 |
| Flow layout | 19 | 7 | 3 | 4 | 5 |
| Persisted theme manager | 18 | 4 | 9 | 0 | 5 |
| Generic loadable state | 26 | 0 | 26 | 0 | 0 |
| Wizard step indicator | 10 | 10 | 0 | 0 |
| Adaptive scroll defaults | 50 | 49 | 1 | 0 | 0 |

Some of these counts are high because a shared component is used broadly
inside one app. The strongest extraction evidence is the near-duplicate
implementation itself:

- `FlowLayout` exists independently in Sanctum, Campzone, WorshipPlus, and
  Eden Match.
- the Campzone and Sanctum `HapticFeedback` implementations are effectively
  the same API.
- the Campzone, Sanctum, and Eden Match theme managers use the same
  `@Observable` plus `UserDefaults` pattern.
- Campzone and Sanctum contain closely related copies of the same pass-through
  `UIWindow` overlay system.
- Campzone and Sanctum both serialize toast presentation through a
  main-actor observable center with token-guarded dismissal.
- Campzone and Sanctum use the same animated progress-ring and global loading
  presentation concept.

## Priority 0: strengthen the package before expanding it

This work produces less visible UI, but it prevents every later extraction
from becoming a regression source.

### 0.1 Replace the placeholder test target

Add focused tests for all deterministic APIs:

- collection and sequence transformations
- binding mapping and fallback behavior
- color parsing and formatting
- page sizes and orientation
- transition configuration values
- async state transformations
- persisted preference restoration
- toast replacement and cancellation behavior

Layout and visual components should receive small host views and snapshot or
geometry tests where practical. At minimum, their supporting algorithms
should be separated into testable value types.

### 0.2 Establish a platform build matrix

The manifest advertises iOS 18 and macOS 15. Both platforms should compile in
CI before a release is tagged. UIKit-only features should be isolated with
platform guards and should either have a documented fallback or be explicitly
iOS-only.

Recommended gates:

```bash
swift test
xcodebuild -scheme EazySwiftUI -destination 'generic/platform=iOS Simulator' build
```

Pre-0.2.0 baseline: `swift test` did not pass on the macOS host. The verified
failures were:

- `SpatialPressingGestureModifier` applies a gesture API that is only
  available on macOS 26 while the package declares macOS 15.
- the macOS branch of `ExtensionColor` treats `NSColor.getRed` as returning a
  Boolean, but that API returns `Void`.
- strict-concurrency warnings remain in `BindingExtension` and `ShakeEffect`.

These issues were resolved in `0.2.0`. The current package passes `swift test`
with warnings treated as errors, plus clean iOS Simulator and macOS builds.

### 0.3 Remove demonstration code from the library target

Types such as `BoolExtensionExamples`, `ComparableExamples`, and
`CollectionExtensionExamples` increase the public API without providing
runtime value. Move examples into documentation, tests, or an example app.

### 0.4 Add API documentation and naming rules

Every new public symbol should have:

- a documentation comment
- at least one tested behavior
- a platform availability decision
- a Sendable/main-actor decision
- a usage example in the README or DocC

Prefer names that communicate package ownership when collision is likely,
such as `EazyFlowLayout`, `EazyOverlayHost`, and `EazyHaptics`.

## Priority 1: extract now

These candidates are already mature enough, appear in multiple apps, and have
clear app-independent boundaries.

### 1. EazyFlowLayout

Evidence: four applications contain their own wrapping `Layout`
implementation.

Proposed API:

```swift
public struct EazyFlowLayout: Layout {
    public init(
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        alignment: HorizontalAlignment = .leading
    )
}
```

Required behavior:

- wraps children without adding trailing spacing to row width
- handles unspecified and infinite proposals
- supports separate horizontal and vertical spacing
- supports leading, center, and trailing row alignment
- behaves correctly with empty content
- works with Dynamic Type

Extraction source: start from EcclesiaKit's implementation, then incorporate
the alignment and measurement cases missing from all current copies.

### 2. EazyHaptics

Evidence: Campzone and EcclesiaKit contain almost identical dispatchers and
matching view modifiers.

Proposed API:

```swift
@MainActor
public enum EazyHaptics {
    public static func impact(_ style: ImpactStyle = .medium)
    public static func selection()
    public static func notification(_ type: NotificationType)
}

public extension View {
    func hapticOnChange<Value: Equatable>(
        of value: Value,
        style: EazyHaptics.ImpactStyle = .light
    ) -> some View
}
```

Keep the implementation a no-op on unsupported platforms. Do not add app
sound effects to this type; sound assets and product feedback policy remain in
each design system.

### 3. PersistedPreference

Evidence: Sanctum, Campzone, and Eden Match repeat the same observable,
`UserDefaults`-backed theme manager.

The reusable concept is not a theme manager. It is a persisted observable
selection.

Proposed API:

```swift
@MainActor
@Observable
public final class PersistedPreference<Value>
where Value: RawRepresentable & Equatable, Value.RawValue == String {
    public private(set) var value: Value

    public init(
        key: String,
        defaultValue: Value,
        defaults: UserDefaults = .standard
    )

    public func select(_ value: Value)
}
```

Each application can then wrap or type-alias it:

```swift
typealias ThemePreference = PersistedPreference<AppTheme>
```

The package must not define `AppTheme`, colors, or a singleton. Those remain
application decisions.

### 4. Localized text highlighting

Evidence: EcclesiaKit already contains a small, polished implementation that
localizes before matching and supports repeated occurrences.

Proposed API:

```swift
public struct TextHighlight {
    public init(_ value: String, color: Color, font: Font? = nil)
}

public extension Text {
    init(
        localized resource: LocalizedStringResource,
        highlighting highlights: TextHighlight...
    )
}
```

This should be extracted almost unchanged, with tests covering:

- translated word order
- repeated matches
- multiple highlights
- empty search strings
- missing matches

### 5. EazyOverlayHost

Evidence: Campzone and EcclesiaKit contain close variants of the same
pass-through overlay-window implementation, and WorshipPlus has another
global overlay mechanism.

Proposed API:

```swift
public struct EazyOverlayHost<Content: View>: View

public extension View {
    func eazyOverlay<Overlay: View>(
        animation: Animation = .snappy,
        alignment: Alignment = .top,
        bottomInset: CGFloat = 0,
        managesOwnHitRegions: Bool = false,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Overlay
    ) -> some View

    func eazyOverlayHitRegion<ID: Hashable>(id: ID) -> some View
}
```

Requirements:

- survives navigation, sheets, and tab changes on iOS
- passes touches through outside registered content
- removes entries and hit regions when owners disappear
- handles scene activation and multiple windows deliberately
- has a normal SwiftUI overlay fallback on macOS
- does not contain toast, loading, mini-player, or app-specific visuals

The current implementations choose the first foreground scene. Before
publishing this API, add explicit scene ownership so multi-window apps do not
render into the wrong window.

### 6. Generic transient presentation center

Evidence: Campzone and EcclesiaKit repeat the same token-guarded, serialized
toast coordinator, but their cards use different colors, fonts, sounds, and
button styles.

Extract the lifecycle, not the visual design.

Proposed API:

```swift
@MainActor
@Observable
public final class TransientPresentationCenter<Item: Equatable & Sendable> {
    public private(set) var current: Item?

    public func show(
        _ item: Item,
        duration: Duration = .seconds(3),
        action: (() -> Void)? = nil
    )

    public func dismiss()
    public func performAction()
}

public struct TransientPresentationHost<Item, Card: View>: View {
    // The application supplies Card.
}
```

The package should guarantee:

- one visible item per center
- a newer item replaces the current item
- stale dismissal tasks cannot clear newer content
- explicit dismiss and action execution cancel the timer
- task cleanup occurs when the center is released

Campzone can keep `CZToast`, Ecclesia can keep `EcclesiaToastCard`, and both
can use the same coordinator and overlay host.

### 7. Progress primitives and blocking presentation

Evidence: all three mature apps have custom loading components; Campzone and
EcclesiaKit share nearly the same progress ring and global saving overlay.

Avoid creating one branded `EazyProgressView`. Extract configurable mechanics:

```swift
public struct ArcProgressView: View {
    public init(
        tint: Color,
        size: CGFloat = 18,
        lineWidth: CGFloat = 2,
        trim: ClosedRange<CGFloat> = 0...0.72,
        duration: Duration = .seconds(1.1)
    )
}

public extension View {
    func eazyBlockingOverlay<Overlay: View>(
        isPresented: Bool,
        @ViewBuilder overlay: () -> Overlay
    ) -> some View
}
```

The primitive should handle Reduce Motion, accessibility labels, cancellation,
and determinate fraction clamping. App-specific card backgrounds, icons,
labels, and semantic colors stay in each design system.

### 8. AsyncPhase and LoadStateView

Evidence: Campzone's `LoadableState` appears across 26 files, while the other
apps repeatedly hand-build loading, empty, loaded, and failed branches.

Proposed state:

```swift
public enum AsyncPhase<Value, Failure: Error> {
    case idle
    case loading(previous: Value?)
    case success(Value)
    case empty
    case failure(Failure, previous: Value?)
}
```

Proposed renderer:

```swift
public struct AsyncPhaseView<
    Value,
    Failure: Error,
    Loading: View,
    Empty: View,
    Success: View,
    Failed: View
>: View {
    // Every visual branch is supplied by the application.
}
```

Important semantics:

- refresh may retain previously loaded content
- cancellation must not replace valid content with an error
- empty is distinct from failure
- retry is supplied by the application
- no Firebase or networking types appear in the API

## Priority 2: extract after one more production use

These are good candidates, but their reusable API needs validation outside the
codebase where each currently lives.

### AdaptiveScrollContainer

EcclesiaKit applies the same vertical scroll defaults across many screens:
size-based bounce, interactive keyboard dismissal, hidden indicators, and
keyboard safe-area behavior.

Generalize it with configuration rather than hard-coding all four choices.
Also correct the current `AdaptativeScrollView` spelling when extracting.

### WizardProgress

EcclesiaKit's `WizardStepIndicator` has a generic step model but branded
visuals. Extract either:

- a value-only `WizardProgress<Step>` model, or
- a fully configurable indicator whose label, marker, connector, and colors
  are supplied by builders.

Do not move Ecclesia fonts, colors, localized fallback text, or backgrounds.

### InlineStatusMessage

The semantics are reusable: error, warning, information, success, optional
description, and optional dismissal. The card styling is not.

A useful package API would expose `StatusKind` and a configurable container or
style protocol, while apps define semantic colors and typography.

### Scroll and geometry observation

Several projects implement offset readers, size readers, and frame reporters.
Consolidate them behind modern SwiftUI geometry APIs:

```swift
public extension View {
    func readSize(_ size: Binding<CGSize>) -> some View
    func readFrame(
        in coordinateSpace: CoordinateSpace,
        _ frame: Binding<CGRect>
    ) -> some View
}
```

Avoid preference-key APIs where `onGeometryChange` is available for the
package's deployment targets.

### ReorderableCollection

Eden Match has a generic reorderable photo grid. The reusable layer should
only manage drag state and array movement. Photo badges, removal controls,
labels, and the three-column grid belong to the app.

Validate the mechanic in a second feature before promoting it to Priority 1.

## Incubator: valuable, but not ready to package

### Auto-scrolling content

Campzone and WorshipPlus both need smooth auto-scrolling for lyrics and
presentations, so this is strategically useful. The current implementations
still contain approximated line heights, timers, unfinished measurement, and
feature-specific controls. First build one correct engine that:

- uses elapsed time rather than assumed frame counts
- pauses during user interaction and resumes predictably
- handles backgrounding and Reduce Motion
- exposes progress and current-item callbacks
- has no lyrics-specific model or controls

After that engine ships successfully in both apps, extract it.

### Hero transitions

Campzone's App Store-style hero card is promising but currently couples
gesture recognition, presentation, material styling, haptics, and iOS-version
branches. Separate its transition state machine from the branded card and
validate it in a second app first.

### Scrolling segmented control

The Campzone control contains useful measurement and snap behavior, but it is
currently coupled to a custom shader, Campzone fonts/colors, haptics, and
iOS 26 glass effects. Extract only after the selection and scrolling engine is
separated from rendering.

### Media and remote-image components

Avatar and media-preview concepts recur, but the apps use different storage,
optimization, caching, authorization, and placeholder policies. Keep these
inside each app until a protocol-based media source has been proven in at
least two applications.

## Do not add to EazySwiftUI

The following may be reusable within one product family but should not enter
this package:

- Ecclesia, Campzone, Eden, or WorshipPlus theme tokens
- product-specific button and text-field styles
- app routes, deep links, and destination registries
- Firestore pages, query extensions, and collection keys
- Cloudinary optimization or upload services
- QR payload formats and check-in flows
- WhatsApp editors and product-specific Markdown themes
- auth provider buttons and account workflows
- camping, church, worship, dating, music, or event domain components

If these need sharing, they belong in a product-specific package such as
EcclesiaKit, not EazySwiftUI.

## Recommended target structure

Do not split the package immediately. First extract and test the Priority 1
APIs. When the core is stable, separate targets so consumers can avoid pulling
in UIKit presentation code or Metal resources they do not use:

```text
EazySwiftUI
├── EazyCore
│   ├── Collections
│   ├── AsyncPhase
│   └── PersistedPreference
├── EazySwiftUI
│   ├── Layout
│   ├── Geometry
│   ├── Feedback
│   └── Presentation
├── EazySwiftUIShaders
│   ├── Interaction effects
│   └── Shimmer
└── EazyDocuments
    └── PDF generation
```

The public umbrella product can still re-export the targets for simple app
installation.

## Suggested delivery sequence

### Release 0.2.0 — reliability and small extractions

1. make iOS and macOS builds green
2. replace the placeholder tests
3. move example-only types out of the public target
4. add `EazyFlowLayout`
5. add `EazyHaptics`
6. add `PersistedPreference`
7. add localized text highlighting

### Release 0.3.0 — presentation infrastructure

1. add `EazyOverlayHost`
2. add the generic transient presentation center
3. add `ArcProgressView`
4. add the configurable blocking-overlay modifier
5. migrate Campzone first, then EcclesiaKit

### Release 0.4.0 — async UI state

1. add `AsyncPhase`
2. add `AsyncPhaseView`
3. migrate one Campzone feature
4. validate the API in one EcclesiaKit or WorshipPlus feature
5. document cancellation and refresh semantics

### Later releases

Promote AdaptiveScrollContainer, WizardProgress, geometry observation, and
reordering only after their second production use. Keep auto-scroll, hero
transitions, segmented controls, and media infrastructure in the incubator
until their mechanics are isolated and tested.

## Definition of done for every extraction

An API is ready to leave an application only when:

- it has no dependency on app models, services, assets, tokens, or copy
- at least two real call sites can use the same public contract
- deterministic behavior is covered by tests
- Reduce Motion and accessibility behavior are intentional
- main-actor and Sendable requirements are explicit
- iOS and macOS behavior is documented
- the source application is migrated, so the duplicate is actually removed
- the README or DocC includes a minimal example
