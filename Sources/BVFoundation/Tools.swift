//
//  Tools.swift
//
//
//  Created by TealShift Schwifty on 8/31/22.
//

import Foundation

public protocol BVUserDefault {
    var key: String { get }
    var value: Any? { get }
    func update(_ value: Any?)
}

public extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }
        return values
    }
}

public extension Task where Success == Never, Failure == Never {
    /// Returns false upon cancellation. This makes it convenient to guard against cancelled tasks after waiting.
    @discardableResult
    static func wait(seconds: TimeInterval) async -> Bool {
        do {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            return true
        } catch is CancellationError {
            return false
        } catch {
            return false
        }
    }
}

public struct Timing {
    public static func wait(seconds: TimeInterval, block: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            block()
        }
    }
    @available(iOS 16.0, *)
    public static func wait(seconds: TimeInterval) async {
        try? await Task.sleep(for: .seconds(seconds))
    }
}
