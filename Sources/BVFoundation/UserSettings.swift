//
//  File.swift
//  BVFoundation
//
//  Created by TealShift Schwifty on 3/12/26.
//

import Foundation
import Combine

public protocol UserDefaultsKey {
    var key: String { get }
    var storage: UserDefaults { get }
}

// Add a default implementation so String-backed enums get `key` for free
public extension UserDefaultsKey where Self: RawRepresentable, RawValue == String {
    var key: String { rawValue }
}

@propertyWrapper
public class AppPersist<T: Codable, Key: UserDefaultsKey>: NSObject {
    
    private let setting: Key
    private let defaultValue: T
    private var key: String { setting.key }
    private var userDefaults: UserDefaults { setting.storage } // Pull storage from the protocol
    private var observerContext = 0
    private let subject: CurrentValueSubject<T, Never>
    private let syncBlock: (String) -> ()
    let sharedWithCloud: Bool
    
    public init(wrappedValue defaultValue: T,
         _ syncBlock: @escaping (String) -> () = { _ in },
         to setting: Key,
         cloud: Bool = false) {
        
        self.setting = setting
        self.defaultValue = defaultValue
        self.subject = CurrentValueSubject(defaultValue)
        self.syncBlock = syncBlock
        self.sharedWithCloud = cloud
        
        super.init()
        
        userDefaults.register(defaults: [setting.key: defaultValue.jsonData ?? Data()])
        userDefaults.addObserver(self, forKeyPath: setting.key, options: .new, context: &observerContext)
        
        // Ensure subject starts with the current value stored in UserDefaults
        subject.value = wrappedValue
    }
    
    public var wrappedValue: T {
        get { // Read directly using the userDefaults instance
            guard let data = userDefaults.data(forKey: key) else { return defaultValue }
            let value = T.jsonDecode(from: data)
            return value ?? defaultValue
        }
        set { // Write directly using the userDefaults instance
            userDefaults.set(newValue.jsonData, forKey: key)
        }
    }
    
    public var projectedValue: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }

    public override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if context == &observerContext {
            // KVO triggered: Update subject and run sync block
            subject.value = wrappedValue
            syncBlock(key)
            Log.v("Detected storage update to \(key) -> \(wrappedValue)")
            
            if sharedWithCloud {
                CloudSettings.shared.pushToCloud(key: key)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    deinit {
        userDefaults.removeObserver(self, forKeyPath: key, context: &observerContext)
    }
}
