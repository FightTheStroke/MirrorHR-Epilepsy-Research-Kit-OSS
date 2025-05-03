//
//  SymptOnTapTimeLineHeader.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 25/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI

class UpdatingSymptomSupport: ObservableObject {
    @Published var notes: String {
        didSet {
            appendKindaOfUpdate(element: .newNotes)
        }
    }

    @Published var startDate: Date {
        didSet {
            appendKindaOfUpdate(element: .newStartDate)
        }
    }

    @Published var symptom: HandledSymptomsEvents {
        didSet {
            appendKindaOfUpdate(element: .newSymptom)
        }
    }

    init() {
        notes = ""
        startDate = Date()
        symptom = .none
    }

    init(existingNotes: String, existingStartDate: Date, existingSymptom: HandledSymptomsEvents) {
        notes = existingNotes
        startDate = existingStartDate
        symptom = existingSymptom
    }

    var kindaOfUpdates: [KindaOfUpdate] = []

    func appendKindaOfUpdate(element: KindaOfUpdate) {
        if !kindaOfUpdates.contains(element) {
            kindaOfUpdates.append(element) // this is to avoid appending multiple times in case a TextEditor or other stuff fires multiple times a change in a var
        }
    }

    enum KindaOfUpdate {
        case newNotes
        case newStartDate
        case newSymptom
    }
}
