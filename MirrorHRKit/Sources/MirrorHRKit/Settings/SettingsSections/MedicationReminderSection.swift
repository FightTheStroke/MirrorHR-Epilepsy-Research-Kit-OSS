//
//  MedicationReminderSection.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 03/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg

extension SettingsView {
    var medicationReminderSection: SettingsSection {
        SettingsSection(
            id: "MedicationReminder",
            header: medicationAlarmString,
            image: "clock",
            rows: [
                .button(name: addMedicationReminderString, image: "plus", action: {
                    SheetViewController.shared.reset()
                    SheetViewController.shared.okActionImage = "plus"
                    SheetViewController.shared.okActionText = addButtonString
                    SheetViewController.shared.okAction = { MedicationManager.shared.scheduleMedicationReminder() }
                    SheetViewController.shared.cancelActionText = closeButtonString
                    SheetViewController.shared.cancelActionImage = "xmark"
                    SheetViewController.shared.sheetContentView = AnyView(MedicationManagerView(showHeader: false))
                    SheetViewController.shared.sheetVisible = true
                }),
                .custom(name: "", AnyView(RemindersWeekDayListView(showEditBtn: false)), isEnabled: true)
            ],
            footer: medicationAlarmFooter,
            isEnabled: true,
            foregroundColor: stefiPurple
        )
    }
}

extension SettingsView {
    var currentTherapySection: SettingsSection {
        SettingsSection(
            id: "CurrentTherapy",
            header: "therapiesNavTitle".local(),
            image: "pills",
            rows: [
                .button(name: "addUpdateTherapiesText".local(), image: "plus", action: {
                    SheetViewController.shared.reset()
                    SheetViewController.shared.cancelActionText = closeButtonString
                    SheetViewController.shared.cancelActionImage = "xmark"
                    SheetViewController.shared.sheetContentView = AnyView(TherapyDBEditView())
                    SheetViewController.shared.sheetVisible = true
                }),
                .custom(name: "", AnyView(TherapyCurrentView()), isEnabled: true)
            ],
            footer: "therapySessionFooterText".local(),
            isEnabled: true,
            foregroundColor: stefiPurple
        )
    }
}
