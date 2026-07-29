//
//  EazyOverlayHost.swift
//  EazySwiftUI
//

import Observation
import SwiftUI

#if os(iOS)
import UIKit

/// Installs a pass-through window that can present content above navigation,
/// sheets, and tab bars.
public struct EazyOverlayHost<Content: View>: View {
    private let content: () -> Content
    @State private var properties = EazyOverlayProperties()

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .environment(\.eazyOverlayProperties, properties)
            .background {
                EazyWindowSceneReader { scene in
                    properties.installIfNeeded(in: scene)
                }
                .frame(width: 0, height: 0)
            }
    }
}

public extension View {
    /// Presents content in the app-wide overlay window.
    ///
    /// Without an `EazyOverlayHost`, this gracefully falls back to a normal
    /// SwiftUI overlay attached to the receiving view.
    func eazyOverlay<Overlay: View>(
        animation: Animation = .snappy,
        alignment: Alignment = .top,
        bottomInset: CGFloat = 0,
        managesOwnHitRegions: Bool = false,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Overlay
    ) -> some View {
        modifier(
            EazyOverlayModifier(
                animation: animation,
                alignment: alignment,
                bottomInset: bottomInset,
                managesOwnHitRegions: managesOwnHitRegions,
                isPresented: isPresented,
                overlayContent: content
            )
        )
    }

    /// Marks a touch-consuming subregion inside an overlay that manages its own
    /// hit regions.
    func eazyOverlayHitRegion<ID: Hashable>(id: ID) -> some View {
        modifier(EazyOverlayHitRegionModifier(id: String(describing: id)))
    }
}

@MainActor
@Observable
final class EazyOverlayProperties {
    private(set) var isInstalled = false
    fileprivate var entries: [Entry] = []
    fileprivate var hitRects: [UUID: CGRect] = [:]
    fileprivate var manualHitRects: [String: CGRect] = [:]

    @ObservationIgnored fileprivate weak var sourceScene: UIWindowScene?
    @ObservationIgnored fileprivate var window: EazyPassThroughWindow?

    struct Entry: Identifiable {
        let id: UUID
        let alignment: Alignment
        let bottomInset: CGFloat
        let managesOwnHitRegions: Bool
        let content: AnyView
    }

    func installIfNeeded(in scene: UIWindowScene) {
        guard window == nil || sourceScene !== scene else { return }

        window?.isHidden = true
        let window = EazyPassThroughWindow(windowScene: scene)
        window.properties = self
        window.backgroundColor = .clear
        window.windowLevel = .alert - 1
        window.isUserInteractionEnabled = true

        let host = UIHostingController(
            rootView: EazyOverlayContainer()
                .environment(\.eazyOverlayProperties, self)
        )
        host.view.backgroundColor = .clear
        window.rootViewController = host
        window.isHidden = false

        sourceScene = scene
        self.window = window
        isInstalled = true
    }

    fileprivate func contains(_ point: CGPoint) -> Bool {
        hitRects.values.contains { $0.contains(point) }
            || manualHitRects.values.contains { $0.contains(point) }
    }
}

private struct EazyOverlayPropertiesKey: EnvironmentKey {
    static let defaultValue: EazyOverlayProperties? = nil
}

private extension EnvironmentValues {
    var eazyOverlayProperties: EazyOverlayProperties? {
        get { self[EazyOverlayPropertiesKey.self] }
        set { self[EazyOverlayPropertiesKey.self] = newValue }
    }
}

private struct EazyOverlayModifier<Overlay: View>: ViewModifier {
    let animation: Animation
    let alignment: Alignment
    let bottomInset: CGFloat
    let managesOwnHitRegions: Bool
    @Binding var isPresented: Bool
    let overlayContent: () -> Overlay

    @Environment(\.eazyOverlayProperties) private var properties
    @State private var entryID: UUID?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if properties == nil, isPresented {
                    overlayContent()
                        .padding(.bottom, bottomInset)
                        .transition(.opacity)
                }
            }
            .animation(animation, value: isPresented)
            .onChange(of: isPresented, initial: true) { _, presented in
                presented ? addEntryIfPossible() : removeEntry()
            }
            .onChange(of: properties?.isInstalled, initial: true) { _, installed in
                if installed == true, isPresented {
                    addEntryIfPossible()
                }
            }
            .onDisappear(perform: removeEntry)
    }

    private func addEntryIfPossible() {
        guard let properties, properties.isInstalled, entryID == nil else { return }
        let id = UUID()
        entryID = id
        let entry = EazyOverlayProperties.Entry(
            id: id,
            alignment: alignment,
            bottomInset: bottomInset,
            managesOwnHitRegions: managesOwnHitRegions,
            content: AnyView(overlayContent())
        )
        withAnimation(animation) {
            properties.entries.append(entry)
        }
    }

    private func removeEntry() {
        guard let properties, let entryID else { return }
        withAnimation(animation) {
            properties.entries.removeAll { $0.id == entryID }
        }
        properties.hitRects[entryID] = nil
        self.entryID = nil
    }
}

private struct EazyOverlayHitRegionModifier: ViewModifier {
    let id: String
    @Environment(\.eazyOverlayProperties) private var properties

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { rect in
            properties?.manualHitRects[id] = rect
        }
        .onDisappear {
            properties?.manualHitRects[id] = nil
        }
    }
}

private struct EazyOverlayContainer: View {
    @Environment(\.eazyOverlayProperties) private var properties

    var body: some View {
        ZStack {
            if let properties {
                ForEach(properties.entries) { entry in
                    Group {
                        if entry.managesOwnHitRegions {
                            entry.content
                        } else {
                            entry.content
                                .onGeometryChange(for: CGRect.self) { proxy in
                                    proxy.frame(in: .global)
                                } action: { rect in
                                    properties.hitRects[entry.id] = rect
                                }
                                .onDisappear {
                                    properties.hitRects[entry.id] = nil
                                }
                        }
                    }
                    .padding(.bottom, entry.bottomInset)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: entry.alignment
                    )
                }
            }
        }
        .background(Color.clear)
    }
}

private final class EazyPassThroughWindow: UIWindow {
    weak var properties: EazyOverlayProperties?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard properties?.contains(point) == true else { return nil }
        return super.hitTest(point, with: event)
    }
}

private struct EazyWindowSceneReader: UIViewRepresentable {
    let onResolve: @MainActor (UIWindowScene) -> Void

    func makeUIView(context: Context) -> EazyWindowSceneReaderView {
        let view = EazyWindowSceneReaderView()
        view.onResolve = onResolve
        return view
    }

    func updateUIView(_ uiView: EazyWindowSceneReaderView, context: Context) {
        uiView.onResolve = onResolve
        uiView.resolve()
    }
}

private final class EazyWindowSceneReaderView: UIView {
    var onResolve: (@MainActor (UIWindowScene) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        resolve()
    }

    func resolve() {
        guard let scene = window?.windowScene else { return }
        onResolve?(scene)
    }
}

#else

/// A root wrapper matching the iOS overlay-host API.
public struct EazyOverlayHost<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
    }
}

public extension View {
    /// Presents a normal SwiftUI overlay on platforms without UIKit windows.
    func eazyOverlay<Overlay: View>(
        animation: Animation = .snappy,
        alignment: Alignment = .top,
        bottomInset: CGFloat = 0,
        managesOwnHitRegions: Bool = false,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Overlay
    ) -> some View {
        overlay(alignment: alignment) {
            if isPresented.wrappedValue {
                content()
                    .padding(.bottom, bottomInset)
                    .transition(.opacity)
            }
        }
        .animation(animation, value: isPresented.wrappedValue)
    }

    func eazyOverlayHitRegion<ID: Hashable>(id: ID) -> some View {
        self
    }
}

#endif
