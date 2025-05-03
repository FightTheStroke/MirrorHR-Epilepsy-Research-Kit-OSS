//
//  VideoPickerControlsView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 10/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import RoberdanToolBox

struct SymptomsLearnerView: View {
    @ObservedObject var suggestedSymptoms = FinalSuggestedSymptoms.shared

    init(suggestedSymptomsFromAI: ArrayOfSymptoms) {
        suggestedSymptoms.prepare4Validation(suggestedSymptoms: suggestedSymptomsFromAI.symptoms)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("confirmSymptomsUnderstanding".local())
                .fontWeight(.bold)
                .padding(.vertical)
            Text("appreciationForTheOpportunityToLearn".local())
                .fontWeight(.light)
                .padding(.bottom)
            Divider()
            ForEach(suggestedSymptoms.validator, id: \.uuid) { validator in
                ValidateSymptom(validator: validator)
                Divider()
            }
            Spacer()
        }
        .padding()
        .background(Color(tertiaryBgkColor))
        .opacity(0.8)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct ValidateSymptom: View {
    @ObservedObject var validator: Validator
    var body: some View {
        HStack {
            Text(validator.symptom.localizedString())
                .font(.title2)
            Spacer()
            Button {
                validator.toggle()
            } label: {
                Image(systemName: validator.validated ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(validator.validated ? .green : .gray)
                    .font(.title2)
            }
        }
    }
}
