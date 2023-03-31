//
//  File.swift
//  
//
//  Created by TealShift Schwifty on 7/15/22.
//
import Foundation
import SwiftUI

public enum AppConfiguration {
    case debug
    case testFlight
    case appStore
}

public struct ThisApp {
    private static let isTestFlight: Bool = {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }()
    public static var isInSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
    
    private static var isDebug:  Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    public static var configuration: AppConfiguration {
        if isDebug {
            return .debug
        } else if isTestFlight {
            return .testFlight
        } else {
            return .appStore
        }
    }
    
    public static var appVersion: String {
        let versionNum = Bundle.main.releaseVersionNumber ?? "-"
        if ThisApp.configuration == .appStore {
            return versionNum
        }
        let buildNum = Bundle.main.buildVersionNumber ?? "-"
        return "\(versionNum) (\(buildNum))"
    }
}

private extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
