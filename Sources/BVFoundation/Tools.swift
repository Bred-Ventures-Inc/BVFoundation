//
//  Tools.swift
//  
//
//  Created by TealShift Schwifty on 8/31/22.
//

import Foundation
import Combine
//public protocol BVUserDefault {
//    var key: String { get }
//    var value: Any? { get }
//    func update(_ value: Any?)
//}

protocol SettingSyncDelegate {
    func settingChanged(key: String)
}

@propertyWrapper final class UserPref<T>: NSObject {
    private let key: String
    private let userDefaults: UserDefaults
    private var observerContext = 0
    private let subject: CurrentValueSubject<T, Never>
    private let syncDelegate: SettingSyncDelegate?

    /// Initialize a key/value to track
    /// - Parameters:
    ///   - defaultValue: Default preference value
    ///   - key: Preference key to track
    ///   - storage: UserDefaults containing value for preference
    ///   - sync: Delegate responsible for keeping this in sync with other platforms
    init(wrappedValue defaultValue: T, _ key: String,
         storage: UserDefaults = .standard, sync: SettingSyncDelegate? = nil) {
        self.key = key
        self.subject = CurrentValueSubject(defaultValue)
        self.userDefaults = storage
        self.syncDelegate = sync
        super.init()
        userDefaults.register(defaults: [key: defaultValue])
        /// The publisher is only called when the value is updated
        userDefaults.addObserver(self, forKeyPath: key, options: .new, context: &observerContext)
        subject.value = wrappedValue
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &observerContext {
            subject.value = wrappedValue
            syncDelegate?.settingChanged(key: key)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    var wrappedValue: T {
        get { userDefaults.object(forKey: key) as? T ?? subject.value }
        set {
            Log.v("Set \(key) -> \(newValue)")
            userDefaults.setValue(newValue, forKey: key)
        }
    }
    var projectedValue: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }

    deinit {
        userDefaults.removeObserver(self, forKeyPath: key, context: &observerContext)
    }
}

@propertyWrapper final class UserPrefOptional<T>: NSObject {
    private var key: String
    private let userDefaults: UserDefaults
    private var observerContext = 0
    private let subject: CurrentValueSubject<T?, Never>
    private let syncDelegate: SettingSyncDelegate?
    
    /// Initialize a key/value to track
    /// - Parameters:
    ///   - defaultValue: Default preference value
    ///   - key: Preference key to track
    ///   - storage: UserDefaults containing value for preference
    ///   - sync: Delegate responsible for keeping this in sync with other platforms
    init(wrappedValue defaultValue: T? = nil, _ key: String,
         storage: UserDefaults = .standard, sync: SettingSyncDelegate? = nil) {
        self.key = key
        self.subject = CurrentValueSubject(defaultValue)
        self.userDefaults = storage
        self.syncDelegate = sync
        super.init()
        if let defaultValue = defaultValue {
            userDefaults.register(defaults: [key: defaultValue])
        }
        /// The publisher is only called when the value is updated
        userDefaults.addObserver(self, forKeyPath: key, options: .new, context: &observerContext)
        subject.value = wrappedValue
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &observerContext {
            subject.value = wrappedValue
            syncDelegate?.settingChanged(key: key)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    var wrappedValue: T? {
        get { userDefaults.object(forKey: key) as? T }
        set {
            Log.v("Set \(key) -> \(String(describing: newValue))")
            userDefaults.setValue(newValue, forKey: key)
        }
    }
    var projectedValue: AnyPublisher<T?, Never> {
        subject.eraseToAnyPublisher()
    }

    deinit {
        userDefaults.removeObserver(self, forKeyPath: key, context: &observerContext)
    }
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
