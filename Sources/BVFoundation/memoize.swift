//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

private var data: [String: [Int: Any]] = [:]

public func memoize<T: Hashable, U>(
    uniquingWith value: T?,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line,
    column: Int = #column,
    _ expression: (() -> U)
) -> U {
    let key = file.description + function.description + line.description + column.description
    
    if let value = value, let result = data[key, default: [:]][value.hashValue] {
        return result as! U
    } else {
        let result = expression()
        if let value = value {
            data[key, default: [:]][value.hashValue] = result
        }
        return result
    }
}

@MainActor
public func memoize<T: Hashable, U>(
    uniquingWith value: T?,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line,
    column: Int = #column,
    _ expression: () async -> U
) async -> U {
    let key = file.description + function.description + line.description + column.description
    
    if let value = value, let memorizedResult = data[key, default: [:]][value.hashValue] {
        return memorizedResult as! U
    } else {
        let result = await expression()
        if let value = value {
            data[key, default: [:]][value.hashValue] = result
        }
        return result
    }
}

@MainActor
public func memoize<T: Hashable, U>(
    uniquingWith value: T?,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line,
    column: Int = #column,
    _ expression: () async throws -> U
) async throws -> U {
    let key = file.description + function.description + line.description + column.description
    
    if let value = value, let result = data[key, default: [:]][value.hashValue] {
        return result as! U
    } else {
        let result = try await expression()
        if let value = value {
            data[key, default: [:]][value.hashValue] = result
        }
        return result
    }
}

public func memoize<T: Hashable, U>(
    uniquingWith value: T?,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line,
    column: Int = #column,
    _ expression: @autoclosure () -> U
) -> U {
    return memoize(uniquingWith: value, file: file, function: function, line: line, column: column) {
        expression()
    }
}
