//
//  HealthEnums.swift
//  
//
//  Created by Roberto D’Angelo on 25/12/21.
//

import Foundation
import HealthKit
import SwiftUI
import SharedPkg

enum SeverityRanges: String, CaseIterable {
    case unspecified = "Unspecified"
    case notPresent = "Not Present"
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"

    var hKCategoryValueSeverity: HKCategoryValueSeverity {
        switch self {
        case .unspecified: return .unspecified
        case .notPresent: return .notPresent
        case .mild: return .mild
        case .moderate: return .moderate
        case .severe: return .severe
        }
    }

    static var keySeverityIndicators: [SeverityRanges] {
        [.mild, .moderate, .severe]
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

    var index: Int {
        switch self {
        case .unspecified: return 0
        case .notPresent: return 1
        case .mild: return 2
        case .moderate: return 3
        case .severe: return 4
        }
    }

    static let severeOnlyGreatherOrEqualValue: Int = 2

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

    var color: UIColor {
        switch self {
        case .unspecified: return .gray
        case .notPresent: return .green
        case .mild: return .orange
        case .moderate: return .magenta
        case .severe: return .red
        }
    }

    static var arrayOfSeverityItemsAsString: [String] {
        SeverityRanges.allCases.map(\.rawValue)
    }

    static var arrayOfSeverityItemsAsEmoji: [String] {
        SeverityRanges.allCases.map(\.emoji)
    }

    static func nameByValue(value: Int) -> SeverityRanges {
        switch value {
        case 0: return SeverityRanges.unspecified
        case 1: return SeverityRanges.notPresent
        case 2: return SeverityRanges.mild
        case 3: return SeverityRanges.moderate
        case 4: return SeverityRanges.severe
        default: return SeverityRanges.unspecified
        }
    }
}

enum HandledHealthKitSymptoms: String, CaseIterable {
    case seizure = "Seizure"
    case constipation = "Constipation"
    case diarrhea = "Diarrhea"
    case dizziness = "Dizziness"
    case drySkin = "Dry Skin"
    case fatigue = "Fatigue"
    case fever = "Fever"
    case generalizedBodyAche = "Generalized Body Ache"
    case headache = "Headache"
    case coughing = "Coughing"
    case nausea = "Nausea"
    case shortnessOfBreath = "Shortness of breath"
    case sleep = "Sleep"
    case soreThroat = "Sore Throat"
    case vomiting = "Vomiting"
    //    case moodChanges
    //    case sleepChanges
    //    case appetiteChanges

    var categoryTypeIdentifier: HKCategoryTypeIdentifier {
        switch self {
        case .seizure: return .fainting
        case .fever: return .fever
        case .nausea: return .nausea
        case .vomiting: return .vomiting
        case .diarrhea: return .diarrhea
        case .dizziness: return .dizziness
        case .fatigue: return .fatigue
        case .sleep: return .sleepAnalysis
        case .headache: return .headache
        case .coughing: return .coughing
        case .constipation: return .constipation
        case .generalizedBodyAche: return .generalizedBodyAche
        case .shortnessOfBreath: return .shortnessOfBreath
        case .soreThroat: return .soreThroat
        case .drySkin: return .drySkin
        }
    }
}

// MARK: daily mood

enum DailyMoods: Int, CaseIterable, Codable {
    case veryBad = 0
    case bad = 1
    case neutral = 2
    case good = 3
    case veryGood = 4

    var severityRange: SeverityRanges {
        switch self {
        case .veryBad: return .severe
        case .bad: return .moderate
        case .neutral: return .unspecified
        case .good: return .mild
        case .veryGood: return .notPresent
        }
    }
}

struct HealthKitMetadaString: Codable {
    var notes: String = ""
    var dailyMood: DailyMoods?

    init(notes: String) {
        self.notes = notes
    }

    init(dailyMood: DailyMoods) {
        self.dailyMood = dailyMood
    }

    init() {
        notes = ""
    }

    func returnMetadataForHealthKitQuery() -> [String: Any] {
        [mirrorHRMetadataKey: jsonString]
    }

    static func readMyMetadataFromSampleMetadata(sampleMetadata: [String: Any]) -> HealthKitMetadaString {
        guard let metadataString = sampleMetadata[mirrorHRMetadataKey] as? String else {
            return HealthKitMetadaString()
        }
        guard let metadata = loadFromJson(jsonString: metadataString) else {
            return HealthKitMetadaString()
        }
        return metadata
    }

    func hasNotes() -> Bool {
        guard notes != "" else {
            return false
        }
        return true
    }

    public var jsonString: String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode jsonstring", .error, sourceModule: "HealthKitMetadaString jsonString")
            return ""
        }
    }

    private static func loadFromJson(jsonString: String) -> HealthKitMetadaString? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(HealthKitMetadaString.self, from: data)
    }
}
