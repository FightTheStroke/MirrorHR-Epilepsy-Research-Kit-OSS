//
//  Enums.swift
//  MirrorHR
//
//  Created by Roberto D'Angelo on 06/10/2020.
//

import Foundation
import SwiftUI
import MirrorHRTelemetryPackage
#if os(iOS)
    import RoberdanToolBox
#endif

// MARK: - Tabs

#if os(iOS)
    /// Represents the different operational states of the heart rate monitoring flow
    ///
    /// FlowStages define the various states that the heart rate monitoring system
    /// can be in at any given time. These states determine UI appearance, notification
    /// behavior, and underlying system actions. The enum provides both numeric values
    /// for storage and human-readable descriptions for display.
    public enum FlowStages: Int, CaseIterable, Codable {
        /// Heart rate is outside safe thresholds for a sustained period
        case alarm = 0
        
        /// Heart rate is within deep sleep threshold range
        case deepSleep = 1
        
        /// Heart rate is within light sleep threshold range
        case lightSleep = 2
        
        /// Heart rate is within normal range
        case normal = 3
        
        /// Heart rate is approaching alarm thresholds but not yet in alarm state
        case warning = 4
        
        /// No heart rate data is being received from local device
        case noLocalData = 5
        
        /// Monitoring is currently stopped
        case stopped = 6
        
        /// Monitoring is active and functioning normally
        case running = 7
        
        /// No heart rate data is being received from internet streaming
        case noInternetStreamData = 8

        /// Human-readable description of the flow stage
        ///
        /// Used for UI display, logging, and notification content
        public var description: String {
            switch self {
            case .alarm:
                return "Alarm"
            case .deepSleep:
                return "Deep Sleep"
            case .lightSleep:
                return "Light Sleep"
            case .normal:
                return "Normal"
            case .warning:
                return "Warning"
            case .noLocalData:
                return "No Data"
            case .stopped:
                return "Stopped"
            case .running:
                return "Running"
            case .noInternetStreamData:
                return "No Streamed Sata"
            }
        }

        public var chartColor: UIColor {
            switch self {
            case .alarm: return UIColor(hexString: "#fa114f")
            case .deepSleep: return UIColor(hexString: "#2094FA")
            case .lightSleep: return UIColor(hexString: "#5AC8FA")
            case .normal: return UIColor(hexString: "#6fb773")
            case .warning: return UIColor(hexString: "#F5A623")
            case .noLocalData: return UIColor(hexString: "#F5A623")
            case .stopped, .running:
                return UIColor.magenta
            case .noInternetStreamData:
                return UIColor(hexString: "#F5A623")
            }
        }
    }

#endif

/// Represents different types of sleep states for tracking and analysis
///
/// Used for categorizing sleep data from HealthKit or other sources to provide
/// appropriate analysis and visualization
public enum SleepTypes: String, Codable {
    /// User is in bed but may not be asleep
    case inBed
    
    /// User is confirmed to be sleeping
    case aSleep
}

/// Represents errors that can occur during Apple Watch communication
///
/// This enum provides a comprehensive set of error cases that may occur when
/// communicating with an Apple Watch, including setup issues, connectivity
/// problems, and runtime errors. Each error includes appropriate descriptive
/// text and can be transmitted between devices as needed.
public enum WatchCommunicationErrors: Equatable, CaseIterable, Error {
    public static var allCases: [WatchCommunicationErrors] = [
        .watchNotPaired, .watchNotReachable, .watchAppNotInstalled, .cantStartTheSession,
        .cantCommunicateWithWatch, .errorFromTheWatch(errorMessage: "Test error"),
        .soSorryError(errorMessage: "Test so sorry msg")]
    
    public static func == (lhs: WatchCommunicationErrors, rhs: WatchCommunicationErrors) -> Bool {
        return lhs.description == rhs.description
    }

    /// The Watch app is not installed on the paired Apple Watch
    case watchAppNotInstalled
    
    /// No Apple Watch is paired with this iPhone
    case watchNotPaired
    
    /// Communication with the Apple Watch failed
    case cantCommunicateWithWatch
    
    /// Error message received from the Apple Watch
    case errorFromTheWatch(errorMessage: String)
    
    /// The paired Apple Watch is not currently reachable
    case watchNotReachable
    
    /// Cannot start a communication session with the Apple Watch
    case cantStartTheSession
    
    /// General error with a descriptive message
    case soSorryError(errorMessage: String)
    
    /// Error related to HealthKit authorization
    case healthAuthorization(errorMessage: String)
    
    /// The MirrorHR app is not active on the remote iPhone
    case remoteMirrorHRNotActive

    /// Localized user-friendly description of the error
    ///
    /// Used for displaying error messages to the user in the UI
    public var description: String {
        switch self {
        case .watchAppNotInstalled: return watchAppNotInstalledString
        case .cantCommunicateWithWatch: return cantCommunicateWatchString
        case .watchNotPaired: return watchNotPairedString
        case .watchNotReachable: return watchNotReachableString
        case let .errorFromTheWatch(errorMessage): return "\(errorMessage)"
        case .cantStartTheSession: return canTStartSessionString
        case let .soSorryError(errorMessage): return soSorryString + "\(errorMessage.local())"
        case let .healthAuthorization(errorMessage): return "\(errorMessage.local())"
        case .remoteMirrorHRNotActive: return "RemoteMirrorHRNotActiveMsg".local()
        }
    }
    
    /// Technical description of the error for debugging purposes
    ///
    /// Used for logging and developer diagnostics
    public var debugDescription: String {
        switch self {
        case .watchAppNotInstalled: return "Watch App Not Installed"
        case .cantCommunicateWithWatch: return "Cant Communicate With Watch"
        case .watchNotPaired: return "Watch Not Paired"
        case .watchNotReachable: return "Watch Not Reachable"
        case let .errorFromTheWatch(errorMessage): return "Error from the watch: \(errorMessage)"
        case .cantStartTheSession: return "CanT Start Session"
        case let .soSorryError(errorMessage): return "So Sorry" + "\(errorMessage)"
        case let .healthAuthorization(errorMessage): return "\(errorMessage)"
        case .remoteMirrorHRNotActive: return "MirrorHR is not active on the remote iPhone"
        }
    }
    
    /// Indicates if this error is related to Apple Watch functionality
    ///
    /// Used to determine if Watch-specific UI/instructions should be shown
    public var requiresWatchEnabled: Bool {
        switch self {
        case .watchAppNotInstalled, .watchNotPaired, .cantStartTheSession, .cantCommunicateWithWatch, .errorFromTheWatch, .watchNotReachable, .healthAuthorization:
            return true
        case .soSorryError, .remoteMirrorHRNotActive:
            return false
        }
    }
    
    /// Converts a debug description string back to the corresponding error case
    ///
    /// Used when reconstructing errors from log files or transmitted messages
    /// - Parameter message: Debug description string to convert
    /// - Returns: Matching WatchCommunicationErrors case or nil if no match
    public static func valueFromDebugDescription(_ message: String) -> WatchCommunicationErrors? {
        var returningValue: WatchCommunicationErrors?
        WatchCommunicationErrors.allCases.forEach { error in
            if error.debugDescription == message {
                returningValue = error
            }
        }
        return returningValue
    }
}

/// Represents events related to HealthKit data operations
///
/// Used to track and communicate the state of HealthKit-related queries
/// and operations throughout the application
public enum HealthKitToolsEvents: String, Equatable {
    /// Indicates that the seizures data needs to be refreshed
    case seizuresQueryNeedToRefresh

    public var description: String {
        return rawValue
    }
}

/// Represents the different device types supported by the application
///
/// Used to identify the source of data and adjust behavior accordingly
/// based on the capabilities of each device type
public enum DeviceModels: String, Codable {
    /// iPhone app as the data source
    case iPhone
    
    /// Apple Watch as the data source
    case appleWatch
    
    /// Data streaming from a local source (same device)
    case localStreaming
    
    /// Data streaming from a remote source (different device)
    case remoteStreaming
}

// MARK: making MirrorHRErrors Codable
extension WatchCommunicationErrors: Codable {
    private enum CodingKeys: String, CodingKey {
        case watchAppNotInstalled, watchNotPaired, cantCommunicateWithWatch, errorFromTheWatch, watchNotReachable,
             cantStartTheSession, soSorryError, healthAuthorization, remoteMirrorHRNotActive
    }
    static var testSamples: [WatchCommunicationErrors] = [
        .watchNotPaired,
        .watchNotReachable,
        .watchAppNotInstalled,
        .cantCommunicateWithWatch,
        .cantStartTheSession,
        .errorFromTheWatch(errorMessage: "ERROR TEST MESSAGE"),
        .soSorryError(errorMessage: "Error Test Message"),
        .healthAuthorization(errorMessage: "Error Test Message")
    ]

    private enum ErrorFromTheWatchKeys: String, CodingKey { case errorMessage }
    private enum SoSorryKeys: String, CodingKey { case errorMessage }
    private enum HealthAuthorizationKeys: String, CodingKey { case errorMessage }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .watchAppNotInstalled:
            try container.encode(true, forKey: .watchAppNotInstalled)
        case .watchNotPaired:
            try container.encode(true, forKey: .watchNotPaired)
        case .cantCommunicateWithWatch:
            try container.encode(true, forKey: .cantCommunicateWithWatch)
        case .errorFromTheWatch(errorMessage: let errorMessage):
            var nestedContainer = container.nestedContainer(keyedBy: ErrorFromTheWatchKeys.self, forKey: .errorFromTheWatch)
            try nestedContainer.encode(errorMessage, forKey: .errorMessage)
        case .watchNotReachable:
            try container.encode(true, forKey: .watchNotReachable)
        case .cantStartTheSession:
            try container.encode(true, forKey: .cantStartTheSession)
        case .soSorryError(errorMessage: let errorMessage):
            var nestedContainer = container.nestedContainer(keyedBy: SoSorryKeys.self, forKey: .soSorryError)
            try nestedContainer.encode(errorMessage, forKey: .errorMessage)
        case .healthAuthorization(errorMessage: let errorMessage):
            var nestedContainer = container.nestedContainer(keyedBy: HealthAuthorizationKeys.self, forKey: .healthAuthorization)
            try nestedContainer.encode(errorMessage, forKey: .errorMessage)
        case .remoteMirrorHRNotActive:
            try container.encode(true, forKey: .remoteMirrorHRNotActive)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.watchAppNotInstalled) {
            self = .watchAppNotInstalled
            return
        }
        if container.contains(.watchNotPaired) {
            self = .watchNotPaired
            return
        }
        if container.contains(.watchNotReachable) {
            self = .watchNotReachable
            return
        }
        if container.contains(.cantCommunicateWithWatch) {
            self = .cantCommunicateWithWatch
            return
        }
        if container.contains(.cantStartTheSession) {
            self = .cantStartTheSession
            return
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: ErrorFromTheWatchKeys.self, forKey: .errorFromTheWatch),
           let errorMessage = try? nestedContainer.decode(String.self, forKey: .errorMessage) {
            self = .errorFromTheWatch(errorMessage: errorMessage)
            return
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: ErrorFromTheWatchKeys.self, forKey: .soSorryError),
           let errorMessage = try? nestedContainer.decode(String.self, forKey: .errorMessage) {
            self = .soSorryError(errorMessage: errorMessage)
            return
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: HealthAuthorizationKeys.self, forKey: .healthAuthorization),
           let errorMessage = try? nestedContainer.decode(String.self, forKey: .errorMessage) {
            self = .healthAuthorization(errorMessage: errorMessage)
            return
        }
        
        mainDebugger.append("Unable to decode Event", .error, sourceModule: "Events - init from decoder")
        throw NSError(domain: "WatchCommunicationErrors", code: 1001, userInfo: [NSLocalizedDescriptionKey: "error in WatchCommunicationErrors initialization"])
    }

    public var jsonString: String? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode jsonstring", .error, sourceModule: "MirrorHRErrors jsonString")
            return nil
        }
    }
    
    public static func loadFromJson(jsonString: String) -> WatchCommunicationErrors? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(WatchCommunicationErrors.self, from: data)
    }
}
