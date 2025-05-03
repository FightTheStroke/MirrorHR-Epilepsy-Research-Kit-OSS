//
//  MedicationManager.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D'Angelo on 02/10/21.
//  Copyright 2021 FightTheStroke Foundation. All rights reserved.
//

import Combine
import Foundation
import SharedPkg
import SwiftUI
import UserNotifications

// TODO: Test Medication database and alarm functionality. See TODO.md for open issues and ROADMAP.md for future improvements.
private actor FetchActor {
    private let notificationCenter: UNUserNotificationCenter
    
    init(notificationCenter: UNUserNotificationCenter) {
        self.notificationCenter = notificationCenter
    }
    
    func fetch() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            notificationCenter.getPendingNotificationRequests { notificationRequests in
                let reminders = notificationRequests.filter { notification in
                    notification.identifier.contains(Events.medicationAlert.description)
                }
                mainDebugger.append("Actor fetched reminders: \(reminders.count)", .event)
                continuation.resume(returning: reminders)
            }
        }
    }
}

/// A proxy class that provides a user-friendly interface for medication management.
///
/// The `ProxyMedicationManager` class acts as a wrapper around `MedicationManager` and provides:
/// - Simplified medication reminder handling
/// - Snooze functionality with configurable limits
/// - User confirmation dialogs
/// - Medication adherence tracking
/// - Integration with the symptoms management system
///
/// The class implements `ObservableObject` for SwiftUI integration and provides a clean API
/// for handling medication-related user interactions.
@MainActor
public class ProxyMedicationManager: ObservableObject {
    /// Shared instance of the ProxyMedicationManager
    public static let shared: ProxyMedicationManager = ProxyMedicationManager()
    
    /// The underlying medication manager instance
    @Published public var medicationManager: MedicationManager
    
    /// Manager for handling confirmation dialogs
    public let confirmationDialog: ConfirmationsDialogManager = .shared
    
    /// Counter for tracking snooze attempts
    public var snoozeCounter: Int = 0
    
    /// Maximum number of allowed snooze attempts
    public let maxSnoozesAllowed: Int = 3 // after 3 snoozes I report no medication taken
    
    /// Delay duration for snooze in seconds
    public let snoozeDelay: TimeInterval = 300 // snooze for 5 minutes
    
    /// Time interval to check for previous medication intake (in minutes)
    private let prevMedicationCheckIntervalMins: Int = -15 // check if medication already taken in the previous 15 mins
    
    /// Initializes a new ProxyMedicationManager instance
    private init() {
        medicationManager = .shared
    }
    
    public func medicationSnoozeAction() {
        medicationManager.medicationSnoozeAction()
    }
    
    public func handleMissedMedication() {
        medicationManager.handleMissedMedication()
    }
    
    public func medicationTakenAction() {
        medicationManager.medicationTakenAction()
    }
    
    public func snoozeReminder() -> Bool {
        snoozeCounter += 1
        if snoozeCounter <= maxSnoozesAllowed {
            return true
        } else {
            snoozeCounter = 0 // reset here the snoozecounter
            return false
        }
    }
    
    public func handleMedicationViaConfirmationDialog() {
        DispatchQueue.main.async { [self] in
            confirmationDialog.show(title: "medicationAlarmString",
                                    message: medicationAlarmMessage,
                                    actions:
                                        AnyView(
                                            VStack {
                                                // if snoozeCounter < maxSnoozesAllowed it's ok and we offer the opportunity to snooze the alarm.
                                                // But if it's the last option, then we don't permit to snooze it again. It's not a game.
                                                // If it's not important for you to take medications, for sure it will not be a stupid app able to help you.
                                                if snoozeCounter < maxSnoozesAllowed {
                                                    Button(role: .cancel, action: {
                                                        self.medicationSnoozeAction()
                                                    }, label: {
                                                        Text(medicationSnoozeString)
                                                    })
                                                    .keyboardShortcut(.defaultAction)
                                                    
                                                    Button(role: .destructive, action: {
                                                        self.handleMissedMedication()
                                                    }, label: {
                                                        Text(reportAsMissedMedicationString)
                                                    })
                                                } else {
                                                    Button(role: .cancel, action: {
                                                        self.handleMissedMedication()
                                                    }, label: {
                                                        Text(reportAsMissedMedicationString)
                                                    })
                                                }
                                                
                                                let medicationHasBeenTaken = ProxySymptomsManager().medicationTakenExists(
                                                    between: Date().addMins(number: prevMedicationCheckIntervalMins),
                                                    endDate: Date())
                                                
                                                // medication has been taken just a few minutes ago
                                                if medicationHasBeenTaken.exist, let lastMedication = medicationHasBeenTaken.last {
                                                    let sinceLast = Calendar.current.dateComponents(
                                                        [.minute],
                                                        from: lastMedication,
                                                        to: Date())
                                                    Button(action: {
                                                        mainDebugger.append("medication already taken a few minutes (\(sinceLast.minute ?? 0)) ago")
                                                        // no more actions needed, it was already stored, so just dismiss is ok
                                                    }, label: {
                                                        Text("alreadyTakenString".local() + " \(sinceLast.minute ?? 0)" + "minutesAgoString".local())
                                                    })
                                                }
                                                
                                                Button(action: {
                                                    self.medicationTakenAction()
                                                }, label: {
                                                    Text(medicationTakenString)
                                                })
                                            }
                                        )
            )
        }
    }
}

/// A manager class for handling medication reminders and adherence tracking.
///
/// The `MedicationManager` class is responsible for:
/// - Managing medication reminders and notifications
/// - Tracking medication adherence
/// - Handling snooze functionality
/// - Managing medication history
/// - Coordinating with the notification system
///
/// The class implements `UNUserNotificationCenterDelegate` for handling notifications
/// and conforms to `ObservableObject` for SwiftUI integration.
@MainActor
public class MedicationManager: NSObject, UNUserNotificationCenterDelegate, ObservableObject, @preconcurrency ErasableClass {
    /// Shared instance of the MedicationManager
    public static let shared = MedicationManager()
    
    /// Subscriber for erase commands
    public var eraseCommandSubscriber = AnyCancellable {}
    
    /// Actor for handling notification fetching
    private let fetchActor: FetchActor
    
    /// Wake-up time for medication reminders
    @Published var wakeUp = Date()
    
    /// Recurrence pattern for medication reminders
    @Published var recurrence: Recurrence = .weekDays
    
    /// List of active medication reminders
    @Published var medicationReminders: [UNNotificationRequest] = []
    
    /// Asynchronous list of medication reminders
    public var medicationAsyncReminders: [UNNotificationRequest] = []
    
    /// Manager for handling notifications
    let notificationManager: NotificationManager = NotificationManager.shared
    
    /// Center for managing user notifications
    let notificationCenter: UNUserNotificationCenter = NotificationManager.shared.notificationCenter
    
    /// Calendar for date calculations
    let calendar = Calendar.current
    
    /// Initializes a new MedicationManager instance
    private override init() {
        self.fetchActor = FetchActor(notificationCenter: NotificationManager.shared.notificationCenter)
        super.init()
        notificationManager.addObserver(self)
        setupEraseSubscriber()
        
        Task {
            await fetch()
        }
    }
    
    public func fetch() async {
        let fetchedReminders = await fetchActor.fetch()
        self.medicationAsyncReminders = fetchedReminders
        self.medicationReminders = fetchedReminders
        mainDebugger.append("Updated reminders on main thread: \(fetchedReminders.count)", .event)
    }
    
    private func setupEraseSubscriber() {
        eraseCommandSubscriber = eraseCommandCombinePublisher
            .sink { [weak self] in
                mainDebugger.append("Erase command received", .event)
                self?.deleteAll()
            }
    }
    
    // Medication adherence is crucial for effective treatment. This app is designed to support your medication schedule.
    func checkMedicationImportance() {
        // Implementation of checkMedicationImportance method
    }
}
