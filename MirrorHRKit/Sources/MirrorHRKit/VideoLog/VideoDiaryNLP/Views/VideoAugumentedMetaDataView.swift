//
//  VideoAugumentedMetaDataView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 06/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI

struct VideoAugumentedMetaDataView: View {
    var symptom: SymptomsData
    
    var body: some View {
        VStack(alignment: .leading) {
//            if let transcript = symptom.videoTranscript {
//                Text(transcript)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
            if let videoMetaData: String = symptom.videoMetaData {
                Text("detectSympstomsString".local() + ": " + returnAllSuggestedSymptoms(jsonString: videoMetaData))
            }
        }
    }
    
    func returnAllSuggestedSymptoms(jsonString: String) -> String {
        let suggestedSymptoms: [HandledSymptomsEvents] = ArrayOfSymptoms.loadFromJson(jsonString: jsonString)?.symptoms ?? []
        var allSuggestedSymptomsString = ""

        suggestedSymptoms.forEach { sympt in
            allSuggestedSymptomsString += "\(sympt.localizedString()), "
        }
        return String(allSuggestedSymptomsString.dropLast(2))
    }
}
