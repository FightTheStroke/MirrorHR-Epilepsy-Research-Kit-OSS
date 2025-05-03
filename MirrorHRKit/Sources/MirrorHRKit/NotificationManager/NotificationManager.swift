//
//  NotificationManager.swift
//  MirrorHR
//
//  Created by Roberto D'Angelo on 09/11/2020.
//

import Combine
import Foundation
import SwiftUI
import UserNotifications
import SharedPkg
import PermissionsManager
import WindowsAzureMessaging

// MARK: LocalNotification Manager
public class NotificationManager: UIResponder, ObservableObject, UNUserNotificationCenterDelegate, EventsSubscriber, ErasableClass {
    static public let shared = NotificationManager()
    
    internal let syncQueue = DispatchQueue(label: "com.mirrorHR.notificationManager.syncQueue")

    internal var realTimeEventsManager = RealTimeEventsManager.shared
    internal var settings = ProfileGenericSettings.shared
    let notificationCenter = UNUserNotificationCenter.current()
    public var eraseCommandSubscriber = AnyCancellable {}
    public var eventSubscriber = AnyCancellable {}
    
    /// Tracks active notification tasks for proper cancellation
    private var activeTasks: [UUID: Task<Void, Never>] = [:]
    
    /// Minimum time intervals between notifications of the same type
    var lastAlarmNotificationFired: TimeInterval = 0.0
    var lastBatteryNotificationFired: TimeInterval = 0.0
    var lastCriticalErrorNotificationFired: TimeInterval = 0.0
    var authorizationStatus: AuthorizationStatus = .notDetermined
    
    var trigger: UNNotificationTrigger?

    var observers: [UNUserNotificationCenterDelegate] = []
    
    /// Request notification permissions with better error handling
    public func askPermissions() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound, .criticalAlert]
        
        Task {
            do {
                let granted = try await notificationCenter.requestAuthorization(options: options)
                await MainActor.run {
                    self.authorizationStatus = granted ? .authorized : .denied
                    if !granted {
                        mainDebugger.append("Notification permission denied by user", .warning, sourceModule: "NotificationManager")
                    }
                }
            } catch {
                await MainActor.run {
                    mainDebugger.append("Notification permission error: \(error.localizedDescription)", .error, sourceModule: "NotificationManager")
                    self.authorizationStatus = .error(error: error)
                    dispatchMainEvent(.cantFireNotification(errorMessage: error.localizedDescription), "NotificationManager")
                }
            }
        }
    }
    
    /// Check current notification authorization status
    public func checkAuthorizationStatus(completion: @escaping (AuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.authorizationStatus = .authorized
                case .denied:
                    self.authorizationStatus = .denied
                case .notDetermined:
                    self.authorizationStatus = .notDetermined
                @unknown default:
                    self.authorizationStatus = .notDetermined
                }
                completion(self.authorizationStatus)
            }
        }
    }
    
    override public init() {
        super.init()
        notificationCenter.delegate = self
        removePendingNoDataCheckNotifications()

        eventSubscriber = mainEventsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] event in
                guard let self = self else { return }
                self.handleEvents(event: event)
            })

        eraseCommandSubscriber = eraseCommandCombinePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.eraseAllNotifications()
            }
    }
    
    deinit {
        // Cancel all pending tasks and remove observers
        cancelAllTasks()
        eraseCommandSubscriber.cancel()
        eventSubscriber.cancel()
    }
    
    /// Schedule a notification with proper error handling and task management
    /// - Parameters:
    ///   - content: The notification content
    ///   - identifier: A unique identifier for the notification
    ///   - trigger: Optional trigger for the notification, nil for immediate delivery
    ///   - completion: Optional callback with success or error
    public func scheduleNotification(
        content: UNNotificationContent,
        identifier: String,
        trigger: UNNotificationTrigger? = nil,
        completion: ((Result<Void, Error>) -> Void)? = nil
    ) {
        let taskID = UUID()
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            defer {
                // Clean up task reference when complete
                DispatchQueue.main.async {
                    self.activeTasks[taskID] = nil
                }
            }
            
            // Create the request
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            do {
                try await self.notificationCenter.add(request)
                DispatchQueue.main.async {
                    completion?(.success(()))
                }
            } catch {
                mainDebugger.append("Failed to schedule notification: \(error.localizedDescription)", .error, sourceModule: "NotificationManager")
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
        
        // Store task for potential cancellation
        activeTasks[taskID] = task
    }
    
    /// Cancel all active tasks to prevent memory leaks
    private func cancelAllTasks() {
        for task in activeTasks.values {
            task.cancel()
        }
        activeTasks.removeAll()
    }
}
