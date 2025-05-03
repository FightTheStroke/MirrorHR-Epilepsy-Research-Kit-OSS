//
//  MainDebugger.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D'Angelo on 26/04/2020.
//  Copyright © 2020 FightTheStroke Foundation. All rights reserved.
//

///
/// # MainDebugger
///
/// A comprehensive logging and debugging system designed for medical applications
/// with strict reliability requirements and real-time performance constraints.
///
/// ## Features
///
/// - **Categorized Logging**: Different log levels for various message types
/// - **Thread-Safe Design**: Safe to call from any thread including real-time monitoring threads
/// - **Performance Optimized**: Minimal impact on real-time operations
/// - **Memory Efficient**: Automatic log rotation and pruning
/// - **Persistence**: Optional file-based logging
/// - **Telemetry Integration**: Automatic error reporting
/// - **UI Integration**: SwiftUI interface for log inspection
///
/// ## Usage Example
///
/// ```swift
/// // Basic logging
/// mainDebugger.append("Heart rate monitoring started")
///
/// // Error logging with source module
/// mainDebugger.append("Connection failed", .error, sourceModule: "WatchConnectivity")
///
/// // Warning with context
/// mainDebugger.append("Battery below 20%", .warning, sourceModule: "PowerMonitor")
///
/// // Critical error that needs immediate attention
/// mainDebugger.append("Failed to access health data", .fatalError)
/// ```
///
/// ## Performance Considerations
///
/// The debugger is designed to have minimal impact on application performance,
/// especially during real-time monitoring sessions:
///
/// - Logs are processed on a dedicated background thread
/// - Memory usage is carefully managed with autoreleasepool and log rotation
/// - Critical operations are optimized for low latency
/// - Non-critical logs can be disabled while keeping error logging active
///
/// ## Thread Safety
///
/// The logger is thread-safe and can be safely called from any thread, including:
/// - Main UI thread
/// - Background processing threads
/// - Real-time monitoring threads
/// - Watch connectivity threads
///
/// ## Best Practices
///
/// - Use appropriate log levels to aid in filtering and priority
/// - Include the source module for better context
/// - Keep log messages concise but informative
/// - Check error logs during development and testing phases
/// - Use `saveLogsToFile` for diagnostics in production
///

import Foundation
import SwiftUI
import os.log
import OSLog
import MirrorHRTelemetryPackage

private let mustBePrintedLogsOnly: Bool = true

/// Type of debug message
public enum DebugMsgType: Identifiable, CaseIterable {
    case justALog
    case greenFlag
    case event
    case error
    case fatalError
    case warning
    case forcePrint
    case aILog
    
    public var id: Self { self }
    
    /// Display name for the debug message type
    public var description: String {
        switch self {
        case .justALog:
            return "Log"
        case .greenFlag:
            return "Success"
        case .event:
            return "Event"
        case .error:
            return "Error"
        case .fatalError:
            return "Fatal Error"
        case .warning:
            return "Warning"
        case .forcePrint:
            return "Forced Print"
        case .aILog:
            return "AI Log"
        }
    }
    
    /// Corresponding OS Log level
    var osLogLevel: OSLogType {
        switch self {
        case .error, .fatalError:
            return .error
        case .warning:
            return .fault
        case .forcePrint, .greenFlag:
            return .info
        case .justALog, .event, .aILog:
            return .debug
        }
    }
    
    /// All debug message types for UI filtering
    static let allEvents: [DebugMsgType] = allCases
}

/// A single log entry in the debugger
public struct DebugLog: Identifiable, Hashable {
    public let id = UUID()
    public let debugString: String
    public let debugTimeStamp: TimeInterval
    public let msgType: DebugMsgType
    
    /// Date representation of the timestamp
    public var date: Date {
        Date(timeIntervalSince1970: debugTimeStamp)
    }
    
    /// Flag for whether this log entry should be displayed in the UI
    public var shouldDisplay: Bool = true
}

/// Logger class that provides structured logging and debugging capabilities
@available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
public final class MainDebugger: ObservableObject {
    /// Shared singleton instance
    public static let shared = MainDebugger()
    
    /// Collection of debug logs
    @Published public var debugLogs: [DebugLog] = []
    
    /// Current filter for types of logs to display
    @Published public var typeFilter = DebugMsgType.allEvents
    
    /// Maximum number of stored log entries
    private let maxLogEntries = 1000
    
    /// System logger for integration with system logging facilities
    private let systemLogger = Logger(subsystem: "com.fightthestroke.mirrorhr", category: "MainDebugger")
    
    /// Flag for whether the debugger is actively collecting logs
    private var isDebuggerActive: Bool = false
    
    /// URL for the log file if file logging is enabled
    public var logFileUrl: URL?
    
    /// Timer for scheduled log pruning
    private var pruneTimer: Timer?
    
    /// Thread-safe queue for log operations
    private let logQueue = DispatchQueue(label: "com.fightthestroke.mirrorhr.debugger", qos: .utility)
    
    /// Private initializer for singleton pattern
    private init() {
        setupPruningTimer()
    }
    
    /// Sets up a timer to periodically remove old logs to prevent memory issues
    private func setupPruningTimer() {
        pruneTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.pruneOldLogs()
        }
    }
    
    /// Activates or deactivates the debugger
    /// - Parameter on: Whether to turn the debugger on or off
    public func turnOnOff(_ on: Bool) {
        switch on {
        case true:
            turnOn()
        case false:
            turnOff()
        }
    }
    
    /// Activates the debugger
    public func turnOn() {
        isDebuggerActive = true
        systemLogger.info("Debugger activated")
    }
    
    /// Deactivates the debugger
    public func turnOff() {
        isDebuggerActive = false
        systemLogger.info("Debugger deactivated")
    }
    
    /// Appends a new log message to the debugger
    /// - Parameters:
    ///   - msg: The message to log
    ///   - type: The type of message (log level)
    ///   - sourceModule: The source module that generated the log
    public func append(_ msg: String, _ type: DebugMsgType = .justALog, sourceModule: String = "") {
        // Construct the full message with source module if provided
        let fullMessage = sourceModule.isEmpty ? msg : "[\(sourceModule)] \(msg)"
        
        // Log to system logger
        systemLogger.log(level: type.osLogLevel, "\(fullMessage)")
        
        // Add to internal log store if debugger is active
        if isDebuggerActive {
            append(newLog: DebugLog(
                debugString: fullMessage,
                debugTimeStamp: Date().timeIntervalSince1970,
                msgType: type
            ))
        }
        
        // Output errors and fatal errors to telemetry regardless of debugger state
        let mustBePrinted: Bool = (type == .error || type == .fatalError || type == .forcePrint)
        if mustBePrinted {
            dispatchTelemetryEvent(event: .mirrorHRError(sourceModule: sourceModule, error: msg))
        }
    }
    
    /// Appends a new log entry to the log store
    /// - Parameter newLog: The log entry to add
    private func append(newLog: DebugLog) {
        logQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Use autoreleasepool for better memory management when logging
            autoreleasepool {
                // Add log to the beginning of the array for most recent first
                DispatchQueue.main.async {
                    self.debugLogs.insert(newLog, at: 0)
                    
                    // Trim logs if exceeding maximum capacity
                    if self.debugLogs.count > self.maxLogEntries {
                        self.debugLogs = Array(self.debugLogs.prefix(self.maxLogEntries))
                    }
                }
                
                // Also log to file if a log file URL is set
                self.writeToLogFile(newLog)
            }
        }
    }
    
    /// Removes oldest logs when too many are accumulated
    private func pruneOldLogs() {
        logQueue.async { [weak self] in
            guard let self = self, self.debugLogs.count > self.maxLogEntries else { return }
            
            DispatchQueue.main.async {
                self.debugLogs = Array(self.debugLogs.prefix(self.maxLogEntries / 2))
            }
        }
    }
    
    /// Writes a log entry to the log file if file logging is enabled
    /// - Parameter log: The log entry to write
    private func writeToLogFile(_ log: DebugLog) {
        guard let logFileUrl = logFileUrl else { return }
        
        autoreleasepool {
            let logLine = "\(log.date.toStdString()) [\(log.msgType.description)]: \(log.debugString)\n"
            
            if let data = logLine.data(using: .utf8) {
                do {
                    let fileHandle = try FileHandle(forWritingTo: logFileUrl)
                    defer { fileHandle.closeFile() }
                    
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                } catch {
                    // If we can't append, try to create a new file
                    try? logLine.write(to: logFileUrl, atomically: true, encoding: .utf8)
                }
            }
        }
    }
    
    /// Clears all stored logs
    public func clearLogs() {
        logQueue.async { [weak self] in
            DispatchQueue.main.async {
                self?.debugLogs.removeAll()
            }
        }
    }
    
    /// Creates a text export of all logs
    /// - Returns: A string containing all logs in a formatted representation
    public func exportLogs() -> String {
        var exportString = "MirrorHR Debug Logs - \(Date().toStdString())\n\n"
        
        logQueue.sync {
            for log in debugLogs {
                exportString.append("\(log.date.toStdString()) [\(log.msgType.description)]: \(log.debugString)\n")
            }
        }
        
        return exportString
    }
    
    /// Saves logs to a file
    /// - Parameter completion: Callback with the file URL or error
    public func saveLogsToFile(completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                completion(.failure(NSError(domain: "MainDebugger", code: 1, userInfo: [NSLocalizedDescriptionKey: "Debugger instance was deallocated"])))
                return
            }
            
            autoreleasepool {
                do {
                    let logContent = self.exportLogs()
                    
                    let fileManager = FileManager.default
                    let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
                    let dateString = dateFormatter.string(from: Date())
                    
                    let logFileURL = documentsDirectory.appendingPathComponent("MirrorHR_Logs_\(dateString).txt")
                    
                    try logContent.write(to: logFileURL, atomically: true, encoding: .utf8)
                    
                    DispatchQueue.main.async {
                        completion(.success(logFileURL))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    /// Sets up file logging to a specific file
    /// - Parameter url: The URL of the file to log to
    public func setLogFile(url: URL) {
        logFileUrl = url
    }
    
    /// Deinitializer to clean up resources
    deinit {
        pruneTimer?.invalidate()
    }
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
struct DebugView: View {
    @ObservedObject var mainDebugger = MainDebugger.shared
    var appnName: String
    var buildnumber: String
    
    var body: some View {
        if #available(OSX 11.0, *) {
            LazyVStack {
                Text(appnName + " (" + buildnumber + ")")
                
                List {
                    ForEach(mainDebugger.debugLogs, id: \.self) { log in
                        Text("\(Date(timeIntervalSince1970: log.debugTimeStamp).toStdString()) -> \(log.debugString)")
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct DebugView_Previews: PreviewProvider {
    @available(OSX 10.15, *)
    static var previews: some View {
        DebugView(appnName: "RoberdanToolBox", buildnumber: "1.0")
    }
}

