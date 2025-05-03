//
//  LocalizationStrings.swift
//  MirrorHR
//
//  Created by Roberto D'Angelo on 20/12/2020.
//

import Foundation
import RoberdanToolBox

/// # Localization Constants
///
/// This file contains all the localized string constants used throughout the MirrorHR application.
/// Each constant uses NSLocalizedString to retrieve the appropriate translation based on the user's
/// device language settings.
///
/// The strings are organized by functional categories to improve maintainability and help
/// developers locate the appropriate constants for different parts of the application.
///
/// When adding new strings:
/// 1. Ensure they're placed in the appropriate category section
/// 2. Use descriptive variable names that indicate their purpose
/// 3. Add entries to all localization files (Localizable.strings) in each language folder

// MARK: - Tab Navigation Strings
/// Localized strings for the application's main tab navigation

/// Tab title for the checklist feature
public let tabChecklist = NSLocalizedString("tabChecklist", comment: "")

/// Tab title for the real-time monitoring feature
public let tabRealTimeMonitor = NSLocalizedString("tabRealTimeMonitor", comment: "")

/// Tab title for the checklist feature (alternative)
public let tabCheckList = NSLocalizedString("tabCheckList", comment: "")

/// Tab title for the diary/journal feature
public let tabDiary = NSLocalizedString("tabDiary", comment: "")

/// Tab title for the insights/analytics feature
public let tabInsights = NSLocalizedString("tabInsights", comment: "")

/// Tab title for the settings feature
public let tabSettings = NSLocalizedString("tabSettings", comment: "")

/// Tab title for the debug logs feature
public let tabDebugLogs = NSLocalizedString("tabDebugLogs", comment: "")

/// Tab title for the onboarding process
public let tabOnboarding = NSLocalizedString("tabOnboarding", comment: "")

/// Sample image label for real-time monitor when no watch is connected
public let realTimeNoWatchSampleImage = NSLocalizedString("realTimeNoWatchSampleImage", comment: "")

/// Message indicating that an Apple Watch is required
public let youMustHaveWatchString = NSLocalizedString("youMustHaveWatchString", comment: "")

/// Button text for user to indicate they now have an Apple Watch
public let iHaveAWatchNowString = NSLocalizedString("iHaveAWatchNowString", comment: "")

/// Generic error message label
public let errorMsg = NSLocalizedString("errorMsg", comment: "")

/// Message explaining that an Apple Watch is required for certain features
public let appleWatchRequiredMsg = NSLocalizedString("appleWatchRequiredMsg", comment: "")

// MARK: - Symptom Names
/// Localized names for tracked symptoms and medical events

/// Placeholder for empty symptom selection
public let sympt_emptySymptom = NSLocalizedString("sympt_emptySymptom", comment: "")

/// Symptom name for seizure events
public let sympt_seizure = NSLocalizedString("sympt_seizure", comment: "")

/// Symptom name for high heart rate (tachycardia)
public let sympt_highBPM = NSLocalizedString("sympt_highBPM", comment: "")

/// Symptom name for low heart rate (bradycardia)
public let sympt_lowBPM = NSLocalizedString("sympt_lowBPM", comment: "")

/// Symptom name for constipation
public let sympt_constipation = NSLocalizedString("sympt_constipation", comment: "")

/// Symptom name for diarrhea
public let sympt_diarrhea = NSLocalizedString("sympt_diarrhea", comment: "")

/// Symptom name for hiccup
public let sympt_hiccup = NSLocalizedString("sympt_hiccup", comment: "")

/// Symptom name for dizziness/vertigo
public let sympt_dizziness = NSLocalizedString("sympt_dizziness", comment: "")

/// Symptom name for fatigue/tiredness
public let sympt_fatigue = NSLocalizedString("sympt_fatigue", comment: "")

/// Symptom name for fever
public let sympt_fever = NSLocalizedString("sympt_fever", comment: "")

/// Symptom name for headache
public let sympt_headache = NSLocalizedString("sympt_headache", comment: "")

/// Medical event for routine medical examination
public let sympt_medicalExamination = NSLocalizedString("sympt_medicalExamination", comment: "")

/// Medical event for hospitalization
public let sympt_hospitalization = NSLocalizedString("sympt_hospitalization", comment: "")

/// Medical event for emergency room visit
public let sympt_emergencyRoom = NSLocalizedString("sympt_emergencyRoom", comment: "")

/// Symptom name for coughing
public let sympt_coughing = NSLocalizedString("sympt_coughing", comment: "")

/// Symptom name for nausea
public let sympt_nausea = NSLocalizedString("sympt_nausea", comment: "")

/// Symptom name for shortness of breath/dyspnea
public let sympt_shortnessOfBreath = NSLocalizedString("sympt_shortnessOfBreath", comment: "")

/// Symptom name for sore throat
public let sympt_soreThroat = NSLocalizedString("sympt_soreThroat", comment: "")

/// Symptom name for vomiting
public let sympt_vomiting = NSLocalizedString("sympt_vomiting", comment: "")

/// Symptom/state name for excitement (potentially seizure trigger)
public let sympt_excitement = NSLocalizedString("sympt_excitement", comment: "")

/// Symptom name for mood changes
public let sympt_moodChanges = NSLocalizedString("sympt_moodChanges", comment: "")

/// Symptom name for changes in sleep pattern
public let sympt_sleepChanges = NSLocalizedString("sympt_sleepChanges", comment: "")

/// Symptom/trigger name for sleep deprivation
public let sympt_sleepDeprivation = NSLocalizedString("sympt_sleepDeprivation", comment: "")

// MARK: Symptoms
/// Additional symptom and health event string constants

/// Symptom name for changes in appetite
public let sympt_appetiteChanges = NSLocalizedString("sympt_appetiteChanges", comment: "")

/// Label for video log entry in symptoms tracking
public let sympt_videoLog = NSLocalizedString("sympt_videoLog", comment: "")

/// Label for seizure-specific video log entry
public let sympt_videoSeizureLog = NSLocalizedString("sympt_videoSeizureLog", comment: "")

/// Label for text log entry in symptoms tracking
public let sympt_textLog = NSLocalizedString("sympt_textLog", comment: "")

/// Symptom/trigger name for stress
public let sympt_stress = NSLocalizedString("sympt_stress", comment: "")

/// Event name for medication taken as prescribed
public let sympt_medicationTaken = NSLocalizedString("sympt_medicationTaken", comment: "")

/// Event name for missed medication dose
public let sympt_medicationForgotten = NSLocalizedString("sympt_medicationForgotten", comment: "")

/// Label for other/unspecified symptoms
public let sympt_other = NSLocalizedString("sympt_other", comment: "")

/// Event name for emergency medication administered
public let sympt_emergencyMedication = NSLocalizedString("sympt_emergencyMedication", comment: "")

/// Label for support filter in symptoms view
public let sympt_FilterSupport = NSLocalizedString("sympt_FilterSupport", comment: "sympt_FilterSupport")

/// General strings used throughout the application

/// Message about language settings for the user interface
public let languageUIMsg = NSLocalizedString("languageUIMsg", comment: "")

/// Label for language selection in UI
public let languageUI = NSLocalizedString("languageUI_String", comment: "")

/// Short version of the application name
public let shortAppName = NSLocalizedString("shortAppName", comment: "")

/// Website URL for the application's about page
public let aboutWebsiteString = NSLocalizedString("aboutWebsiteString", comment: "")

/// Full application name
public let appName = NSLocalizedString("appName", comment: "")

/// Message indicating an alpha/early version of the app
public let alfaVersionMsg = NSLocalizedString("alfaVersionMsg", comment: "")

/// Error message for when video cannot be saved
public let UNABLESAVEVIDEOMSG = NSLocalizedString("UNABLESAVEVIDEOMSG", comment: "")

/// Message for features that are not yet implemented
public let comingSoonMsg = NSLocalizedString("comingSoonMsg", comment: "")

/// Label for important information
public let importantMsg = NSLocalizedString("importantMsg", comment: "")

/// Main error message when Watch connectivity has issues
public let watchMainErrorMsg = NSLocalizedString("watchMainErrorMsg", comment: "")

/// Acknowledgement button text ("Got it")
public let gotItMsg = NSLocalizedString("gotItMsg", comment: "")

/// Label for unplanned events in tracking
public let unplannedEventMsg = NSLocalizedString("unplannedEventMsg", comment: "")

/// Message for stopping low battery notifications
public let stopLowBatteryNotificationsMsg = NSLocalizedString("stopLowBatteryNotificationsMsg", comment: "")

/// Button text to continue a process
public let continueMsg = NSLocalizedString("continueMsg", comment: "")

/// Time indicator for when an alarm was triggered
public let firedAtMsg = NSLocalizedString("firedAtMsg", comment: "")

/// Message shown when a manual alarm is triggered
public let manualAlarmTriggeredMsg = NSLocalizedString("manualAlarmTriggeredMsg", comment: "")

/// Notes field for manual alarm events
public let manualAlarmTriggeredNotesString = NSLocalizedString("manualAlarmTriggeredNotesString", comment: "")

/// Message shown when a false alarm is manually logged
public let manualFalseAlarmTriggeredMsg = NSLocalizedString("manualFalseAlarmTriggeredMsg", comment: "")

/// Label for indicating heart rate that triggered an event
public let byBPMofMsg = NSLocalizedString("byBPMofMsg", comment: "")

/// Message showing Watch battery level
public let watchBatteryIsMsg = NSLocalizedString("watchBatteryIsMsg", comment: "")

/// Confirmation for enabling low battery notifications
public let doYouWantLowBatteryNotificationsMsg = NSLocalizedString("doYouWantLowBatteryNotificationsMsg", comment: "")

/// Label indicating what triggered an alarm
public let firedByMsg = NSLocalizedString("firedByMsg", comment: "")

/// Heart rate message part 1
public let bpmMsg1 = NSLocalizedString("bpmMsg1", comment: "")

/// Message shown when stopping an unclassified alarm
public let unclassifiedAlarmStopMsg = NSLocalizedString("unclassifiedAlarmStopMsg", comment: "")

/// Strings used in the statistics and insights views

/// Label for seizure statistics section
public let seizureStatsMsg = NSLocalizedString("seizureStatsMsg", comment: "")

/// Button text for creating a video log
public let videoLogBtnMsg = NSLocalizedString("videoLogBtnMsg", comment: "")

/// Button text for logging a seizure
public let seizureLogBtnMsg = NSLocalizedString("seizureLogBtnMsg", comment: "")

/// Message for drilling down data by date
public let drillDownByDateMsg = NSLocalizedString("drillDownByDateMsg", comment: "")

/// Label for symptoms logs section
public let symptomsLogs = NSLocalizedString("symptomsLogs", comment: "")

/// Navigation title for insights section
public let insightsNavigationMsg = NSLocalizedString("insightsNavigationMsg", comment: "")

/// Message shown while analyzing data
public let analyzingDataMsg = NSLocalizedString("analyzingDataMsg", comment: "")

/// Label for time since last seizure event
public let sinceLastEventMsg = NSLocalizedString("sinceLastEventMsg", comment: "")

/// Alternative format for time since last event
public let sinceLastEventString = NSLocalizedString("sinceLastEventString", comment: "")

/// Label for interval between last two seizures
public let intervalBetweenLast2Seizures = NSLocalizedString("intervalBetweenLast2Seizures", comment: "")

/// Label for comparison to previous intervals
public let fromPreviousMsg = NSLocalizedString("fromPreviousMsg", comment: "")

/// Congratulatory message for seizure-free period
public let congratsNoSeizureMsg = NSLocalizedString("congratsNoSeizureMsg", comment: "")

/// Label for saving log entries
public let saveLogMsg = NSLocalizedString("saveLogMsg", comment: "")

/// Label for detailed log view
public let detailLogMsg = NSLocalizedString("detailLogMsg", comment: "")

/// Button text for saving data
public let saveBtnMsg = NSLocalizedString("saveBtnMsg", comment: "")

/// Hint for speech recognition input
public let speechHintMsg = NSLocalizedString("speechHintMsg", comment: "")

/// Cancel action button text
public let cancelActionMsg = NSLocalizedString("cancelActionMsg", comment: "")

/// OK/Confirm action button text
public let okActionMsg = NSLocalizedString("okActionMsg", comment: "")

/// Label for real-time monitoring section
public let realTimeMsg = NSLocalizedString("realTimeMsg", comment: "")

/// Label for alarm section or state
public let alarmMsg = NSLocalizedString("alarmMsg", comment: "")

/// Label for CSV data export option
public let csvExportMsg = NSLocalizedString("csvExportMsg", comment: "")

/// Label for warning messages
public let warningMsg = NSLocalizedString("warningMsg", comment: "")

/// Button text to start monitoring
public let startMsg = NSLocalizedString("startMsg", comment: "")

/// Button text to stop monitoring
public let stopMsg = NSLocalizedString("stopMsg", comment: "")

/// Label for export functionality
public let exportString = NSLocalizedString("exportString", comment: "")

/// Label for older data entries
public let olderString = NSLocalizedString("olderString", comment: "")

/// Label for current week's data
public let thisWeekString = NSLocalizedString("thisWeekString", comment: "")

/// Message indicating parental control is active
public let parentalControlOnString = NSLocalizedString("parentalControlOnString", comment: "")

// MARK: - Onboarding Strings
/// Strings used during the user onboarding process

/// Welcome greeting message
public let ciaoMsg = NSLocalizedString("ciaoMsg", comment: "")

/// Headline for welcome screen
public let ciaoHeadlineMsg = NSLocalizedString("ciaoHeadlineMsg", comment: "")

/// Detailed description for welcome screen
public let ciaoDescriptionMsg = NSLocalizedString("ciaoDescriptionMsg", comment: "")

/// Title for disclaimer screen
public let disclaimerTitleMsg = NSLocalizedString("disclaimerTitleMsg", comment: "")

/// Headline for disclaimer information
public let disclaimerHeadlineMsg = NSLocalizedString("disclaimerHeadlineMsg", comment: "")

/// Detailed description of app disclaimers
public let disclaimerDescriptionMsg = NSLocalizedString("disclaimerDescriptionMsg", comment: "")

/// Title for personalization start screen
public let personalizeStartMsg = NSLocalizedString("personalizeStartMsg", comment: "")

/// Headline for personalization instructions
public let personalizeStartHeadlineMsg = NSLocalizedString("personalizeStartHeadlineMsg", comment: "")

/// Detailed description of personalization process
public let personalizeStartDescription = NSLocalizedString("personalizeStartDescription", comment: "")

/// Image resource name for personalization screen
public let personalizeStartImage = NSLocalizedString("personalizeStartImage", comment: "")

/// Title for name input screen
public let whatsUrNameMsg = NSLocalizedString("whatsUrNameMsg", comment: "")

/// Headline for name input instructions
public let whatsUrNameHeadlineMsg = NSLocalizedString("whatsUrNameHeadlineMsg", comment: "")

/// Image resource name for name input screen
public let whatsUrNameImage = NSLocalizedString("whatsUrNameImage", comment: "")

/// Detailed description for name input
public let whatUrNameDescriptionMsg = NSLocalizedString("whatUrNameDescriptionMsg", comment: "")

/// Title for location input screen
public let whereULiveMsg = NSLocalizedString("whereULiveMsg", comment: "")

/// Headline for location input instructions
public let whereULiveHeadLineMsg = NSLocalizedString("whereULiveHeadLineMsg", comment: "")

/// Image resource name for location input screen
public let whereULiveImage = NSLocalizedString("whereULiveImage", comment: "")

/// Detailed description for location input
public let whereULiveDescriptionMsg = NSLocalizedString("whereULiveDescriptionMsg", comment: "")

/// Title for alarm settings section
public let alarmSettingsMsg = NSLocalizedString("alarmSettingsMsg", comment: "")

/// Section header for Apple Watch availability
public let watchAvailableSectionString = NSLocalizedString("watchAvailableSectionString", comment: "")

/// Toggle label for Apple Watch availability
public let watchAvailableToggleString = NSLocalizedString("watchAvailableToggleString", comment: "")

/// Caption explaining Watch availability toggle
public let watchAvailableToggleCaptionString = NSLocalizedString("watchAvailableToggleCaptionString", comment: "")

/// Label for alarm settings
public let alarmString = NSLocalizedString("alarmString", comment: "")

/// Label for minimum heart rate threshold
public let minBpmMsg = NSLocalizedString("minBpmMsg", comment: "")

/// Image resource name for minimum BPM setting
public let minBpmImage = NSLocalizedString("minBpmImage", comment: "")

/// Description for min/max heart rate thresholds
public let minMaxBpmDescriptionMsg = NSLocalizedString("minMaxBpmDescriptionMsg", comment: "")

/// Label for maximum heart rate threshold
public let maxBpmMsg = NSLocalizedString("maxBpmMsg", comment: "")

/// Image resource name for maximum BPM setting
public let maxBpmImage = NSLocalizedString("maxBpmImage", comment: "")

/// URL string for external link
public let linkDestinationString = NSLocalizedString("linkDestinationString", comment: "")

/// Text explaining device compatibility
public let compatibilityStringContent = NSLocalizedString("compatibilityStringContent", comment: "")

/// Label for developer information
public let developerStringLabel = NSLocalizedString("developerStringLabel", comment: "")

/// Label for developer information
public let developerLinkDestination = NSLocalizedString("developerLinkDestination", comment: "")

/// Label for contact information
public let contactLinkDestination = NSLocalizedString("contactLinkDestination", comment: "")

/// Label for privacy policy
public let privacyPolicyString = NSLocalizedString("privacyPolicyString", comment: "")

/// Label for privacy policy link
public let privacyPolicyLinkLabel = NSLocalizedString("privacyPolicyLinkLabel", comment: "")

/// URL for privacy policy
public let privacyPolicyLinkDestination = NSLocalizedString("privacyPolicyLinkDestination", comment: "")

/// Message for mirror notifications
public let mirrorNotificationMsg = NSLocalizedString("mirrorNotificationMsg", comment: "")

/// Message for mirror notifications on Watch
public let mirrorNotificationsWatchMsg = NSLocalizedString("mirrorNotificationsWatchMsg", comment: "")

/// Image resource name for mirror notifications
public let mirrorNotificationImage = NSLocalizedString("mirrorNotificationImage", comment: "")

/// Detailed description for mirror notifications
public let mirrorNotificationDescriptionMsg = NSLocalizedString("mirrorNotificationDescriptionMsg", comment: "")

/// Title for alarm sound settings
public let alarmSoundTitleMsg = NSLocalizedString("alarmSoundTitleMsg", comment: "")

/// Headline for alarm sound settings
public let alarmSoundHeadlineMsg = NSLocalizedString("alarmSoundHeadlineMsg", comment: "")

/// Image resource name for alarm sound
public let alarmSoundImage = NSLocalizedString("alarmSoundImage", comment: "")

/// Detailed description for alarm sound
public let alarmSoundDescriptionMsg = NSLocalizedString("alarmSoundDescriptionMsg", comment: "")

/// Title for notification sound settings
public let notificationSoundTitleMsg = NSLocalizedString("notificationSoundTitleMsg", comment: "")

/// Headline for notification sound settings
public let notificationSoundHeadlineMsg = NSLocalizedString("notificationSoundHeadlineMsg", comment: "")

/// Image resource name for notification sound
public let notificationSoundImage = NSLocalizedString("notificationSoundImage", comment: "")

/// Detailed description for notification sound
public let notificationSoundDescriptionMsg = NSLocalizedString("notificationSoundDescriptionMsg", comment: "")

/// Title for parental control settings
public let parentalControlTitleMsg = NSLocalizedString("parentalControlTitleMsg", comment: "")

/// Headline for parental control settings
public let parentalControlHeadlineMsg = NSLocalizedString("parentalControlHeadlineMsg", comment: "")

/// Image resource name for parental control
public let parentalControlImage = NSLocalizedString("parentalControlImage", comment: "")

/// Detailed description for parental control
public let parentalControlDescriptionMsg = NSLocalizedString("parentalControlDescriptionMsg", comment: "")

/// Title for emergency contact settings
public let emergencyContactTitleMsg = NSLocalizedString("emergencyContactTitleMsg", comment: "")

/// Headline for emergency contact settings
public let emergencyContactHeadLineMsg = NSLocalizedString("emergencyContactHeadLineMsg", comment: "")

/// Image resource name for emergency contact
public let emergencyContactImage = NSLocalizedString("emergencyContactImage", comment: "")

/// Label for emergency contact
public let emergencyCallLabelMsg = NSLocalizedString("emergencyCallLabelMsg", comment: "")

/// Detailed description for emergency contact
public let emergencyContactDescriptionMsg = NSLocalizedString("emergencyContactDescriptionMsg", comment: "")

/// Default emergency contact number
public let defaultEmergencyString = NSLocalizedString("defaultEmergencyNumber", comment: "")

/// Title for language selection
public let selectLanguage = NSLocalizedString("selectLanguage", comment: "")

/// Message for adding more languages
public let willAddMoreLanguagesMsg = NSLocalizedString("willAddMoreLanguagesMsg", comment: "")

/// Label for language selection
public let whichLanguageDoUSpeak = NSLocalizedString("wichLanguageDoUSpeak", comment: "")

/// Detailed description for emergency contact in About view
public let emergencyContactDescriptionMsg4AboutView = NSLocalizedString("emergencyContactDescriptionMsg4AboutView", comment: "")

/// Title for ready to start screen
public let readyToStartTitleMsg = NSLocalizedString("readyToStartTitleMsg", comment: "")

/// Headline for ready to start screen
public let readyToStartHeadlineMsg = NSLocalizedString("readyToStartHeadlineMsg", comment: "")

/// Image resource name for ready to start screen
public let readyToStartImage = NSLocalizedString("readyToStartImage", comment: "")

/// Detailed description for ready to start screen
public let readyToStartDescriptionMsg = NSLocalizedString("readyToStartDescriptionMsg", comment: "")

/// Label for time before fire alarm in triage
public let triageDeltaTimeBeforeFireAlarmMsg = NSLocalizedString("triageDeltaTimeBeforeFireAlarmMsg", comment: "")

/// Label for weekdays
public let weekdaysString = NSLocalizedString("weekdaysString", comment: "")

/// Label for weekends
public let weekendString = NSLocalizedString("weekendString", comment: "")

/// Label for logged at time
public let loggedAtString = NSLocalizedString("loggedAtString", comment: "")

/// Label for from time
public let fromString = NSLocalizedString("fromString", comment: "")

/// Label for to time
public let toString = NSLocalizedString("toString", comment: "")

/// Label for length
public let LenghtString = NSLocalizedString("LenghtString", comment: "")

/// Label for notes
public let notesString = NSLocalizedString("notesString", comment: "")

/// Label for when question
public let whenQuestion = NSLocalizedString("whenQuestion", comment: "")

/// Label for editing notes
public let editNotesString = NSLocalizedString("editNotesString", comment: "")

/// Label for privacy acceptance
public let privacyAcceptanceMsg = NSLocalizedString("privacyAcceptanceMsg", comment: "")

/// Label for test alarm button
public let testAlarmBtnMsg = NSLocalizedString("testAlarmBtnMsg", comment: "")

/// Label for test low battery button
public let testLowBatteryBtnMsg = NSLocalizedString("testLowBatteryBtnMsg", comment: "")

/// Label for test alarm sound background
public let testAlarmSoundBgkMsg = NSLocalizedString("testAlarmSoundBgkMsg", comment: "")

/// Label for test notification sound
public let testNotificationSoundMsg = NSLocalizedString("testNotificationSoundMsg", comment: "")

// MARK: profile view
/// Label for name
public let nameString = NSLocalizedString("nameString", comment: "")

/// Label for living in
public let livingInString = NSLocalizedString("livingInString", comment: "")

/// Label for alarm settings footer
public let alarmSettingsFooterMsg = NSLocalizedString("alarmSettingsFooterMsg", comment: "")

/// Label for parental control profile
public let parentalControlProfileMsg = NSLocalizedString("parentalControlProfileMsg", comment: "")

/// Label for recording a video
public let recordAVideoMsg = NSLocalizedString("recordAVideoMsg", comment: "")

/// Label for notification footer
public let notificationFooterMsg = NSLocalizedString("notificationFooterMsg", comment: "")
public let noDataNotificationMsg = NSLocalizedString("noDataNotificationMsg", comment: "")
public let batteryLevelProfileMsg = NSLocalizedString("batteryLevelProfileMsg", comment: "")
public let sleepSettingsTitleMsg = NSLocalizedString("sleepSettingsTitleMsg", comment: "")
public let sleepSettingsFooterMsg = NSLocalizedString("sleepSettingsFooterMsg", comment: "")
public let deepSleepMaxBpmMsg = NSLocalizedString("deepSleepMaxBpmMsg", comment: "")
public let lightSleepMaxBpmMsg = NSLocalizedString("lightSleepMaxBpmMsg", comment: "")
public let notificationSettingsHeaderMsg = NSLocalizedString("notificationSettingsHeaderMsg", comment: "")
public let notificationSettingsFooterMsg = NSLocalizedString("notificationSettingsFooterMsg", comment: "")
public let shouldFireNoDataMsg = NSLocalizedString("shouldFireNoDataMsg", comment: "")
public let shouldFireLowBatteryMsg = NSLocalizedString("shouldFireLowBatteryMsg", comment: "")
public let notifyRealTimeEndMsg1 = NSLocalizedString("notifyRealTimeEndMsg1", comment: "")
public let notifyRealTimeEngMsg2 = NSLocalizedString("notifyRealTimeEngMsg2", comment: "")
public let aboutMsg = NSLocalizedString("aboutMsg", comment: "")
public let defaultQuickLogNote = NSLocalizedString("defaultQuickLogNote", comment: "")
public let howLongDidItLastMsg = NSLocalizedString("howLongDidItLastMsg", comment: "")
public let debugModeMsg = NSLocalizedString("debugModeMsg", comment: "")
public let developerMode = NSLocalizedString("developerMode", comment: "")
public let migrateDBMsg = NSLocalizedString("migrateDBMsg", comment: "")
public let logsSoFarMsg = NSLocalizedString("logsSoFarMsg", comment: "")
public let seizuresSoFarMsg = NSLocalizedString("seizuresSoFarMsg", comment: "")
public let seizuresOnlyFilterMsg = NSLocalizedString("seizuresOnlyFilterMsg", comment: "")
public let tagEndOfSeizure = NSLocalizedString("tagEndOfSeizure", comment: "")
public let editLogNotesMsg = NSLocalizedString("editLogNotesMsg", comment: "")
public let logASymptomMsg4LogsView = NSLocalizedString("logASymptomMsg4LogsView", comment: "")
public let emptySinceLastEventString = NSLocalizedString("emptySinceLastEventString", comment: "")
public let logsInTotalMsg = NSLocalizedString("logsInTotalMsg", comment: "")
public let resetAllMsg = NSLocalizedString("resetAllMsg", comment: "")
public let restartOnboardingMsg = NSLocalizedString("restartOnboardingMsg", comment: "")
public let developerString = NSLocalizedString("developerString", comment: "")
public let appNameString = NSLocalizedString("appNameString", comment: "")
public let versionString = NSLocalizedString("versionString", comment: "")
public let compatibilityString = NSLocalizedString("compatibilityString", comment: "")
public let contactsString = NSLocalizedString("contactsString", comment: "")
public let contactLabelMsg = NSLocalizedString("contactLabelMsg", comment: "")
public let websiteString = NSLocalizedString("websiteString", comment: "")
public let sampleChartDataMsg = NSLocalizedString("sampleChartDataMsg", comment: "")
public let notificationTitleMsg = NSLocalizedString("notificationTitleMsg", comment: "")
public let realTimeWarningMsg = NSLocalizedString("realTimeWarningMsg", comment: "")
public let chartOptionsTitleMsg = NSLocalizedString("chartOptionsTitleMsg", comment: "")
public let showMarkersMsg = NSLocalizedString("showMarkersMsg", comment: "")
public let showBandsMsg = NSLocalizedString("showBandsMsg", comment: "")
public let reset2DefaultMsg = NSLocalizedString("reset2DefaultMsg", comment: "")
public let seeAllSettingsMsg = NSLocalizedString("seeAllSettingsMsg", comment: "")
public let realTimeOffMsg = NSLocalizedString("realTimeOffMsg", comment: "")
public let bootingProgressMsg = NSLocalizedString("bootingProgressMsg", comment: "")
public let lastBpmMsg = NSLocalizedString("lastBpmMsg", comment: "")
public let secsAgoMsg = NSLocalizedString("secsAgoMsg", comment: "")
public let bPmLabelMsg = NSLocalizedString("bPmLabelMsg", comment: "")
public let keySettingsNavigationTitleMsg = NSLocalizedString("keySettingsNavigationTitleMsg", comment: "")
public let legendaLabelMsg = NSLocalizedString("legendaLabelMsg", comment: "")
public let deepSleepLabelMsg = NSLocalizedString("deepSleepLabelMsg", comment: "")
public let lightSleepLabelMsg = NSLocalizedString("lightSleepLabelMsg", comment: "")
public let awakeLabelMsg = NSLocalizedString("awakeLabelMsg", comment: "")
public let tagFalseAlarmTitleMsg = NSLocalizedString("tagFalseAlarmTitleMsg", comment: "")
public let tagFalseAlarmActionMsg = NSLocalizedString("tagFalseAlarmActionMsg", comment: "")
public let tagFalseAlarmAllGoodMsg = NSLocalizedString("tagFalseAlarmAllGoodMsg", comment: "")
public let saveSeizureMsg = NSLocalizedString("saveSeizureMsg", comment: "")
public let seizureLabelMsg = NSLocalizedString("seizureLabelMsg", comment: "")
public let falseAlarmSuggestion1 = NSLocalizedString("falseAlarmSuggestion1", comment: "")
public let falseAlarmSuggestion2 = NSLocalizedString("falseAlarmSuggestion2", comment: "")
public let falseAlarmSuggestion3 = NSLocalizedString("falseAlarmSuggestion3", comment: "")
public let elapsedTimeString = NSLocalizedString("elapsedTimeString", comment: "")
public let whatTimeIsNowString = NSLocalizedString("whatTimeIsNowString", comment: "")
public let defaultCityString = NSLocalizedString("defaultCityString", comment: "")
public let initialBatteryMsg = NSLocalizedString("initialBatteryMsg", comment: "")
public let logLabelMsg = NSLocalizedString("logLabelMsg", comment: "")
public let offLabelMsg = NSLocalizedString("offLabelMsg", comment: "")
public let tap3timesMsg = NSLocalizedString("tap3timesMsg", comment: "")
public let tagVideoSeizure = NSLocalizedString("tagVideoSeizure", comment: "")
public let watchAppNotInstalledString = NSLocalizedString("watchAppNotInstalledString", comment: "")
public let cantCommunicateWatchString = NSLocalizedString("cantCommunicateWatchString", comment: "")
public let watchNotPairedString = NSLocalizedString("watchNotPairedString", comment: "")
public let watchNotReachableString = NSLocalizedString("watchNotReachableString", comment: "")
public let canTFireNotificationString = NSLocalizedString("canTFireNotificationString", comment: "")
public let canTStartSessionString = NSLocalizedString("canTStartSessionString", comment: "")
public let soSorryString = NSLocalizedString("soSorryString", comment: "")
public let shareFeedbackString = NSLocalizedString("shareFeedback", comment: "")
public let saveAndCloseString = NSLocalizedString("saveAndCloseString", comment: "")
public let noDataReceivedString = NSLocalizedString("noDataReceivedString", comment: "")
public let alarmFiredAtString = NSLocalizedString("alarmFiredAtString", comment: "")
public let checkRangeString = NSLocalizedString("checkRangeString", comment: "")
public let alarmEventString = NSLocalizedString("alarmEventString", comment: "")
public let warningEventString = NSLocalizedString("warningEventString", comment: "")
public let noDataEventString = NSLocalizedString("noDataEventString", comment: "")
public let noDataEventStringV2 = NSLocalizedString("NoDataEventStringV2", comment: "")
public let lowBatteryEventString = NSLocalizedString("lowBatteryEventString", comment: "")
public let unclassifiedEventString = NSLocalizedString("unclassifiedEventString", comment: "")
public let handleSeizureEventString = NSLocalizedString("handleSeizureEventString", comment: "")
public let handleFalseAlarmEventString = NSLocalizedString("handleFalseAlarmEventString", comment: "")
public let stopFromWatchEventString = NSLocalizedString("stopFromWatchEventString", comment: "")
public let sessionStopFromPhoneEventString = NSLocalizedString("sessionStopFromPhoneEventString", comment: "")
public let criticalErrorEventString = NSLocalizedString("criticalErrorEventString", comment: "")
public let criticalErrorSorryEventString = NSLocalizedString("criticalErrorSorryEventString", comment: "")
public let testSoundEventString = NSLocalizedString("testSoundEventString", comment: "")
public let notificationString = NSLocalizedString("notificationString", comment: "")
public let sessionBootingEventString = NSLocalizedString("sessionBootingEventString", comment: "")
public let manualAlarmEventString = NSLocalizedString("manualAlarmEventString", comment: "")
public let dayIndicatorString = NSLocalizedString("dayIndicatorString", comment: "")
public let minutesIndicatorString = NSLocalizedString("minutesIndicatorString", comment: "")
public let secondsIndicatorString = NSLocalizedString("secondsIndicatorString", comment: "")
public let hoursIndicatorString = NSLocalizedString("hoursIndicatorString", comment: "")
public let eventsString = NSLocalizedString("eventsString", comment: "")
public let insightsFilterToggleLeftString = NSLocalizedString("insightsFilterToggleLeftString", comment: "")
public let insightClassInfoString = NSLocalizedString("insightClassInfoString", comment: "")
public let symptomString = NSLocalizedString("symptomString", comment: "")
public let potentialTriggerString = NSLocalizedString("potentialTriggerString", comment: "")
public let severeEventString = NSLocalizedString("severeEventString", comment: "")
public let goodHabitString = NSLocalizedString("goodHabitString", comment: "")
public let badHabitString = NSLocalizedString("badHabitString", comment: "")
public let deprecatedDefaultQuickLogNote = NSLocalizedString("deprecatedDefaultQuickLogNote", comment: "")
public let askPermissionsTitle = NSLocalizedString("askPermissionsTitle", comment: "")
public let aksPermissionsHeadline = NSLocalizedString("aksPermissionsHeadline", comment: "")
public let checkPermissionsString = NSLocalizedString("checkPermissionsString", comment: "")
public let thanksForPermissionsString = NSLocalizedString("thanksForPermissionsString", comment: "")
public let medicationAlarmMessage = NSLocalizedString("medicationAlarmMessage", comment: "")
public let medicationTakenString = NSLocalizedString("medicationTakenString", comment: "")
public let medicationSnoozeString = NSLocalizedString("medicationSnoozeString", comment: "")
public let medicationSnoozeStringDescription = NSLocalizedString("medicationSnoozeStringDescription", comment: "")
public let addMedicationReminderString = NSLocalizedString("addMedicationReminderString", comment: "")
public let yesString = NSLocalizedString("yes_String", comment: "")
public let noString = NSLocalizedString("no_String", comment: "")
public let deleteAllRemindersString = NSLocalizedString("deleteAllRemindersString", comment: "")
public let confirmString = NSLocalizedString("confirmString", comment: "")
public let confirmDeleteMedicationRemindersMsg = NSLocalizedString("confirmDeleteMedicationRemindersMsg", comment: "")
public let medicationAlarmFooter = NSLocalizedString("medicationAlarmFooter", comment: "")
public let iPhoneBatteryIsMsg = NSLocalizedString("iPhoneBatteryIsMsg", comment: "")
public let closeButtonString = NSLocalizedString("closeButtonString", comment: "")
public let addButtonString = NSLocalizedString("addButtonString", comment: "")
public let nextScheduledRemindersString = NSLocalizedString("nextScheduledRemindersString", comment: "")
public let medicationsString = NSLocalizedString("medications_String", comment: "")
public let allLogsString = NSLocalizedString("allLogs", comment: "")
public let reportAsMissedMedicationString = NSLocalizedString("reportAsMissedMedicationString", comment: "")
public let medicationNotificationBodyMessage = NSLocalizedString("medicationNotificationBodyMessage", comment: "")
public let medicationAlarmString = "medicationAlarmString".local()
public let medicationAlarmViewTitle = "medicationAlarmViewTitle".local()
public let letMeUpdateMissedMedicationString = NSLocalizedString("letMeUpdateMissedMedicationString", comment: "")
public let bpmTakesTimeMsg = NSLocalizedString("bpmTakesTimeMsg", comment: "")
public let telemetrySectionString = NSLocalizedString("telemetrySectionString", comment: "")
