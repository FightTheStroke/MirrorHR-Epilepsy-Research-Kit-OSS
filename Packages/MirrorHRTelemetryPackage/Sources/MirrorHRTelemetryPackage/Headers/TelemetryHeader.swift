//
//  TelemetryHeader.swift
//
//
//  Created by Roberto D’Angelo on 12/08/22.
//

import Foundation
import SwiftUI
import OSLog

public struct TelemetryHeader: Codable {
    private static var sharedInstance: TelemetryHeader = TelemetryHeader()
    private static let userIDKey: String = "MirrorHRTelemetryUserID"
    private static let userDefaults = UserDefaults.standard
    
    public static var shared: TelemetryHeader {
        get {
            sharedInstance.updateTimestampAndLocation()
            return sharedInstance
        }
        set {
            sharedInstance = newValue
        }
    }
    
    static var userType: UserType = .unknown
    static var watchStreamingStatus: String = "unknown"
    private var caregivers: [Person]
    public var userID: String
    public var environment: String
    public var appVersion: String
    public var buildVersion: String
#if os(iOS)
    public var language: String
    public var countryCode: String
#endif
    
#if os(watchOS)
    public var language: String
    public var countryCode: String
#endif
    
    public var userType: String
    public var timeStamp: String
    public var sessionID: String
    public var researchID: String
    public var systemVersion: String
    
    private init() {
#if os(iOS)
        self.language = NSLocale.current.language.languageCode?.identifier ?? "<unknown>"
        self.countryCode = NSLocale.current.region?.identifier ?? "<undefined>"
        self.systemVersion = UIDevice.current.systemVersion
#endif
        
#if os(watchOS)
        self.language = NSLocale.current.languageCode ?? "en"
        self.countryCode = NSLocale.current.regionCode ?? "<undefined>"
        self.systemVersion = WKInterfaceDevice.current().systemVersion
#endif
        
        // Inizializza tutte le proprietà memorizzate
        self.sessionID = UUID().uuidString
        self.timeStamp = Date().universalTimeStamp()
        self.userID = "unknown"
        self.environment = AppConfiguration.environment
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        self.buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        self.userType = UserType.unknown.rawValue
        // Inizializza i caregivers e altre proprietà dipendenti da self
        self.researchID = UserDefaults.standard.string(forKey: "MirrorHRTelemetryResearchID") ?? ""
        self.caregivers = CareGiversManager.shared.caregivers
        self.userID = TelemetryHeader.getUserID()
        self.userType = TelemetryHeader.userType.rawValue
    }
    
    public mutating func updateUserType(with type: UserType) {
        TelemetryHeader.userType = type
        userType = type.rawValue
    }
    
    public var currentUserID: String {
        return userID
    }
    
    private mutating func updateTimestampAndLocation() {
        timeStamp = Date().universalTimeStamp()
        caregivers = CareGiversManager.shared.caregivers
    }
    
    public static func getUserID() -> String {
        var userID: String?
        userID = userDefaults.string(forKey: userIDKey)
        guard let userID = userID else {
            let uuidString = UUID().uuidString
            userDefaults.set(uuidString, forKey: userIDKey)
            return uuidString
        }
        return userID
    }
    
    public static func writeUserID(userIDString: String) {
        userDefaults.set(userIDString, forKey: userIDKey)
    }
    
    public static func getUserName() -> String {
        let kidNameKey: String = "ProfileSettings.kidName"
        
        var kidName: String?
        kidName = userDefaults.string(forKey: kidNameKey)
        guard let kidName = kidName else {
            return "unknown"
        }
        return kidName
    }
    
    internal enum AppConfiguration {
        case Debug
        case TestFlight
        case AppStore
        
        static var environment: String {
            switch Config.appConfiguration {
            case .Debug:
                return "IS_DEBUG"
            case .TestFlight:
                return "IS_TESTFLIGHT"
            default:
                return "IS_APPSTORE"
            }
        }
    }
    
    internal struct Config {
        // This is private because the use of 'appConfiguration' is preferred.
        private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        
        // This can be used to add debug statements.
        static var isDebug: Bool {
#if DEBUG
            return true
#else
            return false
#endif
        }
        
        static var appConfiguration: AppConfiguration {
            if isDebug {
                return .Debug
            } else if isTestFlight {
                return .TestFlight
            } else {
                return .AppStore
            }
        }
    }
    
    // Add custom encoding and decoding to include researchID and caregivers
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userID, forKey: .userID)
        try container.encode(environment, forKey: .environment)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(buildVersion, forKey: .buildVersion)
        try container.encode(language, forKey: .language)
        try container.encode(countryCode, forKey: .countryCode)
        try container.encode(userType, forKey: .userType)
        try container.encode(timeStamp, forKey: .timeStamp)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(researchID, forKey: .researchID)
        try container.encode(caregivers, forKey: .caregivers)
        try container.encode(systemVersion, forKey: .systemVersion)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userID = try container.decode(String.self, forKey: .userID)
        environment = try container.decode(String.self, forKey: .environment)
        appVersion = try container.decode(String.self, forKey: .appVersion)
        buildVersion = try container.decode(String.self, forKey: .buildVersion)
        language = try container.decode(String.self, forKey: .language)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        userType = try container.decode(String.self, forKey: .userType)
        timeStamp = try container.decode(String.self, forKey: .timeStamp)
        sessionID = try container.decode(String.self, forKey: .sessionID)
        researchID = try container.decode(String.self, forKey: .researchID)
        caregivers = try container.decode([Person].self, forKey: .caregivers)
        systemVersion = try container.decode(String.self, forKey: .systemVersion)
    }
    
    enum CodingKeys: String, CodingKey {
        case userID
        case environment
        case appVersion
        case buildVersion
        case language
        case countryCode
        case userType
        case timeStamp
        case sessionID
        case researchID
        case caregivers
        case systemVersion
    }
    
    public func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]

        dictionary["userID"] = userID
        dictionary["environment"] = environment
        dictionary["appVersion"] = appVersion
        dictionary["buildVersion"] = buildVersion
        dictionary["language"] = language
        dictionary["countryCode"] = countryCode
        dictionary["userType"] = userType
        dictionary["timeStamp"] = timeStamp
        dictionary["sessionID"] = sessionID
        dictionary["researchID"] = researchID
        dictionary["systemVersion"] = systemVersion

        // Gestisce i caregivers, che sono un array di oggetti `Person`.
        dictionary["caregivers"] = caregivers.map { $0.toDictionary() }

        return dictionary
    }
}
