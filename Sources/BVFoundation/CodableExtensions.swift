//
//  File.swift
//  BVFoundation
//
//  Created by TealShift Schwifty on 10/16/25.
//

import Foundation

public extension Encodable {
    var jsonData: Data? {
        try? JSONEncoder().encode(self)
    }
}
public extension Decodable {
    static func jsonDecode(from jsonData: Data, failQuietly: Bool = false) -> Self? {
        do {
            return try JSONDecoder.init().decode(Self.self, from: jsonData)
        } catch {
            if !failQuietly {
                Log.w("\(String(describing: Self.self)) JSON decoding error: \(error)")
            }
            return nil
        }
    }
}
