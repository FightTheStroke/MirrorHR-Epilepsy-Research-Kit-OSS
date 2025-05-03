//
//  MigrationExtensions.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 19/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SharedPkg
import SwiftUI

extension SymptomsManager {
    // MARK: migration support

    func migrateData() {
        symptomsData.forEach { symptom in
            if (HandledSymptomsEvents(rawValue: symptom.symptom!) == nil) ||
                (oldSymptoms.contains(HandledSymptomsEvents(rawValue: symptom.symptom!)!)) {
                migrateSymptomStructure(symptom)
            }
            if symptom.notes == deprecatedDefaultQuickLogNote {
                migrateDeprecatedDefaultNotes(symptom)
            }
        }
        structureIsMigrated = true
        deprecatedNotesMigrated = true
        mainDebugger.append("Symptoms and notes have been migrated to the new structure 6.6", .greenFlag)
    }

    func migrateSymptomName(_ symptom: SymptomsData) -> HandledSymptomsEvents {
        let migratedSymptom = HandledSymptomsEvents.migrateToLocalizedVersion(symptom.symptom ?? "other")
        symptom.symptom = migratedSymptom.rawValue
        saveAndRefresh()
        return migratedSymptom
    }

    func migrateDeprecatedDefaultNotes(_ symptom: SymptomsData) {
        context.performAndWait {
            symptom.notes = defaultQuickLogNote
            saveAndRefresh()
        }
    }

    func migrateSymptomStructure(_ symptom: SymptomsData) {
        context.performAndWait {
            let migratedSymptom = HandledSymptomsEvents.migrateToLocalizedVersion(symptom.symptom ?? "other")
            symptom.symptom = migratedSymptom.rawValue
            saveAndRefresh()
        }
    }
}
