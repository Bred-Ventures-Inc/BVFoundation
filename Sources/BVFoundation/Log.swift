//
//  Log.swift
//  WorkoutCompanion WatchKit Extension
//
//  Created by Srinivas Prabhu G on 29/10/20.
//  Copyright © 2020 Bred Ventures Inc. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift
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

private extension DDLogFlag {
    var emoji: String {
        switch self {
        case .debug: return "🔨"
        case .error: return "❌"
        case .info: return "ℹ️"
        case .verbose: return "💬"
        case .warning: return "⚠️"
        default: return ""
        }
    }
}

//public extension LogEvent {
//    var emoji: String {
//        switch self {
//            case .d: return "🔨"
//            case .e: return "❌"
//            case .i: return "ℹ️"
//            case .v: return "💬"
//            case .w: return "⚠️"
//        }
//    }
//}

private class FileLogFormatter: NSObject, DDLogFormatter {
    func format(message logMessage: DDLogMessage) -> String? {
        let fileName = (logMessage.fileName as NSString).deletingPathExtension
        return "\(logMessage.timestamp.longDateFormat) [\(fileName)] \(logMessage.flag.emoji) \(logMessage.message)"
    }
}

private struct ConsoleLogFormatter {
    static func format(message logMessage: DDLogMessage) -> String {
        let fileName = (logMessage.fileName as NSString).deletingPathExtension
        return "\(logMessage.timestamp.longTimeFormat) [\(fileName)] \(logMessage.flag.emoji) \(logMessage.message)"
    }
}

private class ConsoleLogger: DDOSLogger, @unchecked Sendable {
    
    static let formatter:ConsoleLogFormatter = ConsoleLogFormatter()

    override func log(message logMessage: DDLogMessage) {
       let message = (ConsoleLogFormatter.format(message: logMessage))
        
        print("\(message)")
    }
}

public final class Log {
//    public static func consolePrint(_ message: String, event: LogEvent) {
//        print("\(Date().longTimeFormat): \(event.emoji) \(message)")
//    }
    
    private static let fileLogger: DDFileLogger = {
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 3
        fileLogger.logFormatter = FileLogFormatter()
        return fileLogger
    }()
    
    private static let consoleLogger: ConsoleLogger = {
        let consoleLogger = ConsoleLogger()
        return consoleLogger
    }()

    public static func startLog()  {
        DDLog.add(consoleLogger)
        DDLog.add(fileLogger)
    }


    static var filePath:[String]?{
        return Log.fileLogger.logFileManager.sortedLogFilePaths
    }
    
    private static func log(message:String, event:LogEvent, fileName: StaticString ){
        switch event {
            case .d:
                DDLogDebug("\(message)",file:fileName)
            case .e:
                DDLogError("\(message)",file:fileName)
            case .i:
                DDLogInfo("\(message)",file:fileName)
            case .v:
                DDLogVerbose("\(message)",file:fileName)
            case .w:
                DDLogWarn("\(message)",file:fileName)
        }
    }
    
    public static func w(_ message: String, fileName: StaticString = #file) {
//        consolePrint(message, event: .w)
        log(message: message, event: .w, fileName: fileName)
    }

    public static func d(_ message: String, fileName: StaticString = #file) {
//        consolePrint(message, event: .d)
        log(message: message, event: .d, fileName: fileName)
    }

    public static func i(_ message: String, fileName: StaticString = #file) {
//        consolePrint(message, event: .i)
        log(message: message, event: .i, fileName: fileName)
    }

    public static func v(_ message: String, fileName: StaticString = #file) {
//        consolePrint(message, event: .v)
        log(message: message, event: .v, fileName: fileName)
    }
    
    public static func e(_ message: String, fileName: StaticString = #file) {
//        consolePrint(message, event: .e)
        log(message: message, event: .e, fileName: fileName)
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

import Zip
extension Log {
    static func getLogData() -> (URL?, String){
        var zipFilePath: URL?

        let paths = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        let logFolderPath = paths[0].appendingPathComponent("Caches/Logs")
        let fileName = "Logs"
        
        do {
            zipFilePath = try Zip.quickZipFiles([logFolderPath], fileName: fileName)
            Log.d("Successfully fetched data from the zipped log files")
        }
        catch(let err){
            Log.e("Error in zipping files \(err)")
        }
        return (zipFilePath, fileName)
    }
}

import SwiftUI
@available(iOS 16.0, *)
struct LogDataLink: Transferable {
    enum ShareError: Error {
        case failed
    }
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .zip) { sharedFile in
            // Read data from the local file
            let (path, _) = Log.getLogData()
            guard let path else { throw ShareError.failed }
            return SentTransferredFile(path)
        }
    }
}
