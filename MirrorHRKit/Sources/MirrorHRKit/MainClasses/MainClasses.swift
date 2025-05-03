//
//  MainClasses.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 28/09/2020.
//

import Combine
import Foundation
import SharedPkg
import SciChart
import SwiftUI
import MirrorHRTelemetryPackage

// MARK: MirrorHRMainApp - main class

/// Represents the current status of the MirrorHR monitoring system
///
/// The Status enum tracks the monitoring state through its entire lifecycle:
/// - `stopped`: Monitoring is inactive
/// - `running`: Active monitoring is in progress
/// - `booting`: System is initializing monitoring
/// - `delayedStop`: Monitoring is scheduled to stop after a time interval
/// - `error`: An error has occurred in the monitoring system
///
/// Each status (except error) includes the source device that triggered the status change.
public enum Status: Equatable {
    case stopped(source: DeviceModels)
    case running(source: DeviceModels)
    case booting(source: DeviceModels)
    case delayedStop(source: DeviceModels, forHowLong: TimeInterval)
    case error(_ error: WatchCommunicationErrors)
}

/// Core coordinator class for the MirrorHR monitoring system
///
/// `MirrorHRMainClass` is the central manager responsible for:
/// - Coordinating heart rate monitoring sessions
/// - Managing communication between iPhone and Apple Watch
/// - Processing heart rate data in real time
/// - Initiating alerts and notifications for abnormal patterns
/// - Managing the monitoring state machine
/// - Collecting and storing session statistics
///
/// This class follows the singleton pattern for global accessibility.
/// It manages the lifecycle of monitoring sessions and handles device
/// communication errors and events through the observer pattern.
///
/// - Important: All UI updates from this class must occur on the main thread
/// - Warning: This class must maintain performance for real-time monitoring
public final class MirrorHRMainClass: ObservableObject, CommunicationErrorSubscriber, @preconcurrency EventsSubscriber {
    /// Shared singleton instance
    public static let shared = MirrorHRMainClass()
    
    /// Subscription for communication error events
    public var communicationErrorSubscriber = AnyCancellable {}
    
    /// Subscription for general application events
    public var eventSubscriber = AnyCancellable {}
    
    /// Manager for data source selection and configuration
    private let dataSourceManager: DataSourceManager = .shared
    
    /// Data series for real-time heart rate visualization
    /// This is continuously updated during an active monitoring session
    let bpmDataSeries = SCIXyDataSeries(xType: .date, yType: .double)
    
    /// Container for telemetry heart rate data to be sent to cloud services
    var telemetryBpmDataMessage: TelemetryBpmDataMessage = TelemetryBpmDataMessage()
    
    /// Chart view representation for real-time visualization
    var realTimeChart: SciChartSurfaceViewRep
    
    /// Unique identifier for the current monitoring session
    private var sessionID = UUID()
    
    /// Timestamp when the current session started
    private var runningSince: TimeInterval = 0.0
    
    /// View controller for tab navigation
    private var tabViewController = TabViewController.shared
    
    /// User settings and preferences
    @Published var settings: ProfileGenericSettings = .shared
    
    /// Heart rate analysis manager
    @Published var kISSFlowManager = KISSFlowManager.shared
    
    /// Indicates whether monitoring is currently active
    /// When set to false, also silences any active alarms
    @Published public var isRunning: Bool = false {
        didSet { if isRunning == false { RealTimeEventsManager.shared.alarmIsSilent = true }}
    }
    
    /// Current status of the monitoring system
    ///
    /// This published property manages the state machine for the monitoring workflow.
    /// When the status changes, appropriate actions are triggered based on the new state:
    /// - `.stopped`: Stops monitoring and cleans up resources
    /// - `.booting`: Initializes monitoring and prepares data structures
    /// - `.running`: Active monitoring state (transition managed by boot sequence)
    /// - `.error`: Handles error conditions and notifies user
    /// - `.delayedStop`: Scheduled stop (primarily used by watch)
    ///
    /// - Important: All state transitions are dispatched to the main thread
    /// - Note: Status changes trigger telemetry events for monitoring usage patterns
    @Published public var status: Status = .stopped(source: .iPhone) {
        didSet {
            // PERFORMANCE CONSIDERATION:
            // This nested dispatch could be eliminated by ensuring
            // all status changes already happen on the main thread.
            // Would reduce thread hops and improve responsiveness.
            DispatchQueue.main.async { [self] in
                if oldValue != status {
                    switch status {
                    case let .stopped(source: source):
                        stopMirrorHRFlow(source)
                    case .error(let error):
                        switch oldValue {
                        case .booting:
                            stopRealTimeSession()
                        case .running:
                            stopRealTimeSession()
                            // IMPORTANT: this is important so that in case of error and the session is running, it alerts the user
                            NotificationManager.shared.fireNotification(event: .criticalError(errorMessage: error.localizedDescription), overrideLastFiredDelay: true)
                            SymptomsManager.shared.fireTelemetryControlSymptoms(SymptomLog(.error, notes: error.localizedDescription))
                        case .error, .delayedStop, .stopped:
                            break
                        }
                        mainDebugger.append("MirrorHRMainClass status is .error because of: \(error.debugDescription)", .error, sourceModule: "MirrorHRMainClass status")
                        
                    case let .booting(source: source):
                        bootMirroHRFlow(source)
                        sendTelemetryIfItMakesSense()
                    case .running:
                        // THREAD SAFETY CONSIDERATION:
                        // Consider adding guards to ensure we can't transition into 
                        // running state except from booting to prevent state corruption
                        break
                        // no other action as it s all handled in .booting
                    case .delayedStop:
                        // DATA INTEGRITY CONSIDERATION:
                        // Consider adding state validation to ensure delayed stop
                        // only comes from valid sources and states
                        // no action as watch can not send delayed stop to the iphone app
                        break
                    }
                }
            }
        }
    }
    
    fileprivate func stopMirrorHRFlow(_ source: DeviceModels) {
        sessionID = UUID()
        status = .stopped(source: source)
        stopRealTimeSession()
        switch source {
        case .appleWatch:
            dispatchMainEvent(.stopReceivedFromWatch, "MirrorHRMainClass from source AppleWatch")
        case .iPhone:
            sendStopFromIphoneToWatch()
            dispatchMainEvent(.stopFromIphone, "MirrorHRMainClass from source iPhone")
        case .localStreaming:
            dispatchMainEvent(.stopFromIphone, "MirrorHRMainClass from source Local Streaming")
        case .remoteStreaming:
            dispatchMainEvent(.stopFromRemoteStreaming, "MirrorHRMainClass from source Remote Streaming Child")
        }
    }
    
    fileprivate func bootMirroHRFlow(_ source: DeviceModels) {
        askHealthAuthorization(healthAuthorizationManager: HealthAuthorizationManager())
        isRunning = true
        // maybe the watch restarted or recovering from an error so saving session that was running and then booting the realtime session as usual
        if dataSourceManager.shouldCleanSession(runningSince: runningSince) {
           cleanSession()
        }
        kISSFlowManager.start(sessionID: sessionID, dataSource: dataSourceManager.dataSource)
        runningSince = Date().timeIntervalSince1970
        dispatchMainEvent(.sessionBoot, "bootMirrorHRFlow")
        switch source {
        case .appleWatch:
            sendStartToWatch()
            sendParentalControlUpdate()
        case .localStreaming, .remoteStreaming:
            checkBootingErrors(source: source)
        case .iPhone:
            sendStartToWatch()
            sendParentalControlUpdate()
            checkBootingErrors(source: source)
        }
    }
    
    fileprivate func cleanSession() {
        saveRealTimeSession()
        bpmDataSeries.clear()
        telemetryBpmDataMessage.clear()
        realTimeChart.sciChartSurface.zoomExtents()
        sessionID = UUID()
    }
    
    fileprivate func sendTelemetryIfItMakesSense() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            if dataSourceManager.dataSource.shouldStreamLocallyOrViaInternet, isRunning {
                let thisEvent: HandledSymptomsEvents = .realTimeSessionStarted
                let symptomsManager: SymptomsManager = .shared
                CareGiversManager.shared.sendRemotCommandToMyCareGivers(command: .patientStartedRealTimeSession)
                symptomsManager.fireTelemetryControlSymptoms(SymptomLog(thisEvent, notes: thisEvent.localizedString()))
            }
        }
    }
    // IMPORTANT: it checks if boots or if there are errors
    func checkBootingErrors(source: DeviceModels) {
        // let's have a maximum time of 45 secs for bootstrap, or there is a problem with the watch or the remote streaming
        _ = Timer.scheduledTimer(withTimeInterval: maxBootingAllowedTime, repeats: false) { [self] timer in
            // if after maxBootingAllowedTime seconds the status is still in booting
            // then there is a problem, probably with the workout or the streaming.
            // NB: different watch versions have different time needed to boot the workout
            DispatchQueue.main.async { [self] in
                if case .booting = status {
                    switch source {
                    case .iPhone, .appleWatch:
                        dispatchEventCommunicationError(.cantStartTheSession, "MirrorHRMain Class bootMirrorHRFlow")
                        status = .error(.cantStartTheSession)
                    case .remoteStreaming, .localStreaming:
                        status = .stopped(source: .remoteStreaming)
                        dataSourceManager.changeRemoteserverStatus(to: .unknown)
                    }
                } else {
                    timer.invalidate()
                }
            }
        }
    }
    
    func sendStopFromIphoneToWatch() {
        CommunicationManagerIoS.shared.sendCommand(.delayedStop(
            source: .iPhone,
            destination: .appleWatch,
            timestamp: Date().timeIntervalSince1970,
            forHowLong: defaultDelayedStopWatch
        ))
    }
    
    private func sendParentalControlUpdate() {
        CommunicationManagerIoS.shared.sendCommand(.parentalControl(parentalControlValue: settings.parentalControl))
    }
    
    private func sendStartToWatch() {
        let communicationManagerIoS: CommunicationManagerIoS = .shared
        let deviceName = communicationManagerIoS.deviceInfo.deviceName
        let deviceVersion = communicationManagerIoS.deviceInfo.deviceVersion
        communicationManagerIoS.sendCommand(.handShake(deviceName: deviceName, deviceVersion: deviceVersion))
        communicationManagerIoS.sendCommand(.start(source: .iPhone, destination: .appleWatch, deviceName: deviceName, deviceVersion: deviceVersion ,timestamp: Date().timeIntervalSince1970))
    }
    
    public func handleWatchCommunicationError(_ error: WatchCommunicationErrors) {
        guard !dataSourceManager.dataSource.isOkToHandleWatchCommunicationErrors else {
            // if is streaming client or no watch it's ok if it can't connect with the watch
            return
        }
        
        switch status {
        case .running, .booting:
            DispatchQueue.main.async {
                self.status = .error(error)
            }
        case .stopped, .delayedStop, .error:
            break
        }
        
    }
    
    @MainActor public func handleEvents(event: Events) {
        switch event {
        case .alarm, .lowBatteryWatch, .handleSeizure, .handleFalseAlarm, .noLocalData, .sessionBoot, .noStreamingData:
            tabViewController.tabView = Tab.realtimeMonitor.rawValue
        case .criticalError(let errorMsg):
            tabViewController.tabView = Tab.realtimeMonitor.rawValue
            status = .error(.soSorryError(errorMessage: errorMsg))
        case .HealthAuthorizationError(let errorMsg):
            tabViewController.tabView = Tab.realtimeMonitor.rawValue
            status = .error(.healthAuthorization(errorMessage: errorMsg))
        case .watchNotReachable:
            tabViewController.tabView = Tab.realtimeMonitor.rawValue
            status = .error(.watchNotReachable)
        case .cantFireNotification(let errorMsg):
            tabViewController.tabView = Tab.realtimeMonitor.rawValue
            status = .error(.soSorryError(errorMessage: errorMsg))
        case .medicationAlert:
            tabViewController.tabView = Tab.diary.rawValue
        case .activePatientChanged:
            break
        case .stopFromIphone:
            guard case .stopped = self.status else {
                self.status = .stopped(source: .iPhone)
                return
            }
            // If the status is already stopped, no action needed
        case .stopFromRemoteStreaming:
            self.status = .stopped(source: .remoteStreaming)
        case .manualAlarm,
                .warning,
                .lowBatteryIphone,
                .unclassifiedEvent,
                .stopReceivedFromWatch,
                .testSound,
                .lastBPM,
                .termination,
                .streamingUnderstandAlert,
                .medicationSnooze:
            break
        }
    }
    
    func startStopFrom(source: DeviceModels) {
        if isRunning {
            status = .stopped(source: source)
        } else {
            status = .booting(source: source)
        }
    }
    
    private init() {
        realTimeChart = SciChartSurfaceViewRep(chartSurface: SCIChartSurface(), bpmDataSeries: bpmDataSeries)
        bpmDataSeries.clear()
        telemetryBpmDataMessage.clear()
        bpmDataSeries.append(x: Date(), y: 0)
        bpmDataSeries.append(x: Date(), y: 200)
        realTimeChart.sciChartSurface.zoomExtents()
        bpmDataSeries.clear()
        NotificationManager.shared.removePendingNoDataCheckNotifications()
        communicationErrorSubscriber = communicationErrorPublisher
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: { error in
                self.handleWatchCommunicationError(error)
            })
        eventSubscriber = mainEventsPublisher
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: { [weak self] event in
                DispatchQueue.main.async {
                    self?.handleEvents(event: event)
                }
            })
    }
}

extension MirrorHRMainClass {
    private func stopRealTimeSession() {
        // let's stop the flowmanager etc.
        isRunning = false
        kISSFlowManager.stop()
        saveRealTimeSession()
        mainDebugger.append("session stopped at \(Date().toStdString())", .event)
    }
    
    private func saveRealTimeSession() {
        // if there are no data (es. just start/stop session) let's NOT save it at all
        if bpmDataSeries.count <= 1 || !dataSourceManager.dataSource.shouldSaveRealtimeSession{
            mainDebugger.append("no data in realtime Session to save or it's only streaming, so not saving the real time session", .event)
            return
        }
        
        CareGiversManager.shared.sendRemotCommandToMyCareGivers(command: .patientStoppedRealTimeSession)

        calculateSessionStats { sessionStats in
            SymptomsManager.shared.appendSymptomLog(
                .init(HandledSymptomsEvents.realTimeSessionEnded,
                      startDate: Date.fromStdDateString(sessionStats.startDate),
                      endDate: Date.fromStdDateString(sessionStats.endDate),
                      jsonMetaData: sessionStats.jsonString(),
                      notes: sessionStats.notesString()
                     )
            )
            DispatchQueue.main.async {
                let showSheet: SheetViewController = .shared
                showSheet.reset()
                showSheet.okActionText = "closeButtonString".local()
                showSheet.sheetContentView = AnyView(SessionStatsView(sessionStats: sessionStats, chartOnly: false))
                showSheet.presentationDetents = [.height(500)]
                showSheet.sheetVisible = true
            }
            
            mainDebugger.append("saved realtime session", .greenFlag)
            
            if Telemetries.realTimeTelemetrySession(jsonString: "").isOn {
                // sending telemetry bpms (if consent)
                self.telemetryBpmDataMessage.sessionStats = sessionStats
                
                let jsonString = self.telemetryBpmDataMessage.jsonString()
                guard jsonString != "" else {
                    mainDebugger.append("TelemetryBpmDataMessage encoding in json returned an empty string", .error, sourceModule: "MirrorHRMainClass saveRealtimeSession")
                    return
                }
                
                mainDebugger.append("Sending realtime session bpms as json to the cloudAPI")
                dispatchTelemetryEvent(event: .realTimeTelemetrySession(jsonString: jsonString))
            }
        }
    }
    
    private func calculateSessionStats(completion: @escaping (_ sessionStats: SessionStats) -> Void) {
        let bpms: [Int] = bpmDataSeries.yValues.toArray()
            .compactMap { yValue in
                let yValueDouble = yValue.toDouble()
                return yValueDouble != 0 ? Int(yValue.toDouble()) : 1
            }
        
        let startDate: Date = Date(timeIntervalSince1970: runningSince)
        let endDate: Date = Date()
        
        let allHealthQuantitiesReader = AllHealthQuantitiesReader()
        allHealthQuantitiesReader.readAllHealthQuantitiesMinMax(startDate: startDate, endDate: endDate) { healthQuantities  in
            let sessionStats = SessionStats(startDate: startDate, endDate: endDate, bpms: bpms, healthQuantities: healthQuantities)
            completion(sessionStats)
        }
    }
}

// MARK: - Insight Class

final class InsightsClass: ObservableObject {
    static var shared = InsightsClass()
    private var healthKitTools = HealthKitTools.shared
    
    let bpmInsightsDataSeries = SCIXyDataSeries(xType: .date, yType: .double)
    var insightsChartSurfaceView: SciChartSurfaceViewRep
    var startDate = Date().daysAgo(number: 1) {
        didSet {
            healthKitTools.readhBPMfromHealthKitOnDateAndFillChart(
                startDateQuery: startDate,
                endDateQuery: endDate,
                destinationDataSeries: bpmInsightsDataSeries,
                chartSurface: insightsChartSurfaceView.sciChartSurface
            )
        }
    }
    
    var endDate = Date() {
        didSet {
            let deltaSinceLastQuery = endDate.timeIntervalSince(oldValue)
            // it runs a new query only if at least HealthQueryDelayInterval
            // has been passed, to avoid overflow of queries
            if deltaSinceLastQuery > healthQueryDelayInterval {
                healthKitTools.readhBPMfromHealthKitOnDateAndFillChart(
                    startDateQuery: startDate,
                    endDateQuery: endDate,
                    destinationDataSeries: bpmInsightsDataSeries,
                    chartSurface: insightsChartSurfaceView.sciChartSurface
                )
            }
        }
    }
    
    @Published var preselectedRanges: Int = 1 {
        didSet {
            switch preselectedRanges {
            case 1:
                startDate = Date().daysAgo(number: 1)
            case 2:
                startDate = Date().daysAgo(number: 3)
            case 3:
                startDate = Date().daysAgo(number: 7)
            case 4:
                startDate = Date().daysAgo(number: 30)
            default:
                startDate = Date().daysAgo(number: 1)
            }
        }
    }
    
    func initializeInsightsView() {
        healthKitTools.readhBPMfromHealthKitOnDateAndFillChart(startDateQuery: startDate,
                                                               endDateQuery: endDate,
                                                               destinationDataSeries: bpmInsightsDataSeries,
                                                               chartSurface: insightsChartSurfaceView.sciChartSurface)
    }
    
    func initializeInsightsView(startDate: Date, endDate: Date) {
        healthKitTools.readhBPMfromHealthKitOnDateAndFillChart(
            startDateQuery: startDate, endDateQuery: endDate,
            destinationDataSeries: bpmInsightsDataSeries,
            chartSurface: insightsChartSurfaceView.sciChartSurface
        )
    }
    
    init() {
        askHealthAuthorization(healthAuthorizationManager: HealthAuthorizationManager())
        bpmInsightsDataSeries.acceptsUnsortedData = true
        insightsChartSurfaceView = SciChartSurfaceViewRep(chartSurface: SCIChartSurface(), bpmDataSeries: bpmInsightsDataSeries)
    }
    
    func showFilteredInsightsClass(dateHeader: String) -> some View {
        let date = Date.fromTimeLineDateHeader2Date(dateHeader: dateHeader)
        initializeInsightsView(
            startDate: date.startOfDay,
            endDate: date.endOfDay
        )
        
        return insightsChartSurfaceView
            .frame(height: 150)
            .cornerRadius(2)
            .overlay(QueryBPMInProgressView())
    }
    
    func showBPMSession(fromDate: Date, toDate: Date) -> some View {
        initializeInsightsView(
            startDate: fromDate,
            endDate: toDate
        )
        return insightsChartSurfaceView
            .frame(height: 150)
            .cornerRadius(2)
            .overlay(QueryBPMInProgressView())
    }
    
    func showFullDayBPM(fromDate: Date, toDate: Date) -> some View {
        initializeInsightsView(
            startDate: fromDate,
            endDate: toDate
        )
        return insightsChartSurfaceView
            .supportedOrientation(.allButUpsideDown)
            .cornerRadius(2)
            .overlay(QueryBPMInProgressView())
    }
}

// MARK: - Device Orientation

public final class DeviceOrientation: ObservableObject {
    public static let shared = DeviceOrientation()
    @Published public var orientation: Orientation = .portrait
    private init() {
        // singleton
    }
    
}

struct SessionStatsView: View {
    var sessionStats: SessionStats
    let chartOnly: Bool
    
    var body: some View {
        VStack {
            if #available(iOS 17.0, *) {
                SessionStatsCharts(sessionStats: sessionStats)
            }
            
            if !chartOnly {
                Text(sessionStats.notesString())
                    .multilineTextAlignment(.leading)
            }
            
        }
    }
}
