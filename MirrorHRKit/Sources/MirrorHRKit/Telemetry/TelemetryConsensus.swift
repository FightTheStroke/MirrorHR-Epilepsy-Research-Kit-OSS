//
//  TelemetryConsensus.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 02/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import RoberdanToolBox
import SharedPkg
import MirrorHRTelemetryPackage

struct TelemetryConsensusView: View {
    @ObservedObject var consensus: TelemetryConsensus = .shared
    
    public var body: some View {
        VStack {
            HStack {
                Text("ResearchID".local())
                Spacer()
                TextField("ResearchID", text: $consensus.researchID)
                    .font(.body)
                    .multilineTextAlignment(.trailing) // Aligns text to the right
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .onSubmit {
                        consensus.saveResearchID()
                    }
                    .onDisappear {
                        consensus.saveResearchID()
                    }
            }
            Divider()
            ForEach(Array(consensus.telemetries.enumerated()), id: \.element.id) { index, item in
                TelemetryTypeConsensusView(index: index)
            }
        }
        .padding()
    }
}

public struct TelemetryTypeConsensusView: View {
    @ObservedObject var consensus: TelemetryConsensus = .shared
    let index: Int
    
    public var body: some View {
        Toggle(isOn: $consensus.telemetries[index].isOn) {
            Text(consensus.telemetries[index].telemetry.description)
        }
    }
}

struct TelemetryConsensusViewNewSettings: View {
    @ObservedObject var consensus: TelemetryConsensus = .shared

    public var body: some View {
        VStack {
            HStack {
                Text("ResearchID".local())
                // TODO: localize ResearchID
                Spacer()
                TextField("ResearchID", text: $consensus.researchID)
                    .font(.body)
                    .multilineTextAlignment(.trailing) // Aligns text to the right
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .onSubmit {
                        consensus.saveResearchID()
                    }
            }
            .onDisappear {
                consensus.saveResearchID()
            }
            List {
                ForEach(Array(consensus.telemetries.enumerated()), id: \.element.id) { index, item in
                    TelemetryTypeConsensusView(index: index)
                }
            }
        }
    }
}
