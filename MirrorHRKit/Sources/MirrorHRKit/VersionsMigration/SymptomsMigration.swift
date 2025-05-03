//
//  SymptomsMigration.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 20/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
// even if it's complex it should be one just once in a lifetime
// swiftlint:disable cyclomatic_complexity

extension HandledSymptomsEvents {
    // version 5 to version 6
    static func migrateToLocalizedVersion(_ symptomString: String) -> HandledSymptomsEvents {
        switch symptomString {
        case "none": return .none
        case "seizure": return .seizure
        case "highBPM": return .highBPM
        case "lowBPM": return .lowBPM
        case "constipation": return .constipation
        case "diarrhea": return .diarrhea
        case "hiccup": return .hiccup
        case "dizziness": return .dizziness
        case "fatigue": return .fatigue
        case "fever": return .fever
        case "headache": return .headache
        case "medicalExamination": return .medicalExamination
        case "hospitalization": return .hospitalization
        case "emergencyRoom": return .emergencyRoom
        case "coughing": return .coughing
        case "nausea": return .nausea
        case "shortnessOfBreath": return .shortnessOfBreath
        case "soreThroat": return .soreThroat
        case "vomiting": return .vomiting
        case "excitement": return .excitement
        case "moodChanges": return .moodChanges
        case "sleepChanges": return .sleepChanges
        case "sleepDeprivation": return .sleepDeprivation
        case "appetiteChanges": return .appetiteChanges
        case "videoLog": return .videoLog
        case "videoSeizureLog": return .videoSeizureLog
        case "textLog": return .textLog
        case "stress": return .stress
        case "medicationTaken": return .medicationTaken
        case "medicationForgotten": return .medicationForgotten
        case "other": return .other
        case "empty symtpom": return .none
        case "Seizure": return .seizure
        case "High heart beat": return .highBPM
        case "Low hearth beat": return .lowBPM
        case "Constipation": return .constipation
        case "Diarrhea": return .diarrhea
        case "Hiccup": return .hiccup
        case "Dizziness": return .dizziness
        case "Fatigue": return .fatigue
        case "Fever": return .fever
        case "Headache": return .headache
        case "Medical examination": return .medicalExamination
        case "Hospitalization": return .hospitalization
        case "Emergency Room": return .emergencyRoom
        case "Coughing": return .coughing
        case "Nausea": return .nausea
        case "Shortness of breath": return .shortnessOfBreath
        case "Sore Throat": return .soreThroat
        case "Vomiting": return .vomiting
        case "Excitement": return .excitement
        case "Mood Changes": return .moodChanges
        case "Sleep Changes": return .sleepChanges
        case "Sleep deprivation": return .sleepDeprivation
        case "Appetite Changes": return .appetiteChanges
        case "Video Diary": return .videoLog
        case "Seizure Log": return .videoSeizureLog
        case "Text Log": return .textLog
        case "Stress": return .stress
        case "Medication taken": return .medicationTaken
        case "Medication forgotten": return .medicationForgotten
        case "Other": return .other
        default: return .other
        }
    }
}

// swiftlint:enable cyclomatic_complexity
