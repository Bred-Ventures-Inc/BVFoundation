//
//  CloudSettings.swift
//  Fatburn
//
//  Created by TealShift Schwifty on 3/14/23.
//

import Foundation
import Combine

/// This class serves as a wrapper to facilitate Key-Value Storage under iCloud. Apps within the same team, on any platform, may
/// share settings using this system. First designate one app as the "primary."
/// Official docs: https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html#//apple_ref/doc/uid/TP40012094-CH6-SW11

/// Before using: Enable the service under Project Target settings > Signing & Capabilities > iCloud > Key-Value Storage
/// This will update your .entitlements file with the key `com.apple.developer.ubiquity-kvstore-identifier`.
/// This key renders as "iCloud Key-Value Store" in Xcode's plist editor with default value: `$(TeamIdentifierPrefix)$(CFBundleIdentifier)`.
/// The app designated as the primary may keep this default value. Other apps under the same team seeking shared access should then copy the bundle ID of the primary to replace `$(CFBundleIdentifier)` in order to match the primary's value.
/// Storage capacity is 1MB, independent of user's iCloud storage capacity.

public class CloudSettings {
    public static let shared = CloudSettings()
    
    public var nowSyncing = false
    
    internal var localStore: UserDefaults?
    internal var cloudStore: NSUbiquitousKeyValueStore {
        NSUbiquitousKeyValueStore.default
    }
    internal var retrievingFromCloud = false
    internal var listeners: Set<AnyCancellable> = []

    public func startSyncing(localStore: UserDefaults = .standard) {
        guard !nowSyncing else {return}
        nowSyncing = true
        self.localStore = localStore
        Log.v("Starting sync for cloud user defaults.")
        NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
            .sink { _ in self.notificationFromCloud() }
            .store(in: &listeners)

        if !cloudStore.synchronize() {
            Log.w("Cloud prefs sync error!")
        }
        notificationFromCloud()
//        printStorageSizePerKey()
//        Log.v("All Cloud settings set: \(cloudStore.dictionaryRepresentation)")
    }
    public func stopSyncing() {
        listeners.removeAll()
        nowSyncing = false
    }

    internal func notificationFromCloud() {
        ///  Disable pushes to cloud while we set local values from cloud
        retrievingFromCloud = true
        Log.v("Syncing to local store from cloud...")
        
        let cloudPrefs = cloudStore.dictionaryRepresentation.enumerated()
        
        for (_, pref) in cloudPrefs {
//            if let list = pref.value as? any Collection {
//                Log.v("Saving setting update from cloud: \(pref.key) -> \(list.count) entries")
//            } else if let dict = pref.value as? Dictionary<String, Any> {
//                Log.v("Saving setting update from cloud: \(pref.key) -> \(dict.count) key entries")
//            } else {
//                Log.v("Saving setting update from cloud: \(pref.key) -> \(pref.value)")
//            }
            localStore?.set(pref.value, forKey: pref.key)
        }
        retrievingFromCloud = false
    }

    func pushToCloud(key: String) {
        guard nowSyncing, !retrievingFromCloud else {return}
        
        let prefValue = localStore?.value(forKey: key)
        Log.v("Notifying cloud for setting update: \(key)")
        cloudStore.set(prefValue, forKey: key)
    }
    
//    private func printStorageSizePerKey() {
//        for key in cloudStore.dictionaryRepresentation.keys {
//            var totalSize = 0
//            if let value = cloudStore.object(forKey: key) {
//                let data = NSKeyedArchiver.archivedData(withRootObject: value)
//                totalSize += data.count
//            }
//            Log.w("You are using \(totalSize) bytes of KV Cloud storage in key \(key)")
//        }
//    }
}
