# Changelog

All notable changes to EazySwiftUI are documented here.

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
