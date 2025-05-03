//
//  SymptomUpdateViews.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 25/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg

struct SymptomNotesUpdateView: View {
    let symptom: SymptomsData
    let symptomsManager = SymptomsManager.shared
    @State private var notes: String
    @Environment(\.presentationMode) var presentationMode
    @State private var videoPlayerIsActive = false
    @State private var showingDeleteConfirmation = false // State to manage delete confirmation alert visibility
    
    init(symptom: SymptomsData) {
        self.symptom = symptom
        self._notes = State(initialValue: symptom.notes ?? "")
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    if symptom.isVideo() {
                        HStack {
                            showKeySymptInfo(symptom: symptom)
                                .font(.headline)
                            Spacer()
                            NavigationLink(destination: VideoPlayerView(symptom: symptom), isActive: $videoPlayerIsActive) {
                                EmptyView()
                            }
                            .hidden()
                            .frame(width: 0, height: 0)
                            
                            Button(action: {
                                self.videoPlayerIsActive = true
                            }) {
                                VideoLogRowView(symptom: symptom, showThumbnailOnly: true)
                            }
                        }
                    } else {
                        showKeySymptInfo(symptom: symptom)
                    }
                    
                    TextEditor(text: $notes)
                        .foregroundColor(Color.primary)
                        .frame(height: 150)
                        .keyboardType(.default)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary).opacity(0.5))
                        .gesture(DragGesture()
                            .onChanged({ _ in
                                UIApplication.shared.endEditing()
                            })
                        )
                }
            }
            
            Section(header:
                        Text("SameEventsMsg".local())
                            .font(.headline)
            ) {
                ForEach(symptomsManager.symptomsData.filter({ sympt in
                    sympt.symptom == symptom.symptom && sympt.id != symptom.id
                })) { relatedLog in
                    SymptomTimeLineRowHeader(symptom: relatedLog, showFullDate: true)
                }
            }
        }
        .listStyle(.automatic)
        .navigationTitle(symptom.symptom?.local() ?? "")
        .navigationBarTitleDisplayMode(.automatic)
        .modifier(MyRadialViewModifier(isList: true))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
//                    // Delete Btn
//                    Button {
//                        showingDeleteConfirmation = true // Show confirmation alert
//                    } label: {
//                        Image(systemName: "minus.circle.fill")
//                    }
                    
                    // Save Btn
                    Button {
                        DispatchQueue.main.async {
                            presentationMode.wrappedValue.dismiss()
                            symptomsManager.updateSymptom(which: symptom, withNotes: notes)
                        }
                    } label: {
                        Text(saveBtnMsg)
                    }
                }
            }
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text(confirmString),
                message: Text(""),
                primaryButton: .destructive(Text(yesString)) {
                    // Perform the delete action
                    DispatchQueue.main.async {
                        symptomsManager.deleteSymptom(for: symptom)
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

func printKeySymptInfo(for symptom: SymptomsData) -> some View {
    VStack (alignment: .leading) {
        let startDate = symptom.startDate ?? Date()
        let endDate = symptom.endDate ?? Date()
        let latitude = symptom.latitude
        let longitude = symptom.longitude
        HStack {
            if symptom.isNotLenghtZero() {
                Text(fromString + "\(startDate.toShort())")
                Text("")
                Text(toString + "\(endDate.toShort())")
                Text("")
                let Lenght = symptom.Lenght()
                Text(LenghtString + "\(Lenght.hour ?? 0)h \(Lenght.minute ?? 0)m \(Lenght.second ?? 0)s")
            } else {
                Text("\(startDate.toShort())")
            }
            if latitude != 0, longitude != 0 {
                Image(systemName: "location.circle")
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        openInMaps(latitude: latitude, longitude: longitude)
                    }
            }
        }
        
        
        
    }
}

func showKeySymptInfo(symptom: SymptomsData) -> some View {
    VStack(alignment: .leading) {
        let startDate = symptom.startDate ?? Date()
        let endDate = symptom.endDate ?? Date()
           
        // if it's realtimeSession and it has session stats let's draw the chart
        if let sympt = symptom.symptom,
            let event = HandledSymptomsEvents(rawValue: sympt),
            event == .realTimeSessionEnded,
            let jsonMetaData = symptom.jsonMetaData,
            let sessionStats: SessionStats = SessionStats.loadFromJson(jsonString: jsonMetaData) {
                HStack {
                    printKeySymptInfo(for: symptom)
                    Spacer()
                    SessionStatsView(sessionStats: sessionStats, chartOnly: true)

                }
        } else { // otherwise let's print the key info
            printKeySymptInfo(for: symptom)
        }
        
        // and if it's realtime session or seizure, let's draw the BPMs
        if let sympt = symptom.symptom,
           let event = HandledSymptomsEvents(rawValue: sympt),
           (event == .realTimeSessionEnded || event == .seizure) {
            InsightsClass.shared.showBPMSession(fromDate: startDate.addMins(number: -60), toDate: endDate.addMins(number: 60))
        }
    }
}
