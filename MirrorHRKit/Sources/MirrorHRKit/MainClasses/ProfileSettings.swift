//
//  ProfileSettings.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 22/12/20.
//  Copyright © 2020 FightTheStroke Foundation. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import SharedPkg
import RoberdanToolBox
import MirrorHRTelemetryPackage
import HealthKit
import PermissionsManager

public final class ProfileGenericSettings: Equatable, ObservableObject, ResettableToDefaultSetting, Codable {
    public static var shared = ProfileGenericSettings()
    
    public var resetToDefaultValues = AnyCancellable {}
    
    // MARK: versionControl
    @AppStorage("profileGenericSettingsMigratedToV11") public var isMigratedToV11: Bool = false
    
    // MARK: Published Stored properties
    @AppStorage(Keys.premiumVersion.value) public var premiumVersion: Bool = defaultPremiumVersion
    @AppStorage(Keys.measurementsUnit.value) public var measurementsUnit: MeasurementsUnit = MeasurementsUnit.metric
    @AppStorage(Keys.kidName.value) public var kidName: String = defaultKidName
    @AppStorage(Keys.kidWeight.value) public var kidWeight: Double = 1.0
    @AppStorage(Keys.brightness.value) public var brightness: Double = 0.1
    @AppStorage(Keys.age.value) public var kidAge: String = ""
    @AppStorage(Keys.kidBirthDate.value) public var kidBirthDate: Date = Date() {
        didSet {
            DispatchQueue.main.async { [self] in
                kidAge = calculateKidAge(birthDate: kidBirthDate)?.text ?? ""
            }
            dispatchTelemetryEvent(event: .dateOfBirth(birthDate: kidBirthDate.toDayMonthYear()))
        }
    }
    @AppStorage(Keys.epilepsyType.value) public var epilepsyType: EpilepsyType = EpilepsyType.defaultValue {
        didSet {
            dispatchTelemetryEvent(event: .epilepsyType(type: epilepsyType.rawValue))
        }
    }
    @AppStorage(Keys.deviceModel.value) public var deviceModel: DeviceModels = defaultDeviceModel
    @AppStorage(Keys.appleWatchEnabled.value) var appleWatchEnabled: Bool = defaultAppleWatchAvailability {
        didSet {
            DispatchQueue.main.async {
                if self.appleWatchEnabled {
                    askHealthAuthorization(healthAuthorizationManager: HealthAuthorizationManager())
                }
            }
        }
    }
    @AppStorage(Keys.privacyAccepted.value) public var privacyAccepted: Bool = defaultPrivacyAccepted
    @AppStorage(Keys.debugMode.value) public var debugMode: Bool = defaultDebugMode {
        didSet {
            mainDebugger.turnOnOff(debugMode)
        }
    }
    @AppStorage(Keys.collectTelemetry.value) public var collectTelemetry: Bool = defaultCollectTelemetry
    @AppStorage(Keys.parentalControl.value) public var parentalControl: Bool = defaultParentalControl
    @AppStorage(Keys.notifyWhenRealtimeMonitorEnds.value) public var notifyWhenRealtimeMonitorEnds: Bool = defaultNotifyWhenRealtimeMonitorEnds
    @AppStorage(Keys.chartShowBands.value) public var chartShowBands: Bool = false
    @AppStorage(Keys.chartShowMarkers.value) public var chartShowMarkers: Bool = true
    @AppStorage(Keys.emergencyNumber.value) public var emergencyNumber: String = "defaultEmergencyNumber".local()
    @AppStorage(Keys.doctorEmail.value) public var doctorEmail: String = ""
    
    private init() {
        // check if we have to migrate the data from the previous version
        self.migrate2V10IfNeeded()
        if !isMigratedToV11 {
            MigrateV11IfNeeded(profileGenericSettings: self)
                .migrateIfNeeded(completion: { migrated in
                    self.isMigratedToV11 = migrated
                })
        }
        
        self.resetToDefaultValues = MirrorHRTelemetryPackage.resetToDefaultValuesCommandPublisher
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: {
                self.reset()
                mainDebugger.append("ResetToDefaultValuesPublisher event received from ProfileGenericSettings class init", .event)
            })
    }
    
    public func reset() {
        premiumVersion = defaultPremiumVersion
        kidName = defaultKidName
        kidWeight = 0
        kidBirthDate = Date()
        deviceModel = defaultDeviceModel
        appleWatchEnabled = defaultAppleWatchAvailability
        privacyAccepted = defaultPrivacyAccepted
        debugMode = defaultDebugMode
        collectTelemetry = defaultCollectTelemetry
        if collectTelemetry {
            Telemetries.turnAllOn()
        } else {
            Telemetries.turnAllOff()
        }
        parentalControl = defaultParentalControl
        notifyWhenRealtimeMonitorEnds = defaultNotifyWhenRealtimeMonitorEnds
        chartShowMarkers = false
        chartShowBands = false
        emergencyNumber = "defaultEmergencyNumber".local()
        doctorEmail = ""
        epilepsyType = EpilepsyType.defaultValue
        kidBirthDate = Date()
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case premiumVersion, measurementsUnit, kidName, kidWeight, brightness, kidAge, kidBirthDate, epilepsyType,
             deviceModel, appleWatchEnabled, privacyAccepted, debugMode, collectTelemetry, parentalControl,
             notifyWhenRealtimeMonitorEnds, chartShowBands, chartShowMarkers, emergencyNumber, doctorEmail
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        premiumVersion = try container.decode(Bool.self, forKey: .premiumVersion)
        measurementsUnit = try container.decode(MeasurementsUnit.self, forKey: .measurementsUnit)
        kidName = try container.decode(String.self, forKey: .kidName)
        kidWeight = try container.decode(Double.self, forKey: .kidWeight)
        brightness = try container.decode(Double.self, forKey: .brightness)
        kidAge = try container.decode(String.self, forKey: .kidAge)
        kidBirthDate = try container.decode(Date.self, forKey: .kidBirthDate)
        epilepsyType = try container.decode(EpilepsyType.self, forKey: .epilepsyType)
        deviceModel = try container.decode(DeviceModels.self, forKey: .deviceModel)
        appleWatchEnabled = try container.decode(Bool.self, forKey: .appleWatchEnabled)
        privacyAccepted = try container.decode(Bool.self, forKey: .privacyAccepted)
        debugMode = try container.decode(Bool.self, forKey: .debugMode)
        collectTelemetry = try container.decode(Bool.self, forKey: .collectTelemetry)
        parentalControl = try container.decode(Bool.self, forKey: .parentalControl)
        notifyWhenRealtimeMonitorEnds = try container.decode(Bool.self, forKey: .notifyWhenRealtimeMonitorEnds)
        chartShowBands = try container.decode(Bool.self, forKey: .chartShowBands)
        chartShowMarkers = try container.decode(Bool.self, forKey: .chartShowMarkers)
        emergencyNumber = try container.decode(String.self, forKey: .emergencyNumber)
        doctorEmail = try container.decode(String.self, forKey: .doctorEmail)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(premiumVersion, forKey: .premiumVersion)
        try container.encode(measurementsUnit, forKey: .measurementsUnit)
        try container.encode(kidName, forKey: .kidName)
        try container.encode(kidWeight, forKey: .kidWeight)
        try container.encode(brightness, forKey: .brightness)
        try container.encode(kidAge, forKey: .kidAge)
        try container.encode(kidBirthDate, forKey: .kidBirthDate)
        try container.encode(epilepsyType, forKey: .epilepsyType)
        try container.encode(deviceModel, forKey: .deviceModel)
        try container.encode(appleWatchEnabled, forKey: .appleWatchEnabled)
        try container.encode(privacyAccepted, forKey: .privacyAccepted)
        try container.encode(debugMode, forKey: .debugMode)
        try container.encode(collectTelemetry, forKey: .collectTelemetry)
        try container.encode(parentalControl, forKey: .parentalControl)
        try container.encode(notifyWhenRealtimeMonitorEnds, forKey: .notifyWhenRealtimeMonitorEnds)
        try container.encode(chartShowBands, forKey: .chartShowBands)
        try container.encode(chartShowMarkers, forKey: .chartShowMarkers)
        try container.encode(emergencyNumber, forKey: .emergencyNumber)
        try container.encode(doctorEmail, forKey: .doctorEmail)
    }
}

// MARK: - Equatable
extension ProfileGenericSettings {
    public static func == (lhs: ProfileGenericSettings, rhs: ProfileGenericSettings) -> Bool {
        return lhs.premiumVersion == rhs.premiumVersion &&
        lhs.measurementsUnit == rhs.measurementsUnit &&
        lhs.kidName == rhs.kidName &&
        lhs.kidWeight == rhs.kidWeight &&
        lhs.brightness == rhs.brightness &&
        lhs.kidAge == rhs.kidAge &&
        lhs.kidBirthDate == rhs.kidBirthDate &&
        lhs.epilepsyType == rhs.epilepsyType &&
        lhs.deviceModel == rhs.deviceModel &&
        lhs.appleWatchEnabled == rhs.appleWatchEnabled &&
        lhs.privacyAccepted == rhs.privacyAccepted &&
        lhs.debugMode == rhs.debugMode &&
        lhs.collectTelemetry == rhs.collectTelemetry &&
        lhs.parentalControl == rhs.parentalControl &&
        lhs.notifyWhenRealtimeMonitorEnds == rhs.notifyWhenRealtimeMonitorEnds &&
        lhs.chartShowBands == rhs.chartShowBands &&
        lhs.chartShowMarkers == rhs.chartShowMarkers &&
        lhs.emergencyNumber == rhs.emergencyNumber &&
        lhs.doctorEmail == rhs.doctorEmail
    }
}

// MARK: - Storage
extension ProfileGenericSettings {
    enum Keys: StorageKey {
        case premiumVersion
        case measurementsUnit
        case kidName
        case kidWeight
        case kidBirthDate
        case epilepsyType
        case deviceModel
        case appleWatchEnabled
        case privacyAccepted
        case debugMode
        case collectTelemetry
        case parentalControl
        case notifyWhenRealtimeMonitorEnds
        case chartShowBands
        case chartShowMarkers
        case emergencyNumber
        case doctorEmail
        case watchStreamingStatus
        case brightness
        case age
        
        var value: String {
            switch self {
            case .measurementsUnit: return "ProfileSettings.measurementsUnit"
            case .appleWatchEnabled: return "ProfileSettings.appleWatchEnabled"
            case .chartShowBands: return "ProfileSettings.chartShowBands"
            case .chartShowMarkers: return "ProfileSettings.chartShowMarkers"
            case .collectTelemetry: return "ProfileSettings.collectTelemetry"
            case .debugMode: return "ProfileSettings.debugMode"
            case .deviceModel: return "ProfileSettings.deviceModel"
            case .emergencyNumber: return "ProfileSettings.emergencyNumber"
            case .kidName: return "ProfileSettings.kidName"
            case .notifyWhenRealtimeMonitorEnds: return "ProfileSettings.notifyWhenRealtimeMonitorEnds"
            case .parentalControl: return "ProfileSettings.parentalControl"
            case .premiumVersion: return "ProfileSettings.premiumVersion"
            case .privacyAccepted: return "ProfileSettings.privacyAccepted"
            case .kidWeight: return "ProfileSettings.kidWeight"
            case .kidBirthDate: return "ProfileSettings.kidBirthDate"
            case .epilepsyType: return "ProfileSettigs.epilepsyType"
            case .brightness: return "ProfileSettings.brightness"
            case .age: return "ProfileSettings.kidAge"
            case .doctorEmail: return "ProfileSettings.doctorEmail"
            case .watchStreamingStatus: return "ProfileSettings.watchStreamingStatus"
            }
        }
    }
}

extension ProfileGenericSettings {
    public func calculateKidAge(birthDate: Date) -> (ageComponents: DateComponents, text: String)? {
        let age = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: birthDate,
            to: Date())
        
        guard let years = age.year, let months = age.month, let days = age.day else {
            return nil
        }
        let text = "\(years)\("yearIndicatorString".local()) \(months)\("monthsIndicatorString".local()) \(days)\("dayIndicatorString".local())"
        return  (age, text)
    }
}

extension Date: @retroactive RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}

extension ProfileGenericSettings {
    // MARK: - JSON Conversion
    public func jsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to encode ProfileGenericSettings: \(error)")
            return nil
        }
    }
    
    public static func loadFromJson(jsonString: String) -> ProfileGenericSettings? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(ProfileGenericSettings.self, from: data)
    }
    
    public func loadFromJson(jsonString: String) throws {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON string", code: 1, userInfo: nil)
        }
        
        let decoder = JSONDecoder()
        let decodedSettings = try decoder.decode(ProfileGenericSettings.self, from: jsonData)
        
        DispatchQueue.main.async {
            self.premiumVersion = decodedSettings.premiumVersion
            self.measurementsUnit = decodedSettings.measurementsUnit
            self.kidName = decodedSettings.kidName
            self.kidWeight = decodedSettings.kidWeight
            self.brightness = decodedSettings.brightness
            self.kidAge = decodedSettings.kidAge
            self.kidBirthDate = decodedSettings.kidBirthDate
            self.epilepsyType = decodedSettings.epilepsyType
            self.deviceModel = decodedSettings.deviceModel
            self.appleWatchEnabled = decodedSettings.appleWatchEnabled
            self.privacyAccepted = decodedSettings.privacyAccepted
            self.debugMode = decodedSettings.debugMode
            self.collectTelemetry = decodedSettings.collectTelemetry
            self.parentalControl = decodedSettings.parentalControl
            self.notifyWhenRealtimeMonitorEnds = decodedSettings.notifyWhenRealtimeMonitorEnds
            self.chartShowBands = decodedSettings.chartShowBands
            self.chartShowMarkers = decodedSettings.chartShowMarkers
            self.emergencyNumber = decodedSettings.emergencyNumber
            self.doctorEmail = decodedSettings.doctorEmail
        }
    }
}
