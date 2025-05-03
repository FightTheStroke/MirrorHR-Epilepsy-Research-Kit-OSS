//
//  DataSourceManager.swift
//
//  Created by Roberto D'Angelo on 12/05/24.
//

import Foundation
import SwiftUI
import MirrorHRTelemetryPackage
import Combine
import SharedPkg
import RoberdanToolBox

fileprivate let appStorageKey: String = "selectedDataSource"

/// A singleton class that manages the data source settings and handles changes to the data source.
///
/// The `DataSourceManager` class is responsible for:
/// - Managing data source settings and configurations
/// - Handling changes between different data sources (diary, Apple Watch, streaming)
/// - Managing remote server status and streaming controls
/// - Coordinating with caregivers for remote monitoring
/// - Handling session cleanup and timeouts
///
/// The class implements `ObservableObject` for SwiftUI integration and conforms to `DataSourceChangeSubscriber`
/// and `EventsSubscriber` for handling data source changes and system events.
public final class DataSourceManager: ObservableObject, DataSourceChangeSubscriber, EventsSubscriber {
    /// Shared instance of the DataSourceManager
    public static let shared = DataSourceManager()
    
    /// The current status of the remote server
    /// - running: Server is active with specified duration
    /// - stopped: Server is inactive
    /// - unknown: Server status is not determined
    /// - ready: Server is ready to accept connections
    public enum RemoteServerStatus: Equatable {
        case running(forMins: Int)
        case stopped
        case unknown
        case ready
    }
    
    /// The settings manager for profile configuration
    private let settings: ProfileGenericSettings
    
    /// The manager for caregiver-related operations
    private let careGiversManager: CareGiversManager
    
    /// Subscriber for data source changes
    public var dataSourceChangeSubscriber: AnyCancellable = AnyCancellable {}
    
    /// Subscriber for system events
    public var eventSubscriber: AnyCancellable = AnyCancellable{}
    
    /// Timer for managing remote data fetching timeouts
    private var timer: Timer?
    
    /// Flag to force session cleanup
    private var forceCleanSession: Bool = false
    
    /// The current data source configuration
    @EnumAppStorage(appStorageKey) public var dataSource: DataSource = .diaryOnly
    
    /// Raw value storage for the selected data source
    @AppStorage(appStorageKey) private var selectedDataSourceRawValue: String = DataSource.diaryOnly.rawValue
    
    /// Current status of the remote server
    @Published var remoteServerStatus: RemoteServerStatus = .stopped
    
    /// Toggle for remote streaming control
    @Published var remoteStreamingStartStopToggle: Bool = false {
        didSet {
            // Handles BPM streaming limits and controls
            if remoteStreamingStartStopToggle {
                switch remoteServerStatus {
                case .running(let forMins):
                    fetchRemoteData(forMins: forMins)
                case .stopped, .unknown:
                    stopFetchingRemoteData()
                case .ready:
                    fetchRemoteData(forMins: 30)
                }
            } else {
                stopFetchingRemoteData()
            }
        }
    }
    
    /// Initializes the `DataSourceManager` with default settings.
    ///
    /// - Parameters:
    ///   - settings: The profile settings. Default is `ProfileGenericSettings.shared`.
    ///   - careGiversManager: The caregivers manager. Default is `CareGiversManager.shared`.
    private init(settings: ProfileGenericSettings = ProfileGenericSettings.shared,
                 careGiversManager: CareGiversManager = .shared) {
        self.settings = settings
        self.careGiversManager = careGiversManager
        self.remoteServerStatus = .unknown
        CareGiversManager.shared.sendRemoteCommandToActivePatient(command: .careGiverCheckingRealTimeStatus)
        self.dataSourceChangeSubscriber = dataSourcesChangesPublisher
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: { [weak self] newDataSource in
                self?.handleDataSourceChanges(newDataSource)
            })
        self.eventSubscriber = mainEventsPublisher
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: { [weak self] event in
                self?.handleEvents(event: event)
            })
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        selectedDataSourceRawValue = try container.decode(String.self, forKey: .selectedDataSourceRawValue)
        dataSource = DataSource(rawValue: selectedDataSourceRawValue) ?? .diaryOnly
    }
    
    /// Handles changes to the data source.
    ///
    /// This function updates the application state based on the new data source. It performs onboarding if needed
    /// and configures the application settings according to the new data source.
    ///
    /// - Parameter dataSource: The new data source.
    public func handleDataSourceChanges(_ dataSource: MirrorHRTelemetryPackage.DataSource) {
        
        if self.dataSource == dataSource {
            return // No changes, return immediately
        }
        DispatchQueue.main.async { [self] in
            remoteStreamingStartStopToggle = false
            mainDebugger.append("Changing the Data Source to \(dataSource.rawValue)")
            performOnboardingIfNeeded(oldDataSource: self.dataSource, newDataSource: dataSource)
            NotificationManager.shared.removePendingNoDataCheckNotifications()
            
            switch dataSource {
            case .diaryOnly:
                settings.appleWatchEnabled = false
                if self.dataSource.isClientOnly {
                    dispatchMainEvent(.stopFromRemoteStreaming, "Data Source changed") // Stop the session as source is changing
                } else {
                    dispatchMainEvent(.stopFromIphone, "Data Source changed and is not streaming client")
                }
                
            case .appleWatchPairedOnly:
                settings.appleWatchEnabled = true
                
            case .appleWatchAndInternetKeyEventsStreamingAsServer:
                settings.appleWatchEnabled = true
                
            case .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
                settings.appleWatchEnabled = true
                
            case .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
                settings.appleWatchEnabled = false
            }
            
            self.dataSource = dataSource
            
//          ToastManager.shared.showToast(message: "DataSource is now \(dataSource.title)", image: "info.bubble")
        }
    }
    
    public func handleEvents(event: SharedPkg.Events) {
        switch event {
        case .alarm, .manualAlarm, .warning, .noLocalData, .noStreamingData, .lastBPM, .lowBatteryWatch, .lowBatteryIphone, .unclassifiedEvent, .handleSeizure, .handleFalseAlarm, .stopFromIphone, .stopReceivedFromWatch, .criticalError, .testSound, .medicationAlert, .medicationSnooze, .streamingUnderstandAlert, .cantFireNotification, .HealthAuthorizationError, .watchNotReachable, .sessionBoot:
            break
            
        case .activePatientChanged:
            changeRemoteserverStatus(to: .unknown)
            forceCleanSession = true
        case .stopFromRemoteStreaming, .termination:
            break
        }
    }
    
    /**
     Determines whether a session should be cleaned based on the provided time interval and data source.
     
     - Parameters:
     - runningSince: The time interval (in seconds) since the session started.
     
     - Returns: A Boolean value indicating whether the session should be cleaned.
     
     This function evaluates if a session should be cleaned based on several conditions:
     - If `forceCleanSession` is set to `true`, it will reset `forceCleanSession` to `false` and return `true`.
     - Depending on the `dataSource`, it checks the elapsed time since the session started (`runningSince`):
     - For `.appleWatchPairedOnly`, `.appleWatchAndInternetKeyEventsStreamingAsServer`, and `.appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer` data sources, the session will be cleaned if it has been running for an hour or more.
     - For `.internetStreamingAsClientForKeyEventsOnly` and `.internetStreamingAsClientForKeyEventsAndBPMs` data sources, the session will be cleaned if it has been running for four hours or more.
     - For `.diaryOnly` data source, the session will never be cleaned.
     
     - Note: The time intervals are compared against the current time in seconds since 1970 (epoch time).
     
     - SeeAlso: `Date.timeIntervalSince1970`
     
     - Example:
     ```
     let shouldClean = shouldCleanSession(runningSince: someTimeInterval)
     if shouldClean {
     // Clean the session
     }
     ```
     */
    public func shouldCleanSession(runningSince: TimeInterval) -> Bool {
        if forceCleanSession {
            forceCleanSession = false
            return true
        }
        
        let currentTime = Date().timeIntervalSince1970
        let elapsedTime = currentTime - runningSince
        
        switch dataSource {
        case .appleWatchPairedOnly,
                .appleWatchAndInternetKeyEventsStreamingAsServer,
                .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            if elapsedTime >= 60 * 60 {
                return true
            }
        case .internetStreamingAsClientForKeyEventsOnly,
                .internetStreamingAsClientForKeyEventsAndBPMs:
            if elapsedTime >= 60 * 60 * 4 { // 4 hours should be reasonable
                return true
            }
        case .diaryOnly:
            return false
        }
        return false
    }
}

extension DataSourceManager {
    private func fetchRemoteData(forMins: Int) {
// TODO: IMPORTANT: Remove time limits for streaming in TestFlight
        if TelemetryHeader.shared.environment == "IS_TESTFLIGHT" {
            return // in testflight non metto limiti di tempo
        }
        
        // Invalidate any existing timer
        timer?.invalidate()
        
        // Schedule a new timer
        let interval: TimeInterval = TimeInterval(forMins * 60)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.remoteStreamingStartStopToggle = false
            dispatchMainEvent(.stopFromRemoteStreaming, "BPM Streaming Limit reached")
        }
    }
    
    private func stopFetchingRemoteData() {
        // Invalidate and clear the timer
        timer?.invalidate()
        timer = nil
    }
    
    /// Returns a warning view with a message and an optional image.
    ///
    /// - Parameters:
    ///   - warningMessage: The warning message to be displayed.
    ///   - showImage: A boolean indicating whether to show an image.
    /// - Returns: A view displaying the warning message and an optional image.
    func warningView(warningMessage: String, showImage: Bool) -> some View {
        HStack {
            if showImage {
                Image(systemName: "exclamationmark.triangle.fill")
            }
            Text(warningMessage)
        }
        .foregroundColor(.red)
        .padding(.horizontal)
    }
    
    /// Checks if the current data source has errors.
    ///
    /// - Returns: A boolean indicating whether the current data source has errors.
    public var dataSourceHasErrors: Bool {
        return dataSource.thereIsAnError != nil
    }
    
    /**
     Updates the remote server status based on the provided symptom event from a specific patient.
     
     - Parameters:
     - kidID: The ID of the patient whose event is being handled.
     - symptomEvent: The `HandledSymptomsEvents` that triggered this status update.
     
     This function updates the server status only if the following conditions are met:
     - The data source is client-only (`dataSource.isClientOnly` is `true`).
     - The provided `kidID` matches the active patient's ID.
     - The symptom event is either a severe key event (`HandledSymptomsEvents.severeKeyEvents` contains `symptomEvent`).
     
     The server status is updated as follows:
     - If `symptomEvent` is one of the severe key events, the new status is set to `.running`.
     
     If these conditions are not met, the function returns without making any changes.
     
     - Note: This function is intended for internal use only.
     
     - SeeAlso: `changeRemoteserverStatus(to:)`
     */
    internal func handleKeyRemoteSymptomsAndEvents(fromPatient kidID: String?, event symptomEvent: HandledSymptomsEvents) {
        guard dataSource.isClientOnly, let kidID: String = kidID, let uuid:UUID = UUID(uuidString: kidID), HandledSymptomsEvents.severeKeyEvents.contains(symptomEvent) else {
            return // nothing to handle here
        }
        
        let activePatient = careGiversManager.getActivePatient()?.id.uuidString
        if kidID != activePatient {
            careGiversManager.forcePatientActivation(id: uuid)
        }
        let newServerStatus: RemoteServerStatus = .running(forMins: 10)
        ToastManager.shared.showToast(message: "SwitchedActivePatientBecauseSeverEvent".local(), image: "person.badge.shield.checkmark.fill")
        changeRemoteserverStatus(to: newServerStatus)
        CareGiversManager.shared.sendRemoteCommandToActivePatient(command: .startSteamingToCareGiver)
        dispatchMainEvent(.sessionBoot, "Key remote event - running forMins")
        return
    }
    
    /**
     Changes the remote server status to the provided new value.
     
     - Parameters:
     - newValue: The new `RemoteServerStatus` to set.
     
     This function updates the remote server status and modifies the data source based on the new status.
     It performs the following actions based on the value of `newValue`:
     - If the new status is `.running`, it sets the data source to `.internetStreamingAsClientForKeyEventsAndBPMs`.
     - If the new status is `.stopped`, it sets the data source to `.internetStreamingAsClientForKeyEventsOnly` and dispatches a stop event.
     - If the new status is `.unknown`, it dispatches a stop event indicating the server status is unknown.
     
     The function only proceeds if the data source is client-only (`dataSource.isClientOnly` is `true`).
     
     After updating the data source and dispatching any necessary events, the function sets the `remoteServerStatus` and resets the `remoteStreamingStartStopToggle` to `false`.
     
     - Note: This function is intended for public use.
     
     - SeeAlso: `updateServerStatus(from:)`
     */
    public  func changeRemoteserverStatus(to newValue: RemoteServerStatus) {
        if !dataSource.isClientOnly { return }
        self.remoteServerStatus = newValue
        
        switch newValue {
        case .stopped:
            dataSource = .internetStreamingAsClientForKeyEventsOnly
            remoteStreamingStartStopToggle = false
            dispatchMainEvent(.stopFromRemoteStreaming, "Server Status is stopped")
        case .unknown:
            remoteStreamingStartStopToggle = false
            dispatchMainEvent(.stopFromRemoteStreaming, "Server Status is unknown")
        case .running:
            dataSource = .internetStreamingAsClientForKeyEventsAndBPMs
            remoteStreamingStartStopToggle = true
        case .ready:
            remoteStreamingStartStopToggle = false
            dataSource = .internetStreamingAsClientForKeyEventsAndBPMs
        }
    }
    
    /// Performs onboarding if needed based on the old and new data sources.
    ///
    /// - Parameters:
    ///   - oldDataSource: The previous data source.
    ///   - newDataSource: The new data source.
    private func performOnboardingIfNeeded(oldDataSource: DataSource, newDataSource: DataSource) {
        // TODO: Redesign the onboarding to be more specific and streamlined. See ROADMAP.md for details.
        return
        // TODO: Implement custom onboarding based on user needs (e.g., remote monitoring doesn't require BPM parameters). See ROADMAP.md.
        //        if oldDataSource.requiresOnboarding != newDataSource.requiresOnboarding, !OnboardingStateMachine.shared.isShowingOnboarding {
        //            OnboardingStateMachine.shared.setOnboarding(to: true)
        //        }
    }
}

extension DataSource {
    /// Checks if there is an error with the current data source.
    ///
    /// - Returns: An optional error message if there is an error, otherwise `nil`.
    public var thereIsAnError: String? {
        var errorMessage: String? = nil
        let isAppleWatchRequiredAndPaired: Bool = self.appleWatchIsRequired && !CommunicationManagerIoS.shared.watchAppInstalledAndPaired
        
        switch self {
        case .diaryOnly:
            errorMessage = nil
        case .appleWatchPairedOnly:
            if isAppleWatchRequiredAndPaired {
                errorMessage = "watchMainErrorMsg".local()
            }
        case .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            if isAppleWatchRequiredAndPaired {
                errorMessage = "watchMainErrorMsg".local()
            }
            if CareGiversManager.shared.caregivers.isEmpty {
                errorMessage = (errorMessage ?? "") + ". There are no caregivers identified. Please go in Settings and add at least one caregiver.".local()
            }
        case .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
            // TODO: Future handling for pediatric users to be developed. See ROADMAP.md.
            break
        }
        return errorMessage
    }
}

extension DataSourceManager: Codable {
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case selectedDataSourceRawValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedDataSourceRawValue, forKey: .selectedDataSourceRawValue)
    }
    
    // MARK: - JSON Conversion
    public func jsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let backupData: [String: Any] = [
                "dataSource": dataSource.rawValue,
                "selectedDataSourceRawValue": selectedDataSourceRawValue
            ]
            let data = try JSONSerialization.data(withJSONObject: backupData, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to encode DataSourceManager: \(error)")
            return nil
        }
    }
    
    public func loadFromJson(jsonString: String) {
        do {
            let data = jsonString.data(using: .utf8)!
            let backupData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: String]
            
            if let dataSourceRawValue = backupData["dataSource"],
               let selectedDataSourceRawValue = backupData["selectedDataSourceRawValue"] {
                DispatchQueue.main.async {
                    self.dataSource = DataSource(rawValue: dataSourceRawValue) ?? .diaryOnly
                    self.selectedDataSourceRawValue = selectedDataSourceRawValue
                }
                UserDefaults.standard.set(self.selectedDataSourceRawValue, forKey: appStorageKey)
            }
        } catch {
            print("Failed to decode DataSourceManager: \(error)")
        }
    }
}
