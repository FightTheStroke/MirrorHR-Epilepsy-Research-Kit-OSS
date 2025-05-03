







```mermaid
classDiagram

  class MyGenericPicker {
    <<interface>>
    +String description
    +String? image
  }
  MyGenericPicker *-- String : composition
  MyGenericPicker *-- String : composition
  MyGenericPicker o-- String : aggregation


  class TherapyEntities {
    <<interface>>
  }


  class Alarm {
    +TimeInterval start
    +TimeInterval end
    +TimeInterval lenght
    +TimeInterval soFar
    +Bool isActive
    +SeverityRanges? severity
    +HealthKitMetadaString metaData
    -Timer? timer
    -SymptomsManager seizures
    -MainTimer currentTime
    -KISSFlowManager kissFlowManager
    +startTracking(firingBPM:manuallyTriggered:) 
    +saveSeizure() 
    +saveFalseAlarm(firingBPM:notes:restartMonitorAutomatically:) 
    +saveUnspecifiedAlarm() 
    -stopTracking() 
  }
  Alarm *-- Alarm : composition
  Alarm *-- SeverityRanges : composition
  Alarm *-- HealthKitMetadaString : composition
  Alarm *-- SymptomsManager : composition
  Alarm *-- KISSFlowManager : composition


  class AllHealthQuantitiesReader {
    +HealthQuantities healthQuantities
    +readAllHealthQuantitiesMinMax(startDate:endDate:completion:) 
  }
  AllHealthQuantitiesReader *-- AllHealthQuantitiesReader__HealthQuantities : composition


  class AnnotationValueProvider {
    +formatValue(with:) 
  }


  class AppDelegate {
    +application(_:didFinishLaunchingWithOptions:) 
    +brightnessDidChange() 
    +application(_:supportedInterfaceOrientationsFor:) UIInterfaceOrientationMask
    +applicationWillTerminate(_:) 
    +applicationWillResignActive(_:) 
  }
  AppDelegate *-- UIInterfaceOrientationMask : composition


  class AudioVideoLogV1 {
    +Int id
    +String transcript
    +String logPrefix
    +String logCoreName
    +String logExt
    +String filename
    +MirrorHRFileTypes fileType
    +String userID
    +Bool save2Cloud
    +String cloudPath
    +String date
    +String videoDataFullFileName
    +Date dateLog
    +URL url
    +String videoDataFileName
    +saveVideoData(videoData:) 
    +jsonString() String
  }
  AudioVideoLogV1 *-- Int : composition
  AudioVideoLogV1 *-- String : composition
  AudioVideoLogV1 *-- String : composition
  AudioVideoLogV1 *-- String : composition
  AudioVideoLogV1 *-- String : composition
  AudioVideoLogV1 *-- String : composition
  AudioVideoLogV1 *-- MirrorHRFileTypes : composition
  AudioVideoLogV1 *-- String : composition
  AudioVideoLogV1 *-- String : composition
  AudioVideoLogV1 *-- String : composition
  AudioVideoLogV1 *-- String : composition
  AudioVideoLogV1 *-- Date : composition
  AudioVideoLogV1 *-- String : composition


  class AudioVideoLogV2 {
    +Int id
    +String transcript
    +String logPrefix
    +String logCoreName
    +String logExt
    +String filename
    +MirrorHRFileTypes fileType
    +String userID
    +Bool save2Cloud
    +String cloudPath
    +String date
    +[AudioVideoMetadata] NLPMetaData
    +String videoDataFullFileName
    +Date dateLog
    +URL? url
    +String videoDataFileName
    +String nLPMetaData2JsonString
    +saveVideoData(videoData:) 
    +jsonString() String
  }
  AudioVideoLogV2 *-- Int : composition
  AudioVideoLogV2 *-- String : composition
  AudioVideoLogV2 *-- String : composition
  AudioVideoLogV2 *-- String : composition
  AudioVideoLogV2 *-- String : composition
  AudioVideoLogV2 *-- String : composition
  AudioVideoLogV2 *-- MirrorHRFileTypes : composition
  AudioVideoLogV2 *-- String : composition
  AudioVideoLogV2 *-- String : composition
  AudioVideoLogV2 *-- String : composition
  AudioVideoLogV2 *-- String : composition
  AudioVideoLogV2 *-- Date : composition
  AudioVideoLogV2 *-- String : composition
  AudioVideoLogV2 *-- String : composition
  AudioVideoLogV2 o-- AudioVideoMetadata : aggregation


  class AugumentVideoLogFlowManager {
    -CompletionAction completion
    -String? transcript
    -Bool isNLPAvailableForThisLanguage
    -Double? sentiment
    -Date startTime
    -ArrayOfSymptoms? suggestedSymptoms
    -PossibleOutputs output
    -URL videoURL
    +AIFlowStatuses aIFlowStatus
    +start(completion:) 
    +applyNLP() 
    -applyNLPInBackground(in:callback:) 
    +applyBasicSearch() 
    +detectSentiment() 
    -speechRecognition() 
    +askUserValidation() 
    +test(completion:) 
    +testSentiment(fakeTranscript:completion:) 
    +testNLP(fakeTranscript:completion:) 
    +testSearch(fakeTranscript:completion:) 
  }
  AugumentVideoLogFlowManager *-- String : composition
  AugumentVideoLogFlowManager *-- Date : composition
  AugumentVideoLogFlowManager *-- ArrayOfSymptoms : composition
  AugumentVideoLogFlowManager *-- AugumentVideoLogFlowManager__PossibleOutputs : composition
  AugumentVideoLogFlowManager *-- AIFlowStatuses : composition


  class BPMRealTimePAletteProvider {
    -KeyFlowThresholds flowThresholds
    +KISSFlowManager kissFlowManager
    +SCIUnsignedIntegerValues strokeColors
    +SCIUnsignedIntegerValues fillColors
    +update() 
  }
  BPMRealTimePAletteProvider *-- KISSFlowManager : composition


  class BlockingActionInProgressModel {
    +Bool blockingActionIsInProgress
  }
  BlockingActionInProgressModel *-- BlockingActionInProgressModel : composition


  class CheckiPhoneBatteryTimer {
    +Int iPhoneBatteryStatus
  }
  CheckiPhoneBatteryTimer *-- CheckiPhoneBatteryTimer : composition
  CheckiPhoneBatteryTimer *-- Int : composition


  class CommunicationManagerIoS {
    -MirrorHRMainClass mirrorHR
    -ProfileGenericSettings profileGenericSettings
    -KeyFlowThresholds keyFlowThresholds
    +Int watchBatteryLevel
    +Bool watchAppInstalledAndPaired
    +Bool activationComplete
    +AnyCancellable streamingMessagesSubscriber
    +WCSession? validReachableSession
    +session(_:activationDidCompleteWith:error:) 
    +session(_:didReceiveMessage:replyHandler:) 
    +sessionReachabilityDidChange(_:) 
    +handleStreamingMessage(_:) 
  }
  CommunicationManagerIoS *-- CommunicationManagerIoS : composition
  CommunicationManagerIoS *-- MirrorHRMainClass : composition
  CommunicationManagerIoS *-- ProfileGenericSettings : composition
  CommunicationManagerIoS *-- Int : composition


  class DeviceOrientation {
    +Orientation orientation
  }
  DeviceOrientation *-- DeviceOrientation : composition


  class FinalSuggestedSymptoms {
    +[HandledSymptomsEvents] symptoms
    +[Validator] validator
    +SymptomsManager symptomsManager
    +prepare4Validation(suggestedSymptoms:) 
    +publishResults() 
  }
  FinalSuggestedSymptoms *-- FinalSuggestedSymptoms : composition
  FinalSuggestedSymptoms *-- SymptomsManager : composition
  FinalSuggestedSymptoms o-- HandledSymptomsEvents : aggregation
  FinalSuggestedSymptoms o-- Validator : aggregation


  class FreshBPM {
    -MirrorHRMainClass mirrorHRMainClass
    -KISSFlowManager kissFlowManager
    -Bool telemetryBpmConsent
    +Int bpm
    +FlowStages eventStage
    +Color color
    +TimeInterval receivedAt
    -TimeInterval lastBPMReceivedAt
    -TimeInterval sentAt
    +UUID sessionID
    +String jsonString
    +landFreshBPM(_:) 
    +analyzeFreshBPM() 
    +encode(to:) 
  }
  FreshBPM *-- FreshBPM : composition
  FreshBPM *-- MirrorHRMainClass : composition
  FreshBPM *-- KISSFlowManager : composition
  FreshBPM *-- Int : composition
  FreshBPM *-- String : composition


  class HalfSheetController {
    +viewWillAppear(_:) 
  }


  class HealthKitTools {
    +Bool queryBPMInProgress
    +Bool querySeizuresInProgress
    +Int analyzedRecordsForInsights
    +DailyMoods dailyMood
    -HealthAuthorizationProtocol healthAuthorizationManager
    +HKHealthStore healthStore
    -HKQuantityType heartRateType
    -HKUnit heartRateUnit
    -Date endDate
    -[NSSortDescriptor] sortDescriptors
    +readhBPMfromHealthKitOnDateAndFillChart(startDateQuery:endDateQuery:destinationDataSeries:chartSurface:) 
    +deleteSample(_:) 
    +saveSymptomsWithSeverityToHealthKStore(symptoms:severity:startTime:endTime:metadata:) 
    +saveSleepDataToHealthStore(startTime:endTime:type:) 
  }
  HealthKitTools *-- HealthKitTools : composition
  HealthKitTools *-- Int : composition
  HealthKitTools *-- DailyMoods : composition
  HealthKitTools *-- Date : composition
  HealthKitTools o-- NSSortDescriptor : aggregation


  class ImportExportViewModel {
    +Int howManyLastDays
    +String attachmentPath
    -SymptomsManager symptomsManager
    -BlockingActionInProgressModel blockingActionInProgressModel
    -String? csvContent
    +Bool isShowingAlert
    +Bool isShowingMailView
    +Bool isFileImporterShowing
    +MyAlert myAlert
    +ImportExportStatus status
    +some View menuView
    +some View confirmImportAction
    +shareBtnAction() 
    +sendEmatilBtnAction() 
    +backupBtnAction() 
    +restoreSymptoms(_:) 
  }
  ImportExportViewModel *-- ImportExportViewModel : composition
  ImportExportViewModel *-- Int : composition
  ImportExportViewModel *-- String : composition
  ImportExportViewModel *-- SymptomsManager : composition
  ImportExportViewModel *-- BlockingActionInProgressModel : composition
  ImportExportViewModel *-- String : composition
  ImportExportViewModel *-- MyAlert : composition
  ImportExportViewModel *-- ImportExportViewModel__ImportExportStatus : composition


  class InsightsClass {
    -HealthKitTools healthKitTools
    +SCIXyDataSeries bpmInsightsDataSeries
    +SciChartSurfaceViewRep insightsChartSurfaceView
    +Date startDate
    +Date endDate
    +Int preselectedRanges
    +initializeInsightsView() 
    +initializeInsightsView(startDate:endDate:) 
    +showFilteredInsightsClass(dateHeader:) 
    +showBPMSession(fromDate:toDate:) 
    +showFullDayBPM(fromDate:toDate:) 
  }
  InsightsClass *-- InsightsClass : composition
  InsightsClass *-- HealthKitTools : composition
  InsightsClass *-- SciChartSurfaceViewRep : composition
  InsightsClass *-- Date : composition
  InsightsClass *-- Date : composition
  InsightsClass *-- Int : composition


  class KISSFlowManager {
    +KeyFlowThresholds keyFlowThresholds
    +FlowStages currentStage
    +TimeInterval firstAlarmReceivedAt
    +TimeInterval triageLenght
    +Bool alarmDispatched
    -NotificationManager notificationManager
    +TimeInterval lastBPMAnalyzedAt
    +UUID sessionID
    +analyzeFlowForBPM(_:) 
    +returnColorOnlyForBPM(_:) 
    +start(sessionID:) 
    +resetAlarm() 
    +stop() 
  }
  KISSFlowManager *-- KISSFlowManager : composition
  KISSFlowManager *-- NotificationManager : composition


  class KeySettingsView__KeySettingsViewModel {
    +SheetViewController sheetView
    +KeyFlowThresholds keyFlowThresholds
    +ProfileGenericSettings profileGenericSettings
    +StreamingManager streamingManager
    +SoundOptions soundOptions
    +TabViewController tabViewController
    +sampleChartDataPressed() 
    +openAllSettings() 
  }
  KeySettingsView__KeySettingsViewModel *-- KeySettingsView__KeySettingsViewModel : composition
  KeySettingsView__KeySettingsViewModel *-- SheetViewController : composition
  KeySettingsView__KeySettingsViewModel *-- ProfileGenericSettings : composition
  KeySettingsView__KeySettingsViewModel *-- TabViewController : composition


  class MedicationManager {
    +UnknownTypeSoAddTypeAttributionToVariable eraseCommandSubscriber
    +Date wakeUp
    +Recurrence recurrence
    +[UNNotificationRequest] medicationReminders
    +Bool showUserActions
    +Int snoozeCounter
    +NotificationManager notificationManager
    +UNUserNotificationCenter notificationCenter
    +Calendar calendar
    +Int maxSnoozesAllowed
    +TimeInterval snoozeDelay
    +checkForMedicationForgotten() 
    -checkForMedicationForgotten(notifications:) 
    -extractNotificationDate(for:now:time:) Date
    -thirtyMinHasPassed(between:and:) 
    -computeNotificationTime(now:nowComponents:notificationComponents:) Date
    -trackMedicationForgottenIfNeeded(from:) 
    +scheduleMedicationReminder() 
    +reminderDoesNotExist(when:) 
    +weekDaysReminderList(_:) 
    +scheduleTherapyAssociatedMedicationReminder(recurrence:atTime:) 
    +deleteRecurrenceAt(_:_:) 
    +deleteNotificationRequest(_:) 
    +deleteAll() 
    +medicationTakenAction() 
    +medicationSnoozeAction() 
    +handleMissedMedication() 
    +handleMedicationViaAlert(snoozeCounter:) 
    +getScheduledMedicationReminders(completion:) 
    +getPendingNotifications(completion:) 
    +cancelPendingMedicationReminders(completion:) 
    +filterRemindersBy(_:) 
    +delete(_:) 
    +getNextTriggerDateFor(_:) Date
    +returnReminderWeekDay(_:) Int
    +createDate(weekday:hour:minute:year:) Date
    +fetch() 
    +showReminderSummary(_:) String
    +userNotificationCenter(_:didReceive:withCompletionHandler:) 
  }
  MedicationManager *-- MedicationManager : composition
  MedicationManager *-- Date : composition
  MedicationManager *-- MedicationManager__Recurrence : composition
  MedicationManager *-- Int : composition
  MedicationManager *-- NotificationManager : composition
  MedicationManager *-- Int : composition
  MedicationManager o-- UNNotificationRequest : aggregation


  class Migrator {
    +String fromVersion
    +String fromRelease
    +String fromBuild
    +String fromAllUp
    +String toVersion
    +String toBuild
    +String toAllUp
    +Error? error
    +MigrationStatus migrationStatus
    +migrate(completion:) 
    -migratePastVideos() 
    -migrateFromAudioVideoLogV1toV2(_:) AudioVideoLogV2
    -migrateAudioVideoLog2ToCoreData(_:) 
  }
  Migrator *-- String : composition
  Migrator *-- String : composition
  Migrator *-- String : composition
  Migrator *-- String : composition
  Migrator *-- String : composition
  Migrator *-- String : composition
  Migrator *-- String : composition
  Migrator *-- Migrator__MigrationStatus : composition


  class MirrorHRMainClass {
    +UnknownTypeSoAddTypeAttributionToVariable communicationErrorSubscriber
    +UnknownTypeSoAddTypeAttributionToVariable eventSubscriber
    -StreamingManager streamingManager
    +SCIXyDataSeries bpmDataSeries
    +TelemetryBpmDataMessage telemetryBpmDataMessage
    +SciChartSurfaceViewRep realTimeChart
    -UUID sessionID
    -TimeInterval runningSince
    -TabViewController tabViewController
    -ProfileGenericSettings profileGenericSettings
    +KISSFlowManager kISSFlowManager
    +Bool isRunning
    +Status status
    -stopMirrorHRFlow(_:) 
    -handleMirrorHRFlowErrors(_:) 
    -bootMirroHRFlow(_:_:) 
    +sendStopFromIphoneToWatch() 
    -sendParentalControlUpdate() 
    -sendStartToWatch() 
    +handleCommunicationError(_:) 
    +handleEvents(event:) 
    +startStopFromIPhone() 
    -stopRealTimeSession() 
    -saveRealTimeSession() 
    -calculateSessionStats(completion:) 
  }
  MirrorHRMainClass *-- MirrorHRMainClass : composition
  MirrorHRMainClass *-- TelemetryBpmDataMessage : composition
  MirrorHRMainClass *-- SciChartSurfaceViewRep : composition
  MirrorHRMainClass *-- TabViewController : composition
  MirrorHRMainClass *-- ProfileGenericSettings : composition
  MirrorHRMainClass *-- KISSFlowManager : composition
  MirrorHRMainClass *-- Status : composition


  class MoreHealthData {
    -Date startDate
    -Date? endDate
    -HealthAuthorizationProtocol healthAuthorizationManager
    -HKHealthStore healthStore
    -[NSSortDescriptor] sortDescriptors
    +readSleep() 
  }
  MoreHealthData *-- Date : composition
  MoreHealthData *-- Date : composition
  MoreHealthData o-- NSSortDescriptor : aggregation


  class MyFile {
    +String userID
    +String filename
    +String localFileName
    +String localFileNameWithDate
    +URL localFullPathWithDate
    +String ext
    +Bool savedLocally
    +String content
    +MirrorHRFileTypes fileType
    +Date dateFile
    +save() 
  }
  MyFile *-- String : composition
  MyFile *-- String : composition
  MyFile *-- String : composition
  MyFile *-- String : composition
  MyFile *-- String : composition
  MyFile *-- String : composition
  MyFile *-- MirrorHRFileTypes : composition
  MyFile *-- Date : composition


  class NotificationManager {
    +RealTimeEventsManager realTimeEventsManager
    +ProfileGenericSettings profileGenericSettings
    +UNUserNotificationCenter notificationCenter
    +UnknownTypeSoAddTypeAttributionToVariable eraseCommandSubscriber
    +UnknownTypeSoAddTypeAttributionToVariable eventSubscriber
    +Bool canNotify
    +TimeInterval lastAlarmNotificationFired
    +TimeInterval lastBatteryNotificationFired
    +TimeInterval lastCriticalErrorNotificationFired
    +UNNotificationTrigger? trigger
    +[UNUserNotificationCenterDelegate] observers
    +fireNotification(_:) 
    +notificationContent(from:) 
    +userNotificationCenter(_:willPresent:withCompletionHandler:) 
    +userNotificationCenter(_:didReceive:withCompletionHandler:) 
    +fireCalendarNotificationRequest(_:_:) 
    +fireRecurringNotificationCheck(_:_:) 
    -extractSuffix(from:) String
    +handleEvents(event:) 
    +fireNotification(event:overrideLastFiredDelay:triggerInterval:category:customMetaData:) 
    +handleMirrorHRNotifications(content:) 
    +testAlarmNotifications(critical:) 
    +addObserver(_:) 
    +removeObserver(_:) 
    +scheduleNewNoDataNotification() 
    +removePendingNoDataCheckNotifications() 
    +eraseAllNotifications() 
    +removePendingRequestWithIdentifier(_:completion:) 
  }
  NotificationManager *-- NotificationManager : composition
  NotificationManager *-- RealTimeEventsManager : composition
  NotificationManager *-- ProfileGenericSettings : composition
  NotificationManager o-- UNUserNotificationCenterDelegate : aggregation


  class OnboardingStateMachine {
    +OnboardingStatus mainAppStatus
    -Bool isOnboarding
    -Bool isShowWhatsNew
    -String lastOnboardedVersion
    +String whatsLastOnboardedVersion
    -refresh() 
    +setOnboarding(to:) 
    +setShowWhatsNew(to:) 
  }
  OnboardingStateMachine *-- OnboardingStateMachine : composition
  OnboardingStateMachine *-- OnboardingStatus : composition
  OnboardingStateMachine *-- String : composition
  OnboardingStateMachine *-- String : composition


  class OnboardingWrapperViewModel {
    +[OnboardingCard] onboardingData
    +[Int] cardsToBeExcludedIfConditionIsFalse
    +Bool conditionOfInclusion
    +String startMsg
    +UIColor tertiaryBackgroundColor
    +ProfileGenericSettings profileGenericSettings
  }
  OnboardingWrapperViewModel *-- String : composition
  OnboardingWrapperViewModel *-- ProfileGenericSettings : composition
  OnboardingWrapperViewModel o-- OnboardingCard : aggregation
  OnboardingWrapperViewModel o-- Int : aggregation
  OnboardingWrapperViewModel o-- PermissionType__PermissionManager : aggregation
  OnboardingWrapperViewModel o-- Int : aggregation
  OnboardingWrapperViewModel o-- OnboardingCard : aggregation
  OnboardingWrapperViewModel o-- OnboardingCard : aggregation


  class ProfileGenericSettings {
    +UnknownTypeSoAddTypeAttributionToVariable resetToDefaultValues
    +Bool premiumVersion
    +MeasurementsUnit measurementsUnit
    +String kidName
    +Double kidWeight
    +CGFloat brightness
    +String kidAge
    +Date kidBirthDate
    +EpilepsyType epilepsyType
    +DeviceModels deviceModel
    +Bool appleWatchEnabled
    +Bool privacyAccepted
    +Bool debugMode
    +Bool collectTelemetry
    +Bool parentalControl
    +Bool notifyWhenRealtimeMonitorEnds
    +Bool chartShowBands
    +Bool chartShowMarkers
    +String emergencyNumber
    +String doctorEmail
    +Bool permissionsNotDone
    +reset() 
    -handleMigrationIfNeeded() 
    +calculateKidAge() 
  }
  ProfileGenericSettings *-- ProfileGenericSettings : composition
  ProfileGenericSettings *-- MeasurementsUnit : composition
  ProfileGenericSettings *-- String : composition
  ProfileGenericSettings *-- String : composition
  ProfileGenericSettings *-- Date : composition
  ProfileGenericSettings *-- EpilepsyType : composition
  ProfileGenericSettings *-- String : composition
  ProfileGenericSettings *-- String : composition


  class QuickLogs {
    +[SymptomLog] logs
    +Date dateLog
    +Int symptomLenght
    +addNew() 
    +refresh() 
  }
  QuickLogs *-- QuickLogs : composition
  QuickLogs *-- Date : composition
  QuickLogs *-- Int : composition
  QuickLogs o-- SymptomLog : aggregation


  class ReadHealthData {
    +Double? minValue
    +Double? maxValue
    +String? minMaxReadyString
    +HealthQuantity healthQuantity
    +UUID id
    +readMinMax(for:) 
    +readMinMax(startDate:endDate:completion:) 
    -returnMinMaxString() 
    -readMinMax(startDate:endDate:) 
    -readAllValues(startDate:endDate:completion:) 
  }
  ReadHealthData *-- String : composition
  ReadHealthData *-- HealthQuantity : composition


  class RealTimeEventsManager {
    +UnknownTypeSoAddTypeAttributionToVariable eventSubscriber
    +Bool alarmIsSilent
    +Bool batteryIsSilent
    +Bool criticalErrorNotificationsAreSilent
    +Bool handleAlarmView
    +Bool showingAlert
    +Alert alert
    +String mainMessage
    +Bool showLowBatterySymbol
    +Bool isShowingMailView
    +String xlsImportExportFullPath
    +Int firingBPM
    -Alarm alarm
    +Alert.Button silentBatteryButton
    +Alert.Button silentCriticalErrorButton
    +Alert.Button shareDataWithDoc
    +Alert.Button doNotShareDataWithDoc
    +Alert.Button continueNotificationsButton
    +handleEvents(event:) 
  }
  RealTimeEventsManager *-- RealTimeEventsManager : composition
  RealTimeEventsManager *-- String : composition
  RealTimeEventsManager *-- String : composition
  RealTimeEventsManager *-- Int : composition
  RealTimeEventsManager *-- Alarm : composition


  class SendEmailView__Coordinator {
    +PresentationMode presentation
    +Result<MFMailComposeResult, Error>? result
    +mailComposeController(_:didFinishWith:error:) 
  }


  class Sentiment {
    +Double score
    +scoreSentiment(input:) 
  }


  class SettingsView__SettingsViewModel {
    +KeyFlowThresholds keyFlowThresholds
    +ProfileGenericSettings profileGenericSettings
    +SoundOptions sounds
    +StreamingManager streamingManager
    +SymptomsManager symptomsManager
    +UserDefaults storage
    +UIApplication application
    +Bool showingAlert
    +testAlarm() 
    +callEmergencyNumber() 
  }
  SettingsView__SettingsViewModel *-- SettingsView__SettingsViewModel : composition
  SettingsView__SettingsViewModel *-- ProfileGenericSettings : composition
  SettingsView__SettingsViewModel *-- SymptomsManager : composition


  class SheetViewController {
    +Bool sheetVisible
    +AnyView sheetContentView
    +String navigationTitle
    +CancelActionCall? cancelAction
    +OkActionCall? okAction
    +OnSheetDismissCall? dismissAction
    +String okActionText
    +String okActionImage
    +String cancelActionText
    +String cancelActionImage
    +Bool showNavTabBarTitle
    +Bool hasCancelButton
    +Bool hasOkButton
    +reset() 
  }
  SheetViewController *-- SheetViewController : composition
  SheetViewController *-- String : composition
  SheetViewController *-- String : composition
  SheetViewController *-- String : composition
  SheetViewController *-- String : composition
  SheetViewController *-- String : composition


  class ShowPickerS {
    +[Bool] show
  }
  ShowPickerS *-- ShowPickerS : composition
  ShowPickerS o-- Bool : aggregation


  class SymptomLog {
    +SymptomsManager symptomsManager
    +UUID id
    +HandledSymptomsEvents symptom
    +Date startDate
    +Date endDate
    +Int16? severity
    +String? notes
    +String? jsonMetaData
    +Double sincePreviousLog
    +String? videoFileName
    +String? videoMetaData
    +String? videoTranscript
    +Data? videoThumbnail
    +Double? videoDuration
    +Double? videoSentiment
    -SymptomsData? symptomData
    +String rawValue
    +SavedStatus savedStatus
    +URL? videoUrl
    +createVideoLogName() String
    +calcVideoDuration() 
    -analizeVideo(completion:) 
    +append(_:) 
    +saveAndAnalyzeVideoLog(_:) 
    -calcSincePreviousLog() 
  }
  SymptomLog *-- SymptomsManager : composition
  SymptomLog *-- HandledSymptomsEvents : composition
  SymptomLog *-- Date : composition
  SymptomLog *-- Date : composition
  SymptomLog *-- String : composition
  SymptomLog *-- String : composition
  SymptomLog *-- String : composition
  SymptomLog *-- String : composition
  SymptomLog *-- String : composition
  SymptomLog *-- SymptomsData : composition
  SymptomLog *-- String : composition
  SymptomLog *-- SymptomLog__SavedStatus : composition


  class SymptomLogDatePicker {
    +Bool showDatePicker
    +Date dateLog
  }
  SymptomLogDatePicker *-- SymptomLogDatePicker : composition
  SymptomLogDatePicker *-- Date : composition


  class SymptomsManager {
    +Bool structureIsMigrated
    +Bool deprecatedNotesMigrated
    +HandledSymptomsEvents chartFilter
    +HandledSymptomsEvents subChartFilter
    +[Date] dateFilters
    +[HandledSymptomsEvents] filterArrayChart
    +[HandledSymptomsEvents] filterArrayTimeLine
    +Int chartPerspective
    +[SymptomsData] filteredChartData
    +NSPredicate? timeLineV10Predicate
    +[SymptomsData] symptomsData
    +[HandledSymptomsEvents] chartFilters
    +UnknownTypeSoAddTypeAttributionToVariable eraseCommandSubscriber
    +PersistenceController.shared.container context
    +NSFetchRequest<NSFetchRequestResult> fetchRequest
    +NSSortDescriptor dataSort
    +NSPredicate? predicate
    +Date noStartDate
    +[HandledSymptomsEvents] seizuresLogOnlySymptomsArray
    +[HandledSymptomsEvents] oldSymptoms
    +[DateComponents] symptomLogsByDateCmptSeizuresForCharts
    +[SymptomsData] seizuresOnlyData
    +SymptomsData? lastSeizure
    +migrateData() 
    +migrateSymptomName(_:) HandledSymptomsEvents
    +migrateDeprecatedDefaultNotes(_:) 
    +migrateSymptomStructure(_:) 
    +importCSV(_:) Int
    +returnStatsByLast12Month() 
    +returnLast12WeeksStatsByWeek() 
    +returnStatsByWeekDay() 
    +seizuresCount() Int
    +seizuresCountInDateRange(lowerDate:upperDate:) Int
    +falseAlarmsCountInDataRange(lowerDate:upperDate:) Int
    +symptomLogByStartDatesSeizuresOnlyForCharts() 
    +sinceLastSeizureString() String
    +distanceBetweenLastAndPrevious() String
    +csvExport(completion:) 
    +xlsSymptomsExport(worksheet:maxRows:anonymized:lastDays:) 
    +clearAllItems() 
    +clearAllItems(completion:) 
    +refresh() 
    +medicationForgottenExists(between:endDate:) 
    +medicationTakenExists(between:endDate:) 
    -logFetchError(error:) 
    +saveSeizure(startTime:endTime:severity:metadata:) 
    +fetch() 
    +appendSymptomLog(_:isBulkInsert:completion:) 
    +appendSymptomLog(_:isBulkInsert:) 
    +saveAndRefresh(_:) 
    +deleteSymptom(_:) 
    +deleteVideoFile(_:) 
    +updateSymptomWith(_:_:) 
    -applyFiltersBySymptomFilter() 
    +refreshCurtesyData() 
    +filterByDataRange(from:to:) 
    +symptomsDataForLastDays(_:) 
    +seizuresForLastDays(_:) 
    +lastSymptoms(_:) 
  }
  SymptomsManager *-- SymptomsManager : composition
  SymptomsManager *-- HandledSymptomsEvents : composition
  SymptomsManager *-- HandledSymptomsEvents : composition
  SymptomsManager *-- Int : composition
  SymptomsManager *-- Date : composition
  SymptomsManager *-- SymptomsData : composition
  SymptomsManager o-- Date : aggregation
  SymptomsManager o-- HandledSymptomsEvents : aggregation
  SymptomsManager o-- HandledSymptomsEvents : aggregation
  SymptomsManager o-- SymptomsData : aggregation
  SymptomsManager o-- SymptomsData : aggregation
  SymptomsManager o-- HandledSymptomsEvents : aggregation
  SymptomsManager o-- HandledSymptomsEvents : aggregation
  SymptomsManager o-- HandledSymptomsEvents : aggregation
  SymptomsManager o-- DateComponents : aggregation
  SymptomsManager o-- SymptomsData : aggregation


  class SymptomsNLP {
    +check(symptoms:in:) 
  }


  class TabViewController {
    +Int tabView
  }
  TabViewController *-- TabViewController : composition
  TabViewController *-- Int : composition


  class TelemetryBpmDataMessage {
    +SessionStats? sessionStats
    +[TelemetryBpmData] dataSeries
    +String? iosDeviceVersion
    +String? watchOSVersion
    +clear() 
    +jsonString() String
  }
  TelemetryBpmDataMessage *-- SessionStats : composition
  TelemetryBpmDataMessage *-- String : composition
  TelemetryBpmDataMessage *-- String : composition
  TelemetryBpmDataMessage o-- TelemetryBpmData : aggregation


  class TherapyManager {
    +[Therapy] therapies
    +[Cocktail] cocktails
    +[Dose] doses
    +[Drug] drugs
    +Bool showYesNoAlert
    +String alertYesNoMsg
    +UnknownTypeSoAddTypeAttributionToVariable eraseCommandSubscriber
    +PersistenceController.shared.container context
    +NSFetchRequest<NSFetchRequestResult> fetchTherapy
    +NSFetchRequest<NSFetchRequestResult> fetchCocktail
    +NSFetchRequest<NSFetchRequestResult> fetchDose
    +NSFetchRequest<NSFetchRequestResult> fetchDrug
    +NSSortDescriptor dataSort
    +NSPredicate? predicate
    +Therapy? currentTherapy
    +fetch() 
    +clearAllItems() 
    -logFetchError(error:) 
    +save() 
    +insertTherapy(name:startDate:endDate:cocktails:saveSymptomLog:) 
    +updateTherapy(therapy:newName:newStartDate:newEndDate:newCocktails:) 
    +insertCocktail(name:doses:reminder:notes:completion:) 
    +updateCocktail(cocktail:newName:doses:reminder:notes:) 
    +deleteTherapy(_:) 
    +deleteCocktail(_:) 
    +insertDrug(name:unit:shape:completion:) 
    +updateDrug(drug:newName:newUnit:newShape:) 
    +deleteDrug(drug:) 
    +insertDose(drug:quantity:shapes:completion:) 
    +deleteDose(dose:) 
    +loadFromJsonAndSave(_:completion:) 
    +generateSample() 
  }
  TherapyManager *-- TherapyManager : composition
  TherapyManager *-- String : composition
  TherapyManager *-- Therapy : composition
  TherapyManager o-- Therapy : aggregation
  TherapyManager o-- Cocktail : aggregation
  TherapyManager o-- Dose : aggregation
  TherapyManager o-- Drug : aggregation


  class UpdatingSymptomSupport {
    +String notes
    +Date startDate
    +HandledSymptomsEvents symptom
    +[KindaOfUpdate] kindaOfUpdates
    +appendKindaOfUpdate(element:) 
  }
  UpdatingSymptomSupport *-- String : composition
  UpdatingSymptomSupport *-- Date : composition
  UpdatingSymptomSupport *-- HandledSymptomsEvents : composition
  UpdatingSymptomSupport o-- KindaOfUpdate : aggregation


  class Validator {
    +UUID uuid
    +HandledSymptomsEvents symptom
    +Bool validated
    +toggle() 
  }
  Validator *-- HandledSymptomsEvents : composition


  class VideoCoordinator {
    +VideoType videoType
    +imagePickerController(_:didFinishPickingMediaWithInfo:) 
  }
  VideoCoordinator *-- VideoType : composition


  class VideoPicker {
    +VideoType videoType
    -UIImagePickerController picker
    -UnknownTypeSoAddTypeAttributionToVariable presentationMode
    +startCapture(completion:) 
    +stopCapture() 
    +makeUIViewController(context:) 
    +updateUIViewController(_:context:) 
    +makeCoordinator() VideoCoordinator
  }
  VideoPicker *-- VideoType : composition


  class XLSImportExport {
    -String? documentPath
    -BRAOfficeDocumentPackage? spreadSheet
    -Array paths
    -String fileName
    -String fullPath
    +[Any] filesToShare
    +UIViewController sharingView
    +deinit() 
    -saveXls() 
    +getFullPath() String
    -exportPersonalDataXLS(worksheetNumber:) 
    -writeSymptomsXLS(lastDays:worksheetNumber:anonymized:) 
    -writeSeizuresXLS(lastDays:worksheetNumber:anonymized:) 
    +share() 
    +sendByEmail(toLine:subject:) 
    -writeSeizuresBpmXls(lastDays:worksheetNumber:completion:) 
    -writeHRVXls(lastDays:worksheetNumber:completion:) 
    +shareXlsDataForLast(days:completion:) 
    +shareFullDataAsXls(anonymized:completion:) 
    +SmartShareXLS(anonymized:completion:) 
  }
  XLSImportExport *-- String : composition
  XLSImportExport *-- String : composition
  XLSImportExport *-- String : composition
  XLSImportExport *-- Int : composition
  XLSImportExport o-- Any : aggregation

```
