# Changelog

All notable changes to EazySwiftUI are documented here.

## 0.4.0

### Added

- `EazyMorphingTabBar`, a floating tab bar that morphs into a panel of actions.
  Its geometry is not an approximation of the iOS 26 tab bar but a measurement
  of it, read off a live `UITabBarController`: a 62-point platter inset 21
  points from the screen edges, 94×54 tab boxes on an 86-point stride, and a
  selection lens that is the tab box itself
- a short-screen arrangement, taken automatically where the vertical size class
  is compact — an iPhone in landscape. The system does not shrink its bar there,
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
