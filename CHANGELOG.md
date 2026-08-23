# Changelog

All notable changes to EazySwiftUI are documented here.

## 0.8.0

### Added

- `EazySlideOutMenu`, a reusable edge-menu container with caller-owned content,
  styling, localization, and settled state; fractional or fixed widths;
  leading and trailing placement with LTR and RTL support; resize-stable drag
  progress; a 44-point visible dismiss region; Reduce Motion-aware settling;
  automatic concentric content corners; accessible scrim and escape dismissal;
  iOS back-swipe and horizontal-scroll arbitration; a macOS drag fallback; an
  interactive preview; and external-module plus geometry tests

## 0.7.0

### Added

- Public `BorderBeamEffectModifier` and `borderBeamEffect` view modifier,
  extracted from Campzone with configurable colors, blur, corner radius,
  rotation duration, base-border visibility, and enabled state. The decorative
  effect does not intercept input and stops rotating when Reduce Motion is
  enabled

### Fixed

- `EazyMorphingTabBar` now keeps each landscape tab at its own measured width
  instead of making every tab as wide as the longest title, and portrait bars
  give an unusually long title width from their shorter neighbors instead of
  truncating it inside an equal box. Selection lenses, nonoverlapping hit
  regions, and drag boundaries follow the resolved widths while retaining
  44-point targets where the available width permits. The native comparison
  preview exercises a long label and a single detached `Tab(role: .search)`
  alongside the custom action toggle
- Dragging `EazyMorphingTabBar` now commits selection from the finger's release
  position without briefly returning the lens to the previously selected tab
- `EazyGlassSegmentControl` now falls back to material below macOS 26 and no
  longer applies the iOS-only `limitsScrolls` property when compiling for
  macOS, restoring the package's declared macOS 15 build support

## 0.6.1

### Added

- A test that loads the compiled shader library through Metal and checks it
  holds every function the package names. Nothing else ties a shader name to
  the Swift that calls it — a name that stops resolving just draws nothing —
  so this is what would catch the shaders falling out of the build again. It
  runs on a simulator or a device, and skips under `swift test`, which
  compiles no shaders

### Changed

- Documentation for the shader pipeline. The README described the removed
  per-platform `.metallib` resources, and `EazyShaderLibrary` still told
  callers to reach for a `.shader()` modifier, which is not a thing

## 0.6.0

### Added

- `EazyGlassSegmentControl`, a horizontally scrollable segment control with a
  Liquid Glass selection capsule that morphs its width to match the active tab.
  Tapping a tab or setting `selection` programmatically scrolls the strip to
  keep the active item centered. Each `Tab` supports an optional SF Symbol icon
  and an optional badge string. Appearance is configurable through
  `EazyGlassSegmentControl.Configuration`: `tint`, `font`, `height`,
  `labelPadding`, `showIcons`, and `hapticsEnabled`

### Fixed

- Metal shaders are compiled by the build system again. The `.metal` files had
  been excluded from the target and hand-compiled `.metallib` files shipped as
  resources in their place, which left the resource bundle with no
  `default.metallib`. Every effect resolved through
  `ShaderLibrary.bundle(.module)` — ripple, blur, pixellate, chroma key, and
  shake — therefore addressed a library that was not there and silently drew
  nothing. The `.metal` files are now target sources, so each build links one
  `default.metallib` for the destination it is building for
- `shakeEffect` is applied with `distortionEffect` rather than `layerEffect`.
  It maps a position to a position, which is not a signature `layerEffect`
  accepts, so the shake never drew
- `chromaKeyEffect` takes its key colour as a `half4`. A
  `Shader.Argument.color` is bound as four components, so declaring three left
  the shader reading the wrong bytes for both the colour and the threshold
  after it
- The blur effect declares a `maxSampleOffset` that covers its kernel. At
  `.zero` every sample the kernel took outside the pixel came back clear, which
  ate the edges of the blur

### Removed

- `compile_shaders.sh` and the 19 committed `.metallib` binaries. Shaders are
  built from source on every build; there is nothing left to regenerate by hand
  and nothing to go stale against the `.metal` files

## 0.5.0

### Added

- public `ExpandableGlassMenu`, with configurable alignment, collapsed size,
  corner radius, content and label, plus an interactive preview and README
  example

### Changed

- `EazyMorphingTabBar` now defaults its panel morph to
  `.bouncy(duration: 0.75, extraBounce: 0.02)` for a softer, more deliberate
  expansion and collapse

### Fixed

- `EazyMorphingTabBar` collapse no longer stalls around the middle and snaps
  shut at the end; both directions now traverse one reversible geometry path,
  expanded content reacts immediately to closing, and actions initiate the
  close before running their handlers

## 0.4.0

### Added

- `EazyMorphingTabBar`, a floating tab bar that morphs into a panel of actions.
  Its geometry is not an approximation of the iOS 26 tab bar but a measurement
  of it, read off a live `UITabBarController`: a 62-point platter inset 21
  points from the screen edges, 94×54 tab boxes on an 86-point stride, and a
  selection lens that is the tab box itself
- a short-screen arrangement, taken automatically where the vertical size class
  is compact - an iPhone in landscape. The system does not shrink its bar there,
  it lays out a different one, and so does this: 44 points instead of 62, the
  title beside the symbol instead of under it and two points larger while the
  symbol gives up six, tab boxes four points apart instead of overlapping by
  eight, and the bar centred at every tab count instead of spreading from four
- a selection lens that stretches as it travels, measured off the system's own:
  a 98-point lens reaches 121 at the crest of a three-tab move, with its height
  unchanged, because its trailing edge lags its leading one. Neither `bounds`
  nor `transform` on the system's view ever reports this, so it is drawn rather
  than laid out
- the same stretch on the panel, so the surface leads with the edge it is
  growing towards and settles back rather than sliding between two rectangles
- `EazyLiquidGlass`: `eazyLiquidGlass(_:merging:style:)` for a Metal-drawn glass
  surface whose shapes merge as they approach, and
  `eazyLiquidLens(_:refraction:depth:dispersion:)` for refracting content
  through a lens. Both render identically from iOS 18 and macOS 15, rather than
  requiring the system material
- `EazyTab`, `EazyTabBarAction`, and `EazyTabBarActionGrid`
- `\.eazyMorphingTabBarMorphProgress` in the environment, so panel content can
  arrive with the glass instead of on a schedule of its own
- Metal libraries for macOS for every shader in the package. `Blur`,
  `ChromaKey`, `Pixellate`, `Ripple`, and `Shake` shipped iOS device and
  simulator libraries only, on a package that declares macOS support

### Fixed

- `CGSize.zero` no longer shadows the standard library's own

## 0.3.0

### Added

- `EazyColorExtractor`, a configurable image color extractor with banded,
  dominant, and average color sampling on iOS and macOS
- `CGImage` overloads and `async` `Data` overloads that decode, downsample, and
  sample off the calling actor
- `ImageGradient` and `eazyImageGradientBackground(_:)` for gradients driven by
  an image, with animated palette changes and an `onExtract` callback
- `linearGradient(from:)` and `gradient(from:)` gradient builders
- `eazyColors(count:)`, `eazyDominantColor`, `eazyAverageColor`, and
  `eazyCGImage` conveniences on `EazyPlatformImage`
- `EazyPlatformImage`, mapping to `UIImage` on iOS and `NSImage` on macOS
- `luminance`, `isDark`, and `readableForeground` on `Color` for picking a
  legible foreground over a runtime color
- behavioral tests covering band order, opacity filtering, dominant color
  ranking, and data decoding

## 0.2.0

### Added

- `EazyFlowLayout` with configurable row spacing and alignment
- `EazyHaptics` and value-driven haptic view modifiers
- observable `PersistedPreference` storage
- localization-safe `TextHighlight`
- `EazyOverlayHost` with pass-through iOS hit testing and macOS fallback
- generic `TransientPresentationCenter` and `TransientPresentationHost`
- Reduce Motion-aware `ArcProgressView`
- configurable app-wide blocking overlays
- `AsyncPhase` and `AsyncPhaseView`
- animated shimmer support
- binding mapping and optional-default helpers
- documentation, release roadmap, and behavioral tests

### Fixed

- macOS 15 package compilation for spatial pressing gestures
- macOS color component extraction
- hexadecimal color round-trip rounding
- strict-concurrency diagnostics in bindings and shader effects
- UIKit-only helpers leaking into macOS builds
- Metal shader resource packaging across supported platforms

### Changed

- iOS 18 and macOS 15 are the declared minimum platforms
- example-only debug types were removed from the public library target
- the package now has a real cross-platform verification baseline
