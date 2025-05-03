//
//  Symptoms Enums.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 10/02/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg

// the symptoms that we can handle
public enum HandledSymptomsEvents: String, CaseIterable, Codable, Comparable, Hashable {
    public static func < (lhs: HandledSymptomsEvents, rhs: HandledSymptomsEvents) -> Bool {
        lhs.localizedString() < rhs.localizedString()
    }
    
    case none = "sympt_emptySymptom"
    case myoclonicTrembling = "sympt_Myoclonic_Trembling"
    case realTimeSessionEnded = "event_realTimeSessionEnded"
    case realTimeSessionStarted = "event_RealTimeSessionStarted"
    case seizure = "sympt_seizure"
    case oldSeizure = "Seizure"
    case highBPM = "sympt_highBPM"
    case lowBPM = "sympt_lowBPM"
    case constipation = "sympt_constipation"
    case diarrhea = "sympt_diarrhea"
    case hiccup = "sympt_hiccup"
    case dizziness = "sympt_dizziness"
    case fatigue = "sympt_fatigue"
    case fever = "sympt_fever"
    case headache = "sympt_headache"
    case medicalExamination = "sympt_medicalExamination"
    case hospitalization = "sympt_hospitalization"
    case emergencyRoom = "sympt_emergencyRoom"
    case coughing = "sympt_coughing"
    case nausea = "sympt_nausea"
    case shortnessOfBreath = "sympt_shortnessOfBreath"
    case soreThroat = "sympt_soreThroat"
    case vomiting = "sympt_vomiting"
    case excitement = "sympt_excitement"
    case moodChanges = "sympt_moodChanges"
    case medicationChange = "sympt_medicationChange"
    case sleepChanges = "sympt_sleepChanges"
    case sleepDeprivation = "sympt_sleepDeprivation"
    case appetiteChanges = "sympt_appetiteChanges"
    case videoLog = "sympt_videoLog"
    case videoSeizureLog = "sympt_videoSeizureLog"
    case oldVideoSeizureLog = "Seizure Log"
    case textLog = "sympt_textLog"
    case stress = "sympt_stress"
    case medicationTaken = "sympt_medicationTaken"
    case medicationForgotten = "sympt_medicationForgotten"
    case cold = "sympt_cold"
    case other = "sympt_other"
    case emergencyMedication = "sympt_emergencyMedication"
    case filter = "sympt_FilterSupport"
    case all = "allLogs"
    case byDate = "filterByDate"
    case therapy = "sympt_therapy"
    case fall = "sympt_fall"
    case headShot = "sympt_headShot"
    case sport = "sympt_sport"
    case vaccine = "sympt_vaccine"
    case covidVaccine = "sympt_covidVaccine"
    case covid = "sympt_covid"
    case otherMedications = "sympt_other_medications"
    case absence = "sympt_absence"
    case dermatitis = "sympt_dermatitis"
    case menses = "sympt_menses"
    case toothache = "sympt_toothache"
    case aura = "sympt_aura"
    case ask4Help = "sympt_ask4Help"
    case alarmFired = "sympt_AlarmFired"
    case moodHappy = "sympt_mood_happy"
    case moodCalm = "sympt_mood_calm"
    case moodSad = "sympt_mood_sad"
    case moodAngry = "sympt_mood_angry"
    case moodAnxious = "sympt_mood_anxious"
    case error = "errorMsg"
    case noData = "NoDataEventStringV2"
    case snoozeReminder = "medicationSnoozeString"
    
    public func localizedString() -> String {
        self.rawValue.local()
    }
    
    public var value: String {
        return self.rawValue
    }
    
    static public var allPossibleSymptoms: [HandledSymptomsEvents] {
        let reservedEvents: [HandledSymptomsEvents] = [.none, .videoLog, .videoSeizureLog, .textLog,.oldSeizure, .oldVideoSeizureLog, .filter,
            .byDate, .all, .realTimeSessionEnded, .realTimeSessionStarted,
            .ask4Help, .alarmFired, .moodSad, .moodCalm, .moodAngry,
            .moodHappy, .moodAnxious, .error, .noData, .snoozeReminder]
        
        var returnArray: [HandledSymptomsEvents] = []
        HandledSymptomsEvents.allCases
            .filter { symptom -> Bool in
                !reservedEvents.contains(symptom)
            }
            .forEach { symptom in
                returnArray.append(symptom)
            }
        
        return returnArray.sorted { lhs, rhs -> Bool in
            if lhs.fastLaneInt == 1, rhs.fastLaneInt != 1 {
                return true
            }
            if lhs.fastLaneInt != 1, rhs.fastLaneInt == 1 {
                return false
            }
            return lhs.localizedString() < rhs.localizedString()
        }
    }
    
    static var testSymptoms: [HandledSymptomsEvents] = [.seizure, .absence, .aura]
    
    static public var allPossibleSymptomsDictionary: [SymptomCategory: [SymptomLog]] {
        let reservedEvents: [HandledSymptomsEvents] = [.none, .videoLog, .videoSeizureLog, .textLog, .oldSeizure, .oldVideoSeizureLog, .filter,
            .byDate, .all, .realTimeSessionEnded, .realTimeSessionStarted, .error, .noData, .snoozeReminder, .ask4Help, .alarmFired, .moodSad, .moodCalm, .moodAngry, .moodHappy, .moodAnxious]
        
        var categoryDictionary: [SymptomCategory: [SymptomLog]] = [:]
        
        HandledSymptomsEvents.allCases
            .filter { symptom -> Bool in
                !reservedEvents.contains(symptom)
            }
            .forEach { symptom in
                let category = symptom.symptomCategory
                
                if var categorySymptoms = categoryDictionary[category] {
                    categorySymptoms.append(SymptomLog(symptom))
                    categoryDictionary[category] = categorySymptoms
                } else {
                    categoryDictionary[category] = [SymptomLog(symptom)]
                }
            }
        return categoryDictionary
    }
    
    static public var allPossibleSymptomsLocalized: [String] {
        allPossibleSymptoms.map { sympt in
            sympt.localizedString()
        }
    }
    
    static var allPossibleFilters = (allPossibleSymptoms + [.realTimeSessionEnded, .videoSeizureLog, .videoLog]).sorted()
    
    static var seizuresRelatedSymptoms: [HandledSymptomsEvents] = [.seizure, .videoSeizureLog]
    
    static var remoteEventsWithANeededAction: [HandledSymptomsEvents] = [
        .seizure, .highBPM, .lowBPM, .hospitalization, .emergencyRoom, .vomiting, .videoSeizureLog, .emergencyMedication, .absence
    ]
    
    static var severeKeyEvents: [HandledSymptomsEvents] {
        HandledSymptomsEvents.allCases
            .filter { symptom -> Bool in
                symptom.symptomCategory == .severe
            }
    }
    
    var fastLaneInt: Int {
        switch self {
        case .seizure, .medicationTaken, .medicationForgotten, .emergencyMedication: return 1
        default: return 2
        }
    }
    
    public var quickCommandsImage: String {
        switch self {
        case .seizure: return "bolt"
        case .videoLog: return "video"
        default: return image
        }
    }
    
    public var image: String {
        switch self {
        case .none:
            return "xmark.rectangle.portrait"
        case .hiccup:
            return "wind"
        case .seizure:
            return "bolt.circle"
        case .constipation:
            return "tray.and.arrow.down"
        case .medicationTaken:
            return "pills.fill"
        case .medicationForgotten:
            return "pills"
        case .diarrhea:
            return "flame"
        case .dizziness:
            return "tornado"
        case .fatigue:
            return "hand.thumbsdown"
        case .fever:
            return "thermometer"
        case .headache:
            return "brain.head.profile"
        case .toothache:
            return "mouth"
        case .coughing:
            return "mouth"
        case .medicationChange:
            return "pills"
        case .nausea:
            return "nose.fill"
        case .shortnessOfBreath:
            return "lungs"
        case .soreThroat:
            return "aqi.low"
        case .vomiting:
            return "trash"
        case .moodChanges:
            return "person.and.arrow.left.and.arrow.right"
        case .sleepChanges:
            return "moon.zzz"
        case .appetiteChanges:
            return "mouth"
        case .videoLog:
            return "video.circle.fill"
        case .videoSeizureLog:
            return "video.bubble.left"
        case .textLog:
            return "doc.text"
        case .other:
            return "quote.bubble"
        case .stress:
            return "hand.thumbsdown"
        case .highBPM:
            return "arrow.up.heart"
        case .lowBPM:
            return "arrow.down.heart"
        case .sleepDeprivation:
            return "powersleep"
        case .medicalExamination:
            return "waveform.path.ecg.rectangle"
        case .hospitalization:
            return "bed.double.fill"
        case .emergencyRoom:
            return "cross.fill"
        case .excitement:
            return "hands.sparkles"
        case .oldSeizure:
            return "bolt.circle"
        case .oldVideoSeizureLog:
            return "video.bubble.left"
        case .emergencyMedication:
            return "cross.case.fill"
        case .filter:
            if #available(iOS 15.0, *) {
                return "line.3.horizontal.decrease.circle"
            } else {
                return "circle"
            }
        case .all:
            return Tab.insights.image
        case .byDate:
            return "calendar"
        case .realTimeSessionEnded:
            return Tab.realtimeMonitor.image
        case .cold:
            return "nose"
        case .fall: return "person.fill.turn.down"
        case .headShot: return "person.fill.xmark"
        case .therapy:
            if #available(iOS 15.0, *) {
                return "person.2.wave.2"
            } else {
                return "circle"
            }
        case .sport: return "sportscourt"
        case .vaccine, .covidVaccine, .dermatitis:
            if #available(iOS 15.0, *) {
                return "allergens"
            } else {
                return "circle"
            }
        case .covid:
            if #available(iOS 15.0, *) {
                return "globe.europe.africa"
            } else {
                return "circle"
            }
        case .otherMedications:
            return "pills"
        case .absence:
            return "person.fill.xmark"
        case .menses:
            return "oval.fill"
        case .aura:
            return "waveform.path"
        case .ask4Help:
            return "hand.raised"
        case .alarmFired:
            return "light.beacon.max"
        case .realTimeSessionStarted:
            return "play.circle"
        case .moodHappy:
            return "😀"
        case .moodCalm:
            return "😌"
        case .moodSad:
            return "😞"
        case .moodAngry:
            return "😡"
        case .moodAnxious:
            return "😓"
        case .error:
            return "exclamationmark.circle"
        case .noData:
            return "antenna.radiowaves.left.and.right.slash"
        case .snoozeReminder:
            return "timer"
        case .myoclonicTrembling:
            return "hand.raised.fill"
        }
    }
    
    public enum SymptomCategory: String, CaseIterable {
        case symptom = "symptomString"
        case warning = "potentialTriggerString"
        case severe = "severeEventString"
        case goodHabit = "goodHabitString"
        case badHabit = "badHabitString"
        case supportingFuncts = "supportingFunctionsString"
        case errors = "errorMsg"
        
        var categoryColor: Color {
            switch self {
            case .badHabit, .warning, .severe:
                return stefiPurple
            case .goodHabit:
                return .green
            case .symptom:
                return .primary
            case .supportingFuncts:
                return .secondary
            case .errors:
                return .red
            }
        }
        
        var diaryOrder: Int {
            switch self {
            case .symptom:
                return 4
            case .warning:
                return 1
            case .severe:
                return 0
            case .goodHabit:
                return 3
            case .badHabit:
                return 2
            case .errors:
                return 3
            case .supportingFuncts:
                return 99
            }
        }
    }
    
    var isVideo: Bool {
        switch self {
        case .videoLog, .videoSeizureLog, .oldVideoSeizureLog:
            return true
        default:
            return false
        }
    }
    
    var symptomCategory: SymptomCategory {
        switch self {
        case .seizure, .hospitalization, .emergencyRoom, .videoSeizureLog, .emergencyMedication, .ask4Help, .alarmFired:
            return .severe
        case .highBPM, .lowBPM, .fever, .headache, .sleepDeprivation, .stress, .medicationForgotten, .medicationChange, .absence, .aura:
            return .warning
        case .videoLog, .textLog, .medicationTaken, .realTimeSessionEnded, .vaccine,.covidVaccine:
            return .goodHabit
        case .filter, .all, .moodSad, .moodCalm, .moodAngry, .moodHappy, .moodAnxious:
            return .supportingFuncts
        case .error, .noData:
            return .errors
        default:
            return .symptom
        }
    }
    
    var soundName: String {
        switch self {
        case .seizure, .hospitalization, .emergencyRoom, .videoSeizureLog, .emergencyMedication, .ask4Help:
            return SoundOptions.shared.alarmSound
        default:
            return SoundOptions.shared.notificationSound
        }
    }
    
    var hasLenght: Bool {
        switch self {
        case .none, .medicationChange, .medicationTaken, .emergencyMedication,
                .medicationForgotten, .videoLog, .vaccine, .covidVaccine,
                .medicalExamination, .emergencyRoom, .hospitalization,
                .fever, .otherMedications, .realTimeSessionStarted, .moodSad, .moodCalm, .moodAngry, .moodHappy, .moodAnxious:
            return false
        default:
            return true
        }
    }
    
    static public var dailyMoods: [HandledSymptomsEvents] {
        [.moodHappy, .moodCalm, .moodSad, .moodAngry, .moodAnxious]
    }
    
    var symptomColor: Color {
        symptomCategory.categoryColor
    }
    
    var fastLogColor: Color {
        return stefiViolet
    }
    
    var fileType: MirrorHRFileTypes {
        switch self {
        case .videoLog:
            return .videoLog
        case .videoSeizureLog:
            return .seizureLog
        case .oldVideoSeizureLog:
            return .seizureLog
        default:
            return .json
        }
    }
}

// the Severity Ranges  that we can handle
// -  .unspecified 0
// -  .notPresent 1
// - .mild 2
// - .moderate 3
// - .severe 4
public enum SymptomSeverityRanges: String, CaseIterable {
    case unspecified = "Unspecified"
    case notPresent = "Not Present"
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    
    var hKCategoryValueSeverity: String {
        switch self {
        case .unspecified: return ".unspecified"
        case .notPresent: return ".notPresent"
        case .mild: return ".mild"
        case .moderate: return ".moderate"
        case .severe: return ".severe"
        }
    }
    
    static var keySeverityIndicators: [SymptomSeverityRanges] {
        [.moderate, .severe]
    }
    
    var icon: String {
        switch self {
        case .unspecified: return "questionmark.circle.fill"
        case .notPresent: return "checkmark.circle.fill"
        case .mild: return "bolt.fill"
        case .moderate: return "bolt.circle"
        case .severe: return "bolt.circle.fill"
        }
    }
    
    var value: Int {
        switch self {
        case .unspecified: return 0
        case .notPresent: return 1
        case .mild: return 2
        case .moderate: return 3
        case .severe: return 4
        }
    }
    
    static var severeOnlyGreatherOrEqualValue: Int {
        2
    }
    
    var emoji: String {
        switch self {
        case .unspecified: return "🤔"
        case .notPresent: return "😐"
        case .mild: return "☹️"
        case .moderate: return "😰"
        case .severe: return "🥵"
        }
    }
    
    var circles: String {
        "◉"
    }
    
    var coloredCircles: Color {
        switch self {
        case .unspecified: return .gray
        case .notPresent: return .green
        case .mild: return .yellow
        case .moderate: return .orange
        case .severe: return .red
        }
    }
    
    var color: Color {
        switch self {
        case .unspecified: return .gray
        case .notPresent: return .green
        case .mild: return .orange
        case .moderate: return .purple
        case .severe: return .red
        }
    }
    
    static var arrayOfSeverityItemsAsString: [String] {
        var returnArray: [String] = []
        SymptomSeverityRanges.allCases.forEach { item in
            returnArray.append(item.rawValue)
        }
        return returnArray
    }
    
    static var arrayOfSeverityItemsAsEmoji: [String] {
        var returnArray: [String] = []
        SymptomSeverityRanges.allCases.forEach { item in
            returnArray.append(item.emoji)
        }
        return returnArray
    }
    
    static func nameByValue(value: Int) -> SymptomSeverityRanges {
        switch value {
        case 0: return SymptomSeverityRanges.unspecified
        case 1: return SymptomSeverityRanges.notPresent
        case 2: return SymptomSeverityRanges.mild
        case 3: return SymptomSeverityRanges.moderate
        case 4: return SymptomSeverityRanges.severe
        default: return SymptomSeverityRanges.unspecified
        }
    }
}

struct ArrayOfSymptoms: Codable {
    var symptoms: [HandledSymptomsEvents]
    
    init(_ symptoms: [HandledSymptomsEvents]) {
        self.symptoms = symptoms
    }
    
    init() {
        self.symptoms = []
    }
    
    public var jsonString: String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode jsonstring", .error, sourceModule: "ArrayOfSymptoms jsonString")
            return ""
        }
    }
    
    public static func loadFromJson(jsonString: String) -> ArrayOfSymptoms? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(ArrayOfSymptoms.self, from: data)
    }
}
