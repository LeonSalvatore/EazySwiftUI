# EazySwiftUI

[![Swift 6](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-iOS%2018%20%7C%20macOS%2015-lightgrey.svg?style=flat)](https://developer.apple.com)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen.svg?style=flat)](https://www.swift.org/package-manager/)

EazySwiftUI is a growing collection of reusable Swift and SwiftUI building
blocks extracted from real application work. It keeps common UI patterns,
interaction effects, transitions, bindings, data helpers, and document
utilities in one lightweight package.

```swift
import EazySwiftUI
```

## Highlights

- A floating tab bar measured off the iOS 26 system bar, with a liquid glass
  surface that morphs into a panel of actions
- An expandable Liquid Glass menu that morphs between a compact label and
  caller-provided content
- Liquid glass surfaces and lenses drawn by Metal, from iOS 18 and macOS 15
- SwiftUI interaction effects powered by Metal shaders
- Animated shimmer loading states
- Reusable transitions and conditional view modifiers
- Binding helpers for optional and derived values
- Hex colors with light and dark appearance support
- Image color extraction with gradient, palette, and legibility helpers
- Wrapping flow layouts and async-state rendering
- App-wide overlays and generic transient presentation coordination
- Haptic feedback, persisted preferences, and localized text highlighting
- Safe collection access, stable grouping, and small quality-of-life helpers
- Stateful SwiftUI previews
- Multi-page PDF generation from SwiftUI views on iOS
- Configured for Swift 6 strict concurrency checking

## Requirements

| Tool or platform | Minimum version |
| --- | --- |
| Swift | 6.0 |
| iOS | 18.0 |
| macOS | 15.0 |
| Xcode | A version that supports Swift 6 and the listed deployment targets |

## Installation

### Xcode

1. In Xcode, select **File → Add Package Dependencies**.
2. Enter the package URL:

   ```text
   https://github.com/LeonSalvatore/EazySwiftUI.git
   ```

3. Select **Up to Next Major Version** starting from `0.4.0`.
4. Add `EazySwiftUI` to your application target.

### Package.swift

Add EazySwiftUI to your package dependencies:

```swift
dependencies: [
    .package(
        url: "https://github.com/LeonSalvatore/EazySwiftUI.git",
        from: "0.4.0"
    )
]
```

Then add it to the dependencies of the target that uses it:

```swift
.target(
    name: "YourTarget",
    dependencies: ["EazySwiftUI"]
)
```

## Usage

### Interaction effects

Apply triggered effects such as press, ripple, shake, and spring animations, or
static shader effects such as pixelation, chroma keying, and blur.

```swift
import SwiftUI
import EazySwiftUI

struct ValidationExample: View {
    @State private var shakeTrigger = 0

    var body: some View {
        VStack {
            TextField("Email", text: .constant(""))
                .textFieldStyle(.roundedBorder)
                .interactionEffect(
                    .shake(shakeTrigger, config: .default)
                )

            Button("Validate") {
                shakeTrigger += 1
            }
        }
        .padding()
    }
}
```

Static effects do not need a trigger:

```swift
Image("Artwork")
    .resizable()
    .scaledToFit()
    .interactionEffect(.pixellate(pixelSize: 8))
```

Available effects:

| Kind | Effects |
| --- | --- |
| Triggered | `press`, `ripple`, `shake`, `spring` |
| Static | `pixellate`, `chromaKey`, `blur` |

### Morphing tab bar

`EazyMorphingTabBar` is a floating tab bar that morphs into a panel of actions.
Collapsed it is a strip of tabs and a round toggle beside it; the two are one
body of glass that merges and separates as they move.

```swift
struct RootView: View {
    @State private var selection = "house"
    @State private var isExpanded = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ContentView()

            EazyMorphingTabBar(
                tabs: [
                    EazyTab(systemImage: "house", title: "Home"),
                    EazyTab(systemImage: "tray", title: "Inbox"),
                    EazyTab(systemImage: "bell", title: "Activity"),
                    EazyTab(systemImage: "square.stack", title: "Library")
                ],
                selection: $selection,
                isExpanded: $isExpanded,
                actions: [
                    EazyTabBarAction(systemImage: "scissors", title: "Trim") { trim() },
                    EazyTabBarAction(systemImage: "crop", title: "Crop") { crop() }
                ]
            )
            // The bar insets its own sides. Only the bottom edge is yours to
            // place, and the system puts its bar 21 points above the screen
            // edge rather than above the home indicator.
            .padding(.bottom, EazyMorphingTabBarMetrics.screenInset)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
```

Pass `expandedContent:` instead of `actions:` to expand into a view of your own.
With no actions the toggle is left off and the strip takes the full width, which
is the arrangement that matches the system bar exactly.

> Use one bar for the whole screen — an overlay on the `TabView`, or a
> `safeAreaInset` — rather than one per page. A bar per page swaps for a
> different instance part way through a transition, and the one that comes into
> view is already parked on its new tab, which looks like a broken animation.

The geometry is measured rather than estimated. `EazyMorphingTabBarMetrics`
carries those measurements and every one of them is adjustable:

| Preset | Use |
| --- | --- |
| `.standard` | The system bar: 62 points tall, title under the symbol |
| `.shortScreen` | The bar the system draws where the screen is short: 44 points tall, title beside the symbol, always centred |
| `.symbolsOnly` | The standard height with the titles suppressed |

`.shortScreen` is taken automatically where the vertical size class is compact,
which on an iPhone means landscape. Pass `shortScreenMetrics: nil` to keep one
arrangement at every size, or your own metrics to change what the short screen
gets.

Selection can be dragged as well as tapped: the lens follows the finger rather
than stepping from tab to tab. Reduce Motion drops the animation, and Reduce
Transparency drops the glass for an opaque surface.

Panel content that should arrive with the glass rather than on a schedule of its
own can read how far the morph has gone:

```swift
struct PanelRow: View {
    @Environment(\.eazyMorphingTabBarMorphProgress) private var morph

    var body: some View {
        content.opacity(morph)
    }
}
```

### Expandable glass menu

`ExpandableGlassMenu` morphs a compact label into any SwiftUI content. You own
the progress, so the menu can be driven by a button, a gesture, or an interactive
control.

```swift
struct MoreMenu: View {
    @State private var isExpanded = false

    var body: some View {
        ExpandableGlassMenu(
            alignment: .topLeading,
            progress: isExpanded ? 1 : 0
        ) {
            VStack(alignment: .leading) {
                Button("Send", systemImage: "paperplane") { }
                Button("Swap", systemImage: "arrow.trianglehead.2.counterclockwise") { }
                Button("Receive", systemImage: "arrow.down") { }
            }
            .padding()
        } label: {
            Button(
                isExpanded ? "Close menu" : "Open menu",
                systemImage: isExpanded ? "xmark" : "plus"
            ) {
                withAnimation(.bouncy(duration: 0.75, extraBounce: 0.02)) {
                    isExpanded.toggle()
                }
            }
            .labelStyle(.iconOnly)
        }
    }
}
```

The default collapsed size is 55×55 points. Use `labelSize` and `cornerRadius`
to fit a different control, and keep progress between `0` and `1` for manual or
interactive updates.

### Liquid glass

The tab bar's surface is available on its own. `eazyLiquidGlass(_:merging:)`
draws a blurred, lit surface behind a view, with two shapes that merge into one
body as they approach:

```swift
Color.clear
    .frame(width: 300, height: 80)
    .eazyLiquidGlass(
        .capsule(CGRect(x: 0, y: 12, width: 220, height: 56)),
        merging: .capsule(CGRect(x: 240, y: 12, width: 56, height: 56)),
        style: .regular
    )
```

A background cannot refract what is behind it, so bending content is a separate
modifier that samples the view itself:

```swift
TabStrip()
    .eazyLiquidLens(
        .capsule(selectionFrame),
        refraction: 10,
        depth: 16,
        dispersion: 0.12
    )
```

Both are animatable, and both are drawn by a bundled Metal shader rather than by
the system material, so they render the same from iOS 18 and macOS 15 onwards.
Styles are configurable through `EazyLiquidGlassStyle`; `.regular`, `.tabBar`,
and `.clear` are provided.

### Shimmer

Use `shimmer` for loading placeholders or highlighted content. Its colors,
blur, duration, direction, and blend mode are configurable.

```swift
RoundedRectangle(cornerRadius: 12)
    .frame(height: 72)
    .shimmer(
        color: .gray.opacity(0.25),
        highlight: .white.opacity(0.8),
        duration: 1.25,
        direction: .leadingToTrailing
    )
```

Set `isActive` to `false` to show the original content without the effect.

### View layout and conditional modifiers

```swift
Text("EazySwiftUI")
    .hSpacing(.leading)
    .if(isHighlighted) { view in
        view.foregroundStyle(.orange)
    }
    .ifLet(optionalBackground) { view, background in
        view.background(background)
    }
```

Useful view helpers include:

- `hSpacing`, `vSpacing`, and `maxFrame`
- `frame(_ size:)` and `squareFrame`
- `if` and `ifLet`
- `getSize` and `getFrame`

### Transitions

EazySwiftUI includes common edge transitions and helpers for conditionally
removing views from the layout.

```swift
if isPresented {
    DetailView()
        .transition(.slideFromBottom)
}
```

```swift
BannerView()
    .removeFromEdge(
        if: shouldHideBanner,
        edge: .top,
        animation: .easeInOut(duration: 0.25)
    )
```

Built-in transitions include `slideFromBottom`, `slideFromTop`,
`slideFromLeading`, `slideFromTrailing`, and `scaleAndFade`.

### Bindings

Turn an optional binding into a non-optional binding with a fallback:

```swift
struct ProfileEditor: View {
    @State private var nickname: String?

    var body: some View {
        TextField(
            "Nickname",
            text: $nickname.defaulting("")
        )
    }
}
```

Map a binding when a control needs a different representation:

```swift
let textBinding = $quantity.mapped(
    get: String.init,
    set: { Int($0) ?? 0 }
)
```

The package also provides binding initializers for writable properties on
reference types and nested optional model values.

### Colors

Create colors from hexadecimal strings or integers:

```swift
let accent = Color(hex: "#6C5CE7")
let translucent = Color(hex: 0x6C5CE780)
```

Create a color that adapts to the current appearance:

```swift
let surface = Color(
    lightHex: "#FFFFFF",
    darkHex: "#121212"
)
```

Convert compatible colors back to hexadecimal values with `hex` or
`hexString`.

Pick a legible foreground for any background color, including colors that are
only known at runtime:

```swift
Text(album.title)
    .foregroundStyle(background.readableForeground)
    .background(background)
```

`luminance` and `isDark` expose the same information when a view needs to make
its own decision.

### Image color extraction

`EazyColorExtractor` reads representative colors out of an image so artwork can
drive the surrounding UI. It downsamples the image once, then samples the
resulting pixels, and returns sRGB colors.

Banded colors keep the spatial order of the image, which is what a gradient
needs:

```swift
let extractor = EazyColorExtractor(count: 3, axis: .vertical)
let colors = extractor.colors(from: artwork)
```

Dominant colors are ranked by how much of the image they cover, with similar
colors merged, which is what a palette or an accent color needs:

```swift
let palette = extractor.dominantColors(from: artwork)
let accent = artwork.eazyDominantColor
let average = artwork.eazyAverageColor
```

Every method also accepts a `CGImage`, and a `Data` overload decodes,
downsamples, and samples off the calling actor:

```swift
let colors = await extractor.colors(from: downloadedImageData)
```

Configure sampling through the extractor:

| Parameter | Purpose |
| --- | --- |
| `count` | Number of colors to produce |
| `axis` | Direction the image is split along, `.vertical` or `.horizontal` |
| `sampleSize` | Largest dimension, in pixels, of the downsampled image |
| `minimumOpacity` | Opacity below which a pixel is ignored |

`ImageGradient` turns the extracted colors into an animated backdrop, and
reports the palette so the rest of the screen can reuse it:

```swift
ZStack {
    ImageGradient(
        image: album.artwork,
        extractor: EazyColorExtractor(count: 4),
        onExtract: { palette = $0 }
    )
    .ignoresSafeArea()

    AlbumDetails(album: album)
}
```

The same view is available as a background modifier:

```swift
AlbumDetails(album: album)
    .eazyImageGradientBackground(album.artwork)
```

For a ready-made gradient without a dedicated view, build one directly:

```swift
Rectangle()
    .fill(extractor.linearGradient(from: album.artwork))
```

### Collections and values

The package contains focused helpers for arrays, collections, sequences, sets,
optionals, strings, booleans, comparable values, and geometry.

```swift
let names = ["Ana", "Ben", "Chloé"]
let selectedName = names[safe: selectedIndex]

let sections = people.groupedStable(by: \.department)

let progress = rawProgress.clamped(to: 0...100)

guard title.isNotEmptyAfterTrim else {
    return
}
```

`groupedStable(by:)` is also available for `AsyncSequence`.

### Stateful previews

`StatefulPreview` gives preview content a real binding without creating a
wrapper view solely for preview state.

```swift
#Preview {
    StatefulPreview(false) { isEnabled in
        Toggle("Enabled", isOn: isEnabled)
            .padding()
    }
}
```

### Flow layout

Wrap chips, tags, or other variable-width content into rows:

```swift
EazyFlowLayout(
    horizontalSpacing: 8,
    verticalSpacing: 8,
    alignment: .leading
) {
    ForEach(tags, id: \.self) { tag in
        Text(tag)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.quaternary, in: .capsule)
    }
}
```

### Async UI state

Model loading, refresh, empty, success, and failure without coupling the
package to a networking framework:

```swift
enum ScreenError: Error {
    case unavailable
}

let phase: AsyncPhase<[Article], ScreenError> = .loading(previous: cachedArticles)

AsyncPhaseView(phase) { previous in
    ArticleList(articles: previous ?? [])
        .overlay { ArcProgressView() }
} empty: {
    ContentUnavailableView("No articles", systemImage: "newspaper")
} success: { articles in
    ArticleList(articles: articles)
} failed: { _, previous in
    ArticleList(articles: previous ?? [])
        .overlay { Text("Could not refresh") }
}
```

`AsyncPhase` retains optional previous content during refreshes and failures,
and supports value transformation with `map`.

### Global overlays and transient presentation

Install the overlay host once at the application root:

```swift
@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            EazyOverlayHost {
                RootView()
            }
        }
    }
}
```

Present arbitrary content above navigation, tabs, and sheets:

```swift
content.eazyOverlay(
    alignment: .bottom,
    isPresented: $isMiniPlayerVisible
) {
    MiniPlayer()
}
```

`TransientPresentationCenter` owns replacement, cancellation, actions, and
auto-dismissal while the application supplies its own card:

```swift
@State private var center = TransientPresentationCenter<ToastItem>()

TransientPresentationHost(center: center) {
    ContentView()
} card: { item, dismiss in
    ToastCard(item: item, dismiss: dismiss)
}
```

Use `eazyBlockingOverlay(isPresented:scrim:overlay:)` with an app-designed
loading card when an operation must block the full interface.

### Haptics

```swift
Button("Save") {
    EazyHaptics.impact(.medium)
    save()
}

Picker("Theme", selection: $theme)
    .eazyHapticOnChange(of: theme)
```

Haptic calls are safe no-ops on unsupported platforms.

### Persisted preferences

Reuse the observable persistence pattern behind themes and display modes:

```swift
enum AppTheme: String {
    case system, light, dark
}

@State private var theme = PersistedPreference(
    key: "app.theme",
    defaultValue: AppTheme.system
)
```

Call `theme.select(.dark)` to update and persist the selection, or
`theme.reset(to: .system)` to remove it.

### Localized text highlighting

Localization happens before substring matching, preserving translated word
order and punctuation:

```swift
Text(
    localized: "Welcome back, \(name)",
    highlighting: TextHighlight(name, color: .accentColor, font: .headline)
)
```

### PDF generation

On iOS, `PDFGenerator` renders one SwiftUI view for each page and writes the
result to a PDF file.

```swift
@MainActor
func makeReport() throws -> URL? {
    try PDFGenerator.generate(
        .a4(),
        pageCount: 3
    ) { pageIndex in
        VStack(spacing: 16) {
            Text("Report")
                .font(.largeTitle.bold())

            Text("Page \(pageIndex + 1)")
        }
        .padding(40)
    }
}
```

Use `PageSize.a4()`, `PageSize.letter()`, or provide a custom `PageSize`.
`swappedOrientation()` converts a page size between portrait and landscape.

> `PDFGenerator`, `PDFGenerationError`, and `Bundle.appName` are currently
> available on iOS only.

## Platform notes

Most APIs support both iOS and macOS. The following helpers are
platform-specific:

- PDF generation and `UIImage` resizing/compression are available on iOS.
- Selective corner rounding through `CustomCornerShape` is available on iOS.
- `EazyPlatformColor` maps to `UIColor` on iOS and `NSColor` on macOS, and
  `EazyPlatformImage` maps to `UIImage` on iOS and `NSImage` on macOS.
- Image color extraction, `ImageGradient`, and
  `eazyImageGradientBackground(_:)` support both iOS and macOS.
- Metal shader libraries are bundled as Swift Package resources; no manual
  resource setup is required when the package is installed through Swift
  Package Manager. Each shader ships three precompiled libraries — iOS device,
  iOS simulator, and macOS — built against the package's own deployment targets,
  and the matching one is selected at runtime. Nothing in a consuming project
  needs a Metal build phase, and the `.metal` sources are excluded from the
  target so they are never compiled twice.
- Where a shader library cannot be loaded, the glass surfaces fall back to a
  material-filled shape rather than disappearing.

## Development

Clone the repository and run the package tests:

```bash
git clone https://github.com/LeonSalvatore/EazySwiftUI.git
cd EazySwiftUI
swift test
```

When changing Metal shaders, use the included `compile_shaders.sh` script to
rebuild the packaged `.metallib` resources for supported destinations.

## Roadmap

The [reuse audit and roadmap](REUSE_AUDIT.md) documents patterns found across
Sanctum, Campzone, WorshipPlus, and Eden Match, including which mechanics
should be extracted next and which product-specific code should remain in each
application.

## Release history

See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Contributing

Issues and pull requests are welcome. Keep additions small, reusable, and
documented, and include tests when behavior can be verified independently of
the UI.
