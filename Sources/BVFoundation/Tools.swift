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
    static func wait(seconds: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
