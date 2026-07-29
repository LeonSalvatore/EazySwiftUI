//
//  TransientPresentation.swift
//  EazySwiftUI
//

import Observation
import SwiftUI

/// Serializes transient app feedback so stale timers cannot dismiss newer
/// content. Applications provide their own item model and card view.
@MainActor
@Observable
public final class TransientPresentationCenter<Item>
where Item: Equatable & Sendable {
    public typealias Action = @MainActor @Sendable () -> Void
    public typealias Sleep = @Sendable (Duration) async throws -> Void

    public private(set) var current: Item?
    public private(set) var hasAction = false

    @ObservationIgnored private var action: Action?
    @ObservationIgnored private var dismissalTask: Task<Void, Never>?
    @ObservationIgnored private var token = 0
    @ObservationIgnored private let sleep: Sleep

    public init(
        sleep: @escaping Sleep = { duration in
            try await Task.sleep(for: duration)
        }
    ) {
        self.sleep = sleep
    }

    public func show(
        _ item: Item,
        duration: Duration? = .seconds(3),
        action: Action? = nil
    ) {
        token &+= 1
        let presentation = token
        current = item
        self.action = action
        hasAction = action != nil

        dismissalTask?.cancel()
        guard let duration else {
            dismissalTask = nil
            return
        }

        dismissalTask = Task { [weak self, sleep] in
            try? await sleep(duration)
            guard !Task.isCancelled, let self else { return }
            self.dismiss(presentation: presentation)
        }
    }

    public func dismiss() {
        dismiss(presentation: nil)
    }

    public func performAction() {
        let action = action
        dismiss()
        action?()
    }

    private func dismiss(presentation: Int?) {
        if let presentation, presentation != token {
            return
        }
        dismissalTask?.cancel()
        dismissalTask = nil
        current = nil
        action = nil
        hasAction = false
    }
}

/// Hosts application-defined transient content in `EazyOverlayHost`.
public struct TransientPresentationHost<
    Content: View,
    Item: Equatable & Sendable,
    Card: View
>: View {
    private let center: TransientPresentationCenter<Item>
    private let content: () -> Content
    private let card: (Item, @escaping @MainActor () -> Void) -> Card

    @State private var isPresented = false

    public init(
        center: TransientPresentationCenter<Item>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder card: @escaping (
            Item,
            @escaping @MainActor () -> Void
        ) -> Card
    ) {
        self.center = center
        self.content = content
        self.card = card
    }

    public var body: some View {
        content()
            .eazyOverlay(isPresented: $isPresented) {
                if let item = center.current {
                    card(item, center.dismiss)
                }
            }
            .onChange(of: center.current, initial: true) { _, item in
                isPresented = item != nil
            }
    }
}
