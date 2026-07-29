//
//  AsyncPhase.swift
//  EazySwiftUI
//

import SwiftUI

/// The complete presentation state of an asynchronous value.
public enum AsyncPhase<Value, Failure: Error> {
    case idle
    case loading(previous: Value?)
    case success(Value)
    case empty
    case failure(Failure, previous: Value?)

    public var value: Value? {
        switch self {
        case .loading(let previous), .failure(_, let previous):
            previous
        case .success(let value):
            value
        case .idle, .empty:
            nil
        }
    }

    public var error: Failure? {
        guard case .failure(let error, _) = self else { return nil }
        return error
    }

    public var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }

    public func map<NewValue>(
        _ transform: (Value) throws -> NewValue
    ) rethrows -> AsyncPhase<NewValue, Failure> {
        switch self {
        case .idle:
            .idle
        case .loading(let previous):
            .loading(previous: try previous.map(transform))
        case .success(let value):
            .success(try transform(value))
        case .empty:
            .empty
        case .failure(let error, let previous):
            .failure(error, previous: try previous.map(transform))
        }
    }
}

extension AsyncPhase: Sendable where Value: Sendable, Failure: Sendable {}
extension AsyncPhase: Equatable where Value: Equatable, Failure: Equatable {}

/// Renders every `AsyncPhase` branch with application-supplied views.
public struct AsyncPhaseView<
    Value,
    Failure: Error,
    Loading: View,
    Empty: View,
    Success: View,
    Failed: View
>: View {
    private let phase: AsyncPhase<Value, Failure>
    private let loading: (Value?) -> Loading
    private let empty: () -> Empty
    private let success: (Value) -> Success
    private let failed: (Failure, Value?) -> Failed

    public init(
        _ phase: AsyncPhase<Value, Failure>,
        @ViewBuilder loading: @escaping (Value?) -> Loading,
        @ViewBuilder empty: @escaping () -> Empty,
        @ViewBuilder success: @escaping (Value) -> Success,
        @ViewBuilder failed: @escaping (Failure, Value?) -> Failed
    ) {
        self.phase = phase
        self.loading = loading
        self.empty = empty
        self.success = success
        self.failed = failed
    }

    @ViewBuilder
    public var body: some View {
        switch phase {
        case .idle:
            loading(nil)
        case .loading(let previous):
            loading(previous)
        case .success(let value):
            success(value)
        case .empty:
            empty()
        case .failure(let error, let previous):
            failed(error, previous)
        }
    }
}
