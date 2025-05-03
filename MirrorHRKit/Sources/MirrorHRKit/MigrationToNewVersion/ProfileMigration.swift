//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 18/06/23.
//

import Foundation
import SwiftUI
import SharedPkg

// MARK: - Profile Generic Settings Migration
internal extension ProfileGenericSettings {
    func migrate2V10IfNeeded() {
        struct ProfileSettingsData: Codable {
            let alphaVersion: Bool?
            let kidsName: String?
            let deviceModel: DeviceModels?
            let usingDevice: Bool?
            let privacyAccepted: Bool?
            let debugMode: Bool?
            let collectTelemetry: Bool?
            let parentalControl: Bool?
            let notifyWhenRealtimeMonitorEnds: Bool?
            let chartShowBands: Bool?
            let chartShowMarkers: Bool?
            let emergencyNumber: String?
            let doctorEmail: String?
            let permissionsDone: Bool?
        }
        
        let fileName = appName + "_ProfileGenerics"
        let userDefaults = UserDefaults.standard
        guard
            let fileContent = userDefaults.string(forKey: fileName),
            let fileContentData = fileContent.data(using: .utf8),
            let decodedData = try? JSONDecoder().decode(ProfileSettingsData.self, from: fileContentData)
        else {
            return
        }
        
        self.premiumVersion = decodedData.alphaVersion ?? defaultPremiumVersion
        self.kidName = decodedData.kidsName ?? defaultKidName
        self.deviceModel = decodedData.deviceModel ?? defaultDeviceModel
        self.appleWatchEnabled = decodedData.usingDevice ?? defaultAppleWatchAvailability
        self.privacyAccepted = decodedData.privacyAccepted ?? defaultPrivacyAccepted
        self.debugMode = decodedData.debugMode ?? defaultDebugMode
        self.collectTelemetry = decodedData.collectTelemetry ?? defaultCollectTelemetry
        self.parentalControl = decodedData.parentalControl ?? defaultParentalControl
        self.notifyWhenRealtimeMonitorEnds = decodedData.notifyWhenRealtimeMonitorEnds ?? defaultNotifyWhenRealtimeMonitorEnds
        self.chartShowBands = decodedData.chartShowBands ?? false
        self.chartShowMarkers = decodedData.chartShowMarkers ?? true
        self.emergencyNumber = decodedData.emergencyNumber ?? "defaultEmergencyNumber".local()
        self.doctorEmail = decodedData.doctorEmail ?? ""
        userDefaults.removeObject(forKey: fileName)
    }
}

extension ProfileGenericSettings {
    internal class MigrateV11IfNeeded {
        let profileGenericSettings: ProfileGenericSettings
        
        // MARK: Published Stored properties
        @PublishedStored(key: Keys.premiumVersion, defaultValue: defaultPremiumVersion)
        var premiumVersion: Bool
        
        @PublishedStored(key: Keys.measurementsUnit, defaultValue: MeasurementsUnit.metric)
        var measurementsUnit: MeasurementsUnit
        
        @PublishedStored(key: Keys.kidName, defaultValue: defaultKidName)
        var kidName: String
        
        @PublishedStored(key: Keys.kidWeight, defaultValue: 1)
        var kidWeight: Double
        
        @PublishedStored(key: Keys.brightness, defaultValue: 0.1)
        var brightness: CGFloat
        
        @PublishedStored(key: Keys.age, defaultValue: "")
        var kidAge: String
        
        @PublishedStored(key: Keys.kidBirthDate, defaultValue: Date())
        var kidBirthDate: Date
        
        @PublishedStored(key: Keys.epilepsyType, defaultValue: EpilepsyType.defaultValue)
        var epilepsyType: EpilepsyType
        
        @PublishedStored(key: Keys.deviceModel, defaultValue: defaultDeviceModel)
        var deviceModel: DeviceModels
        
        @PublishedStored(key: Keys.appleWatchEnabled, defaultValue: defaultAppleWatchAvailability)
        public var appleWatchEnabled: Bool
        
        @PublishedStored(key: Keys.privacyAccepted, defaultValue: defaultPrivacyAccepted)
        var privacyAccepted: Bool
        
        @PublishedStored(key: Keys.debugMode, defaultValue: defaultDebugMode)
        public var debugMode: Bool
        
        @PublishedStored(key: Keys.collectTelemetry, defaultValue: defaultCollectTelemetry)
        var collectTelemetry: Bool
        
        @PublishedStored(key: Keys.parentalControl, defaultValue: defaultParentalControl)
        var parentalControl: Bool
        
        @PublishedStored(key: Keys.notifyWhenRealtimeMonitorEnds, defaultValue: defaultNotifyWhenRealtimeMonitorEnds)
        var notifyWhenRealtimeMonitorEnds: Bool
        
        @PublishedStored(key: Keys.chartShowBands, defaultValue: false)
        var chartShowBands: Bool
        
        @PublishedStored(key: Keys.chartShowMarkers, defaultValue: true)
        var chartShowMarkers: Bool
        
        @PublishedStored(key: Keys.emergencyNumber, defaultValue: "defaultEmergencyNumber".local())
        var emergencyNumber: String
        
        @PublishedStored(key: Keys.doctorEmail, defaultValue: "")
        var doctorEmail: String
        
        init(profileGenericSettings: ProfileGenericSettings) {
            self.profileGenericSettings = profileGenericSettings
        }
        
        func migrateIfNeeded(completion: @escaping (Bool) -> Void) {
            DispatchQueue.main.async { [self] in
                setStorage(UserDefaults.standard, into: self)
                profileGenericSettings.appleWatchEnabled = appleWatchEnabled
                profileGenericSettings.brightness = brightness
                profileGenericSettings.premiumVersion = premiumVersion
                profileGenericSettings.measurementsUnit = measurementsUnit
                profileGenericSettings.kidName = kidName
                profileGenericSettings.kidAge = kidAge
                profileGenericSettings.kidWeight = kidWeight
                profileGenericSettings.kidBirthDate = kidBirthDate
                profileGenericSettings.epilepsyType = epilepsyType
                profileGenericSettings.deviceModel = deviceModel
                profileGenericSettings.privacyAccepted = privacyAccepted
                profileGenericSettings.debugMode = debugMode
                profileGenericSettings.collectTelemetry = collectTelemetry
                profileGenericSettings.parentalControl = parentalControl
                profileGenericSettings.notifyWhenRealtimeMonitorEnds = notifyWhenRealtimeMonitorEnds
                profileGenericSettings.chartShowBands = chartShowBands
                profileGenericSettings.chartShowMarkers = chartShowMarkers
                profileGenericSettings.emergencyNumber = emergencyNumber
                profileGenericSettings.doctorEmail = doctorEmail
                completion(true)
            }
        }
    }
}
