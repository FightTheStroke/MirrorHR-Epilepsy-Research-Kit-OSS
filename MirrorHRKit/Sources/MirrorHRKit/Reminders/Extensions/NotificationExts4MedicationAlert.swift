//
//  MedicationManagerNotificationExts.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D'Angelo on 17/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import UserNotifications
import SharedPkg

// Delegate
extension MedicationManager {
    public func medicationTakenAction() {
        SymptomLog(.medicationTaken).append { _ in
            mainDebugger.append("medication taken thx to reminder", .event)
        }
    }
    
    public func medicationSnoozeAction() {
        let proxyMedicationManager: ProxyMedicationManager = .shared
        guard proxyMedicationManager.snoozeReminder() else {
            handleMissedMedication()
            mainDebugger.append("Medication manager: handling missed medication as snooozescounter was over the limit of snoozes", .event)
            return
        }
        // If snoozesCounter < maxSnoozesAllowed, allow snoozing the alarm. For the final reminder, snoozing is disabled to ensure medication adherence.
        notificationManager.fireNotification(
            event: .medicationSnooze,
            triggerInterval: ProxyMedicationManager.shared.snoozeDelay,
            customMetaData: .init(name: "SNOOZECOUNTER", valueInt: proxyMedicationManager.snoozeCounter)
        )
        mainDebugger.append("Medication Manager: firing snooze notification #\(proxyMedicationManager.snoozeCounter)", .event)
    }
    
    public func handleMissedMedication() {
        SymptomLog(.medicationForgotten).append { _ in
            mainDebugger.append("medication forgotten", .event)
        }
    }
    
    public func handleMedicationViaAlert() {
        ProxyMedicationManager.shared.handleMedicationViaConfirmationDialog()
        mainDebugger.append("Medication handled via alert", .event)
    }
}
