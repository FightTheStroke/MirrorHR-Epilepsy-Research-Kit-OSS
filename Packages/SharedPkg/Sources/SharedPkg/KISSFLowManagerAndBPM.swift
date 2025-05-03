//
//  KISSFLowManagerAndBPM.swift
//  MirrorHR
//
//  Created by Roberto D'Angelo on 21/10/2020.
//

import Combine
import Foundation
import RoberdanToolBox
import SwiftUI
import MirrorHRTelemetryPackage

/// Manages threshold settings for heart rate monitoring and alarm conditions
///
/// KeyFlowThresholds is responsible for storing and managing all threshold values
/// used in heart rate monitoring, including alarm limits, warning zones, and sleep
/// state detection. It persists settings to local storage and ensures consistent
/// threshold application across the application.
///
/// This class follows the Singleton pattern and supports resetting to default values.
/// All threshold changes trigger appropriate recalculations and updates to dependent systems.
public final class KeyFlowThresholds: LocalStorage, Codable, Equatable, ObservableObject, ResettableToDefaultSetting {
    /// Publisher that can be used to reset settings to default values
    public var resetToDefaultValues = AnyCancellable {}
    
    /// Shared singleton instance for global access to threshold settings
    public static var shared = KeyFlowThresholds()
    
    /// Filename for persisting threshold settings to local storage
    let STORAGEFILENAME = appName + "_KeyFlowThresholds"
    
    /// Flag to prevent didSet triggers during initialization
    private var isInitiating: Bool = true
    
    /// Minimum heart rate (in BPM) that will trigger an alarm
    /// 
    /// When heart rate drops below this value, the system will enter
    /// a pre-alarm state and potentially trigger alerts if sustained.
    /// Changes to this property are automatically persisted and will
    /// recalculate dependent thresholds like warning zones.
    @Published public var alarmMin: Int = defaultAlarmMin {
        didSet {
            store(what: "alarmMin", oldValue: oldValue, newValue: alarmMin, recalculateAllParams: true, updateMarkers: true)
        }
    }
    
    /// Maximum heart rate (in BPM) that will trigger an alarm
    /// 
    /// When heart rate exceeds this value, the system will enter
    /// a pre-alarm state and potentially trigger alerts if sustained.
    /// Changes to this property are automatically persisted and will
    /// recalculate dependent thresholds like warning zones.
    @Published public var alarmMax: Int = defaultAlarmMax {
        didSet {
            store(what: "alarmMax", oldValue: oldValue, newValue: alarmMax, recalculateAllParams: true, updateMarkers: true)
        }
    }
    
    /// Time in seconds to wait in alarm condition before triggering notifications
    ///
    /// This delay helps reduce false alarms by requiring the heart rate to remain
    /// outside acceptable bounds for a sustained period before alerting the user.
    /// Changes to this property are automatically persisted but do not trigger
    /// recalculation of other parameters.
    @Published public var triageDeltaTimeBeforeFireAlarm: Int = defaultTriageDeltaTimeBeforeFireAlarm {
        didSet {
            store(what: "triageDeltaTimeBeforeFireAlarm", oldValue: oldValue, newValue: triageDeltaTimeBeforeFireAlarm, recalculateAllParams: false, updateMarkers: false)
        }
    }
    
    /// Minimum heart rate (in BPM) for warning zone
    /// 
    /// When heart rate drops below this value but remains above alarmMin,
    /// the system enters a warning state to alert users of a potential issue.
    /// Changes to this property are automatically persisted and update visual markers.
    @Published public var warningMin: Int = defaultWarningMin {
        didSet {
            store(what: "warningMin",oldValue: oldValue, newValue: warningMin, recalculateAllParams: false, updateMarkers: true)
        }
    }
    
    /// Maximum heart rate (in BPM) for warning zone
    /// 
    /// When heart rate exceeds this value but remains below alarmMax,
    /// the system enters a warning state to alert users of a potential issue.
    /// Changes to this property are automatically persisted and update visual markers.
    @Published public var warningMax: Int = defaultWarningMax { 
        didSet {
            store(what: "warningMax", oldValue: oldValue, newValue: warningMax, recalculateAllParams: false, updateMarkers: true)
        }
    }
    
    /// Maximum heart rate (in BPM) considered as deep sleep
    /// 
    /// Used for sleep analysis and monitoring to identify deep sleep states.
    /// Heart rates below this threshold while sleeping are categorized as deep sleep.
    /// Changes to this property are automatically persisted and update visual markers.
    @Published public var deepSleepMax: Int = defaultDeepSleepMax { 
        didSet {
            store(what: "deepSleepMax", oldValue: oldValue, newValue: deepSleepMax, recalculateAllParams: false, updateMarkers: true)
        }
    }
    
    /// Maximum heart rate (in BPM) considered as light sleep
    /// 
    /// Used for sleep analysis and monitoring to identify light sleep states.
    /// Heart rates between deepSleepMax and this value while sleeping are categorized as light sleep.
    /// Changes to this property are automatically persisted and update visual markers.
    @Published public var lightSleepMax: Int = defaultLightSleepMax { didSet
        {
            store(what: "lightSleepMax", oldValue: oldValue, newValue: lightSleepMax, recalculateAllParams: false, updateMarkers: true)
        }
    }
    
    /// Maximum interval in seconds without heart rate data before triggering a notification
    /// 
    /// Used to detect when the device is not receiving heart rate data,
    /// which could indicate a connection issue or that the device is not being worn.
    /// Changes to this property are automatically persisted.
    @Published public var maxIntervalWithoutData: Int = defaultMaxIntervalWithoutData { didSet
        {
            store(what: "maxIntervalWithoutData", oldValue: oldValue, newValue: maxIntervalWithoutData, recalculateAllParams: false, updateMarkers: false)
        }
    }
    
    /// Minimum battery level percentage that will trigger a low battery notification
    /// 
    /// When battery level drops below this threshold, the system can alert the user
    /// to charge their device if shouldFireLowBattery is enabled.
    /// Changes to this property are automatically persisted.
    @Published public var minBatteryLevelForNotification: Int = defaultMinBatteryLevelForNotification { didSet 
        {
            store(what: "minBatteryLevelForNotification",oldValue: oldValue, newValue: minBatteryLevelForNotification, recalculateAllParams: false, updateMarkers: false)
        }
    }
    
    /// Flag to enable/disable notifications when no heart rate data is received
    /// 
    /// When enabled and no heart rate data is received for longer than maxIntervalWithoutData,
    /// the system will send a notification to alert the user.
    /// Changes to this property are automatically persisted.
    @Published public var shouldFireNoData: Bool = true { didSet
        {
            let myOldValue = oldValue ? 1 : 0
            let myNewValue = shouldFireNoData ? 1 : 0
            store(what: "shouldFireNoData", oldValue: myOldValue, newValue: myNewValue, recalculateAllParams: false, updateMarkers: false)
        }
    }
    
    /// Flag to enable/disable notifications for low battery
    /// 
    /// When enabled and battery level drops below minBatteryLevelForNotification,
    /// the system will send a notification to alert the user.
    /// Changes to this property are automatically persisted.
    @Published public var shouldFireLowBattery: Bool = true { didSet
        {
            let myOldValue = oldValue ? 1 : 0
            let myNewValue = shouldFireLowBattery ? 1 : 0
            store(what: "shouldFireLowBattery", oldValue: myOldValue, newValue: myNewValue, recalculateAllParams: false, updateMarkers: false)
        }
    }
    
    /// Equality operator for comparing two KeyFlowThresholds instances
    ///
    /// Used to determine if two threshold configurations are equivalent
    /// by comparing all their key settings.
    /// - Parameters:
    ///   - lhs: Left-hand side KeyFlowThresholds instance
    ///   - rhs: Right-hand side KeyFlowThresholds instance
    /// - Returns: Boolean indicating if all threshold values match
    public static func == (lhs: KeyFlowThresholds, rhs: KeyFlowThresholds) -> Bool {
        if (lhs.alarmMin != rhs.alarmMin) ||
            (lhs.alarmMax != rhs.alarmMax) ||
            (lhs.deepSleepMax != rhs.deepSleepMax) ||
            (lhs.lightSleepMax != rhs.lightSleepMax) ||
            (lhs.shouldFireNoData != rhs.shouldFireNoData) ||
            (lhs.warningMax != rhs.warningMax) ||
            lhs.warningMin != rhs.warningMin ||
            lhs.triageDeltaTimeBeforeFireAlarm != rhs.triageDeltaTimeBeforeFireAlarm ||
            lhs.shouldFireLowBattery != rhs.shouldFireLowBattery {
            return false
        } else {
            return true
        }
    }
    
    /// Private initializer that loads settings from persistent storage
    ///
    /// Implements the singleton pattern and loads previously saved threshold values.
    /// If no saved values exist, default values are used.
    /// Also sets up the reset event listener to handle reset requests.
    private init() {
        isInitiating = true
        super.init(STORAGEFILENAME)
        let savedVersion = KeyFlowThresholds.loadFromJson(jsonString: load())
        alarmMin = savedVersion?.alarmMin ?? defaultAlarmMin
        alarmMax = savedVersion?.alarmMax ?? defaultAlarmMax
        triageDeltaTimeBeforeFireAlarm = savedVersion?.triageDeltaTimeBeforeFireAlarm ?? defaultTriageDeltaTimeBeforeFireAlarm
        warningMax = savedVersion?.warningMax ?? defaultWarningMax
        warningMin = savedVersion?.warningMin ?? defaultWarningMin
        deepSleepMax = savedVersion?.deepSleepMax ?? defaultDeepSleepMax
        lightSleepMax = savedVersion?.lightSleepMax ?? defaultLightSleepMax
        maxIntervalWithoutData = savedVersion?.maxIntervalWithoutData ?? defaultMaxIntervalWithoutData
        minBatteryLevelForNotification = savedVersion?.minBatteryLevelForNotification ?? defaultMinBatteryLevelForNotification
        shouldFireNoData = savedVersion?.shouldFireNoData ?? true
        shouldFireLowBattery = savedVersion?.shouldFireLowBattery ?? true
        migrateFromPreviousVersionsIfNeeded()
        resetToDefaultValues = resetToDefaultValuesCommandPublisher
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: {
                self.reset()
                mainDebugger.append("ResetToDefaultValuesPublisher event received from KeyFlowThresholds class", .event)
            })
        isInitiating = false
    }
    
    /// Migrates settings from previous versions if needed
    ///
    /// Handles backward compatibility by updating any legacy settings
    /// to their appropriate values in the current version.
    func migrateFromPreviousVersionsIfNeeded() {
        if maxIntervalWithoutData == 30 {
            maxIntervalWithoutData = defaultMaxIntervalWithoutData
        }
    }
    
    /// Stores changes to threshold settings in persistent storage
    ///
    /// Called whenever a threshold value changes to persist the new value
    /// and optionally trigger recalculation of dependent values or UI updates.
    /// - Parameters:
    ///   - what: Name of the parameter being changed
    ///   - oldValue: Previous value of the parameter
    ///   - newValue: New value of the parameter
    ///   - recalculateAllParams: Whether to recalculate dependent parameters
    ///   - updateMarkers: Whether to update UI markers reflecting thresholds
    func store(what: String, oldValue: Int, newValue: Int, recalculateAllParams: Bool, updateMarkers: Bool) {
        if isInitiating {
            return
        }
        if newValue != oldValue {
            DispatchQueue.main.async {
                print("KeyFlowThresholds - Storing \(what) - initializing : \(self.isInitiating) - oldValue: \(oldValue) - newValue: \(newValue)")
                self.save(self.jsonString())
                if recalculateAllParams {
                    self.recalculateAllOtherParams()
                }
                if updateMarkers {
                    print("updatedParametersBroadcasting")
                    updatedParametersBroadcasting()
                }
            }
        }
    }
    
    /// Recalculates dependent threshold parameters
    ///
    /// Automatically adjusts related thresholds when core parameters change,
    /// maintaining appropriate relationships between different threshold levels.
    /// For example, adjusts sleep thresholds based on alarm min/max values.
    func recalculateAllOtherParams() {
        let delta: Double = (Double(alarmMax - alarmMin) * normalPercForParamsCalc)
        if !isInitiating {
            // this control secure sleep params are changed only after class is initiatied, enabling correct storing of sleep params
            deepSleepMax = alarmMin + Int(delta)
            lightSleepMax = deepSleepMax + 1 + Int(delta)
        }
        warningMin = alarmMin + defaultWarningDelta
        warningMax = alarmMax - defaultWarningDelta
    }
    
    /// Keys used for encoding/decoding threshold settings
    private enum CodingKeys: String, CodingKey {
        case
        alarmMin,
        alarmMax,
        deepSleepMax,
        lightSleepMax,
        warningMin,
        warningMax,
        maxIntervalWithoutData,
        minBatteryLevelForNotification,
        shouldFireNoData,
        shouldFireLowBattery,
        triageDeltaTimeBeforeFireAlarm
    }
    
    /// Encodes threshold settings for persistence
    ///
    /// Creates a JSON representation of all threshold settings
    /// for storage in the file system.
    /// - Parameter encoder: The encoder to write data to
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alarmMin, forKey: .alarmMin)
        try container.encode(alarmMax, forKey: .alarmMax)
        try container.encode(deepSleepMax, forKey: .deepSleepMax)
        try container.encode(lightSleepMax, forKey: .lightSleepMax)
        try container.encode(warningMin, forKey: .warningMin)
        try container.encode(warningMax, forKey: .warningMax)
        try container.encode(maxIntervalWithoutData, forKey: .maxIntervalWithoutData)
        try container.encode(minBatteryLevelForNotification, forKey: .minBatteryLevelForNotification)
        try container.encode(shouldFireNoData, forKey: .shouldFireNoData)
        try container.encode(shouldFireLowBattery, forKey: .shouldFireLowBattery)
        try container.encode(triageDeltaTimeBeforeFireAlarm, forKey: .triageDeltaTimeBeforeFireAlarm)
    }
    
    /// Initializes threshold settings from decoded data
    ///
    /// Creates a new instance by decoding values from persistent storage
    /// and sets up the reset event listener.
    /// - Parameter decoder: The decoder to read data from
    public required init(from decoder: Decoder) throws {
        super.init(STORAGEFILENAME)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alarmMin = try container.decode(Int.self, forKey: .alarmMin)
        alarmMax = try container.decode(Int.self, forKey: .alarmMax)
        deepSleepMax = try container.decode(Int.self, forKey: .deepSleepMax)
        lightSleepMax = try container.decode(Int.self, forKey: .lightSleepMax)
        warningMin = try container.decode(Int.self, forKey: .warningMin)
        warningMax = try container.decode(Int.self, forKey: .warningMax)
        maxIntervalWithoutData = try container.decode(Int.self, forKey: .maxIntervalWithoutData)
        minBatteryLevelForNotification = try container.decode(Int.self, forKey: .minBatteryLevelForNotification)
        shouldFireNoData = try container.decode(Bool.self, forKey: .shouldFireNoData)
        shouldFireLowBattery = try container.decode(Bool.self, forKey: .shouldFireLowBattery)
        triageDeltaTimeBeforeFireAlarm = try container.decode(Int.self, forKey: .triageDeltaTimeBeforeFireAlarm)
        
        resetToDefaultValues = resetToDefaultValuesCommandPublisher
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: {
                self.reset()
                mainDebugger.append("ResetToDefaultValuesPublisher event received from KeyFlowThresholds class", .event)
            })
    }
    
    /// Required initializer (unimplemented)
    ///
    /// This initializer is required by the parent class but is not used.
    /// Calling it will result in a fatal error.
    required init(storageFileName _: String) {
        mainDebugger.append("FATAL ERROR: init(storageFileName:) has not been implemented", .fatalError, sourceModule: "KeyFlowThresholds init")
        fatalError("init(storageFileName:) has not been implemented")
    }
    
    /// Required initializer (unimplemented)
    ///
    /// This initializer is required by the parent class but is not used.
    /// Calling it will result in a fatal error.
    required init(_: String) {
        fatalError("init(_:) has not been implemented")
    }
    
    /// Converts threshold settings to a JSON string
    ///
    /// Creates a JSON representation of all threshold settings that can be
    /// stored to persistent storage or transmitted to other devices.
    /// - Returns: JSON string representation of threshold settings
    public func jsonString() -> String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode jsonstring", .error)
            return ""
        }
    }
    
    /// Creates a KeyFlowThresholds instance from a JSON string
    ///
    /// Parses a JSON string containing threshold settings and creates a
    /// new KeyFlowThresholds instance with those settings.
    /// - Parameter jsonString: JSON string representation of threshold settings
    /// - Returns: Optional KeyFlowThresholds instance, or nil if parsing fails
    public static func loadFromJson(jsonString: String) -> KeyFlowThresholds? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(KeyFlowThresholds.self, from: data)
    }
    
    /// Updates this instance's settings from a JSON string
    ///
    /// Parses a JSON string containing threshold settings and updates
    /// this instance's properties with those settings.
    /// - Parameter jsonString: JSON string representation of threshold settings
    public func loadFromJson(jsonString: String) {
        guard let keyFlowThresholdsFromServer: KeyFlowThresholds = KeyFlowThresholds.loadFromJson(jsonString: jsonString) else {
            mainDebugger.append("received KeyFlowThresholds jsonString in the wrong format so can't be loaded", .error, sourceModule: "CommunicationManagerIoS handleStreamingMessage")
            return
        }
        
        alarmMin = keyFlowThresholdsFromServer.alarmMin
        alarmMax = keyFlowThresholdsFromServer.alarmMax
        triageDeltaTimeBeforeFireAlarm = keyFlowThresholdsFromServer.triageDeltaTimeBeforeFireAlarm
        warningMax = keyFlowThresholdsFromServer.warningMax
        warningMin = keyFlowThresholdsFromServer.warningMin
        deepSleepMax = keyFlowThresholdsFromServer.deepSleepMax
        lightSleepMax = keyFlowThresholdsFromServer.lightSleepMax
        maxIntervalWithoutData = keyFlowThresholdsFromServer.maxIntervalWithoutData
        minBatteryLevelForNotification = keyFlowThresholdsFromServer.minBatteryLevelForNotification
        shouldFireNoData = keyFlowThresholdsFromServer.shouldFireNoData
        shouldFireLowBattery = keyFlowThresholdsFromServer.shouldFireLowBattery
    }
    
    /// Resets all threshold settings to their default values
    ///
    /// Restores all thresholds to their factory default settings as defined
    /// in the global constants. Used when the user requests to reset settings
    /// or when settings become corrupted.
    public func reset() {
        alarmMin = defaultAlarmMin
        alarmMax = defaultAlarmMax
        deepSleepMax = defaultDeepSleepMax
        lightSleepMax = defaultLightSleepMax
        warningMin = defaultWarningMin
        warningMax = defaultWarningMax
        maxIntervalWithoutData = defaultMaxIntervalWithoutData
        minBatteryLevelForNotification = defaultMinBatteryLevelForNotification
        shouldFireNoData = true
        shouldFireLowBattery = true
        triageDeltaTimeBeforeFireAlarm = defaultTriageDeltaTimeBeforeFireAlarm
    }
    
    /// Creates a SwiftUI binding for a specific property of KeyFlowThresholds
    ///
    /// Useful for connecting KeyFlowThresholds properties to SwiftUI views
    /// for two-way binding, ensuring changes are properly persisted.
    /// - Parameter property: KeyPath to the property to create a binding for
    /// - Returns: A SwiftUI Binding connected to the shared instance
    public static func binding<T>(
        for property: WritableKeyPath<KeyFlowThresholds, T>
    ) -> Binding<T> {
        .init(
            get: {
                KeyFlowThresholds.shared[keyPath: property]
            },
            set: { value in
                KeyFlowThresholds.shared[keyPath: property] = value
            }
        )
    }
}
