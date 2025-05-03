//
//  GlobalConstants.swift
//  MirrorHR
//
//  Created by Roberto D'Angelo on 27/09/2020.
//

import Foundation
import RoberdanToolBox
import SwiftUI

/// Global Constants provides application-wide configuration values and defaults
/// used throughout the MirrorHR application for consistent behavior.

// MARK: - Version Info

/// Current build number from the app's Info.plist
public let BUILDNUMBER: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"

/// Current version string from the app's Info.plist
public let VERSION: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"

/// Separator used to format the full version string
public let versionSeparator = "."

/// Full application version string in format "version.build"
public let appVersion: String = VERSION + versionSeparator + BUILDNUMBER
// agvtool next-version -all to increase the build on all schemas. avoid to do it via script in buildins phases as it will refresh packages too

// MARK: - Communication Identifiers

/// Username identifier for iPhone device in socket communications
public let iPhoneSocketUsername = "MirrorHR iPhone"

/// Username identifier for Apple Watch device in socket communications
public let watchSocketUsername = "MirrorHR Watch"

/// Username identifier for macOS device in socket communications
public let macSocketUsername = "MirrorHR MacOS"
// public let BETASOCKET = false

// MARK: - Default Settings

/// Default value for premium version state
public let defaultPremiumVersion = false

/// Separator used between notes and suggestions in text
public let notesSuggestionsSeparator: String = ". "

/// Default duration for delayed stopwatch timer (30 minutes)
public let defaultDelayedStopWatch: TimeInterval = 30 * 60

// MARK: - Heart Rate Flow Manager Defaults

/// Available options for maximum heart rate alarm threshold
/// Used in settings UI for heart rate alarm configuration
public let alarmMaxOptions: [Int] = [70, 80, 90, 100, 110, 120, 125, 130, 135, 140, 145, 150, 155, 160, 165, 170, 180, 190, 200]

/// Available options for minimum heart rate alarm threshold
/// Used in settings UI for heart rate alarm configuration
public let alarmMinOptions: [Int] = [30, 40, 45, 50, 55, 60, 65, 70]

/// Available options for alarm volume levels
/// Used in settings UI for alarm sound configuration
public let alarmVolumeOptions: [Int] = [4, 5, 6, 7, 8, 9, 10]

/// Available options for log duration in minutes
/// Used in settings UI for configuring how long to store logs
public let lenghtMinutesLogsOptions: [Int] = [1, 5, 10, 15, 30]

/// Available options for log duration in seconds
/// Used for shorter duration logs configurations
public let lenghtSecondsLogOptions: [Int] = [5, 7, 8, 10, 15]

/// Available options for battery level warning thresholds
/// Used in settings UI for configuring when to warn about low battery
public let batteryLevelWarningOptions: [Int] = [5, 10, 15, 20]

/// Available options for maximum duration without data before warning
/// Used in settings UI for configuring connectivity warning timeouts (in seconds)
public let maxNoDataWarningOptions: [Int] = [60, 90, 120, 240]

/// Available options for triage time buffer in seconds
/// Used to configure how long to wait before triggering alarms
public let triageTimeBufferOptions: [Int] = [0, 5, 10, 30, 60]

/// Default minimum heart rate threshold for triggering alarms (BPM)
public let defaultAlarmMin: Int = 50

/// Default maximum heart rate threshold for triggering alarms (BPM)
public let defaultAlarmMax: Int = 135

/// Default maximum heart rate considered as deep sleep (BPM)
/// Used for sleep analysis and monitoring
public let defaultDeepSleepMax: Int = 80

/// Default delta value to create warning zones before alarm thresholds
/// Creates a buffer zone before hitting alarm thresholds
public let defaultWarningDelta: Int = 5

/// Time in seconds after which to warn about stale heart rate data
public let lastUpdateWarningDeltaSecs: Int = 10

/// Default minimum heart rate for warning zone
/// Calculated as minimum alarm threshold plus warning delta
public let defaultWarningMin = defaultAlarmMin + defaultWarningDelta

/// Default maximum heart rate for warning zone
/// Calculated as maximum alarm threshold minus warning delta
public let defaultWarningMax = defaultAlarmMax - defaultWarningDelta

/// Default seconds to wait in alarm state before triggering notification
/// Helps reduce false alarms by requiring sustained threshold violation
public let defaultTriageDeltaTimeBeforeFireAlarm: Int = 0

/// Default maximum heart rate considered as light sleep (BPM)
/// Used for sleep analysis and monitoring
public let defaultLightSleepMax: Int = 94

/// Default maximum time interval (in seconds) without heart rate data before triggering a warning
/// Used to detect potential connectivity or monitoring issues
public let defaultMaxIntervalWithoutData: Int = 60 // seconds

/// Default minimum battery level (percentage) at which to trigger low battery notification
/// Ensures users are warned before device shuts down
public let defaultMinBatteryLevelForNotification: Int = 15 // it's a %

// MARK: - System Components

/// Shared debug logging instance
/// Used throughout the app for consistent logging
public let mainDebugger = MainDebugger.shared

/// Key used for storing MirrorHR metadata in HealthKit records
/// Ensures consistent identification of app-generated health records
public let mirrorHRMetadataKey = "MirrorHR" // IMPORTANT: key for metadata in healthkit

public let defaultIntervalBetweenAlarmsAndNotifications: Double = 120 // an alarm every 2 minutes should be ok
public let maxBootingAllowedTime: Double = 45 // max time to wait until workoutsession starts sending data
public let automaticRestartIntervalAfterFalseAlarm: Double = 15 * 60 // restart the monitoring after 10 mins from a false alarm

// ProfileGenerics
public let defaultKidName = "Kid"
public let defaultCity = "Milano"

public let defaultDeviceModel: DeviceModels = .appleWatch
public let defaultAppleWatchAvailability = false
public let defaultPrivacyAccepted = true
public let defaultDebugMode = false
public let defaultCollectTelemetry = true
public let defaultParentalControl = true
public let defaultNotifyWhenRealtimeMonitorEnds = false

public let defaultSoundAlarmOptions = ["loud-alarm", "gentle",
                                       "buzzer", "frenzy", "car-horn", "cuckoo-cuckoo-clock",
                                       "done-for-you", "door-knock", "melodysoft", "goes-without-saying",
                                       "horse-whinnies", "serious-strike", "system-fault",
                                       "you-have-new-message", "medicationReminderSound"]
public let defaultSoundNotificationOptions = defaultSoundAlarmOptions
public let defaultAlarmOptionIndex = 0
public let defaultNotificationOtionIndex = 1
public let defaultAlarmSoundVolume: Float = 0.8
public let defaultNotificationSoundVolume: Float = 0.6

// key parameters sleep constants
public let normalPercForParamsCalc = 0.30

// UI constants
public let defaultViewCornerRadius: CGFloat = 10
public let defaultBtnCornerRadius: CGFloat = 10

// MARK: CornerRadius Default
public let defaultCornerRadius: CGFloat = 8
public let defaultToggleCornerRadius: CGFloat = 16

public let defaultShadowRadius: CGFloat = 10

public let btnDefaultBackgroundGradient = LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.5), Color.blue.opacity(0.5)]), startPoint: .leading, endPoint: .trailing)
public let disabledBtnDefaultBackgroundGradient = LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .leading, endPoint: .trailing)

public let darkGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.5), Color.blue.opacity(0.5)]),
                                                         startPoint: .topLeading,
                                                         endPoint: .bottomTrailing)

public let lightGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                                                          startPoint: .topLeading,
                                                          endPoint: .bottomTrailing)

public let darkOpacity: Double = 0.85
public let lightOpacity: Double = 1

public let chevronUP: String = "chevron.up"
public let chevronDown: String = "chevron.down"

// coder encoder json
public let encoder = JSONEncoder()
public let decoder = JSONDecoder()

// NILS
public let NILSTRING = ""
// public let NILINT = 0
// public let NILCOLORSTRING = ""
// public let NILDATE = Date(timeIntervalSinceReferenceDate: 0)

// default interval before running a new query on healthkit
public let healthQueryDelayInterval: TimeInterval = 300.0
