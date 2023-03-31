//
//  Log.swift
//  WorkoutCompanion WatchKit Extension
//
//  Created by Srinivas Prabhu G on 29/10/20.
//  Copyright © 2020 Bred Ventures Inc. All rights reserved.
//

import Foundation
//import CocoaLumberjackSwift
//#if os(watchOS)
//import Mixpanel
//#endif

public enum LogEvent {
    case e
    case i
    case v
    case d
    case w
}

/*
 
 Log.v("The lowest priority level. Use this one for contextual information.")
 Log.d("Print your variables that will help you fix the bug")
 Log.i("Useful for non developers looking into issues")
 Log.w("Use this log level when reaching a condition that won’t necessarily cause a problem but strongly leads the app in that direction.")
 Log.e("Something went wrong. Highest priority log level.")

 */

public extension LogEvent {
    var emoji: String {
        switch self {
            case .d: return "🔨"
            case .e: return "❌"
            case .i: return "ℹ️"
            case .v: return "💬"
            case .w: return "⚠️"
        }
    }
}

public final class Log {
    public static func consolePrint(_ message: String, event: LogEvent) {
        print("\(Date().longTimeFormat): \(event.emoji) \(message)")
    }
    
    public static func w(_ message: String) {
        consolePrint(message, event: .w)
    }

    public static func d(_ message: String) {
        consolePrint(message, event: .d)
    }

    public static func i(_ message: String) {
        consolePrint(message, event: .i)
    }

    public static func v(_ message: String) {
        consolePrint(message, event: .v)
    }
    
    public static func e(_ message: String) {
        consolePrint(message, event: .e)
    }

//    class private func logError(message: String,
//
//                               fileName: StaticString ,
//                               line: Int ,
//                               column: Int ,
//                               funcName: String ) {
//
//        var eventProperties: [String: Any] = [:]
//        eventProperties["File"] = ("\(fileName)" as NSString).lastPathComponent
//        eventProperties["Line Number"] = line
//        eventProperties["Message"] = message
//        log(message: message, event: .e, fileName: fileName)
//        #if os(watchOS)
//        AppAnalytics.shared.error(properties: eventProperties)
//        #endif
//    }
}

extension Date {
    static var longDateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return formatter
    }()
    
    static var extraLongDateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss:SSS"
        return formatter
    }()
    
    static var shortDateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    static var longTimeFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    var longDateFormat:String {
        Date.longDateFormatter.string(from: self)
    }
    
    var shortDateFormat:String{
        Date.shortDateFormatter.string(from: self)
    }
    
    var longTimeFormat:String{
        return Date.longTimeFormatter.string(from: self)
    }
    
}
