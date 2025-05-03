//
//  TimeLineViewV9_70.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D'Angelo on 27/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg
import CoreData
import Combine

/// View model for symptom timeline visualization
/// - Manages symptom timeline data
/// - Handles timeline interactions
/// - Provides data formatting for display
/// - Implements ObservableObject for UI updates
class SymptomsTimeLineViewModel: ObservableObject {
    @Published var groupedSymptoms: [(key: Date, value: [SymptomsData])] = []
    
    init(filteredSymptoms: [SymptomsData]) {
        self.groupedSymptoms = self.groupSymptoms(symptoms: filteredSymptoms)
    }
    
    // Feb 26 2024 - grouping and sorting by endDate vs startDate
    private func groupSymptoms(symptoms: [SymptomsData]) -> [(key: Date, value: [SymptomsData])] {
        let noDate: Date = Date(timeIntervalSince1970: 0)
        // Raggruppamento dei sintomi per la data di inizio del giorno di endDate
        let grouped = Dictionary(grouping: symptoms) { $0.endDate?.startOfDay ?? noDate }
        
        // Ordinamento interno di ogni gruppo di sintomi per endDate in modo decrescente e successivo ordinamento dei gruppi per data
        let sortedGroups = grouped.mapValues { symptomsArray in
            symptomsArray.sorted { ($0.endDate ?? noDate) > ($1.endDate ?? noDate) }
        }.sorted { $0.key > $1.key }
        
        return sortedGroups
    }
    
}

struct SymptomsTimeLine: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SymptomsData.endDate, ascending: false)])
    var symptoms: FetchedResults<SymptomsData>
    
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var symptomsManager = SymptomsManager.shared
    @Environment(\.editMode) private var editMode
    
    // This will be a computed property now
    var viewModel: SymptomsTimeLineViewModel {
        SymptomsTimeLineViewModel(filteredSymptoms: symptomsManager.filteredSymptoms)
    }
    
    var body: some View {
        List {
            if symptomsManager.isSearching || symptomsManager.seizuresCount() > 0 {
                InsightsHeaderView()
            }
            InsightsCharts()
            ForEach(viewModel.groupedSymptoms, id: \.key) { date, symptomsLogs in
                Section(header: SectionHeaderView(date: date)) {
                    ForEach(symptomsLogs) { log in
                        SymptomRowView(log: log)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            symptomsManager.deleteSymptom(for: symptomsLogs[index])
                        }
                    }
                }
            }
        }
        .listStyle(.automatic)
    }
}

struct SectionHeaderView: View {
    let date: Date
    var body: some View {
        HStack {
            Text(date.sinceTodayString())
                .font(.headline).fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
            Spacer()
            if ProfileGenericSettings.shared.appleWatchEnabled {
                NavigationLink {
                    BPMOfTheWholeDayView(dateToShow: date)
                        .modifier(MyRadialViewModifier(isList: true))
                        .navigationBarTitle(date.dateHeader())
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Image(systemName: "heart.text.square").foregroundColor(.accentColor)
                }
            }
        }
    }
}

struct SymptomRowView: View {
    let log: SymptomsData
    var body: some View {
        VStack(alignment: .leading) {
            SymptomTimeLineRowHeader(symptom: log, showFullDate: false)
            SymptomTimeLineRow(symptom: log)
                .foregroundColor(.secondary)
        }
    }
}

struct BPMOfTheWholeDayView: View {
    var dateToShow: Date
    
    var body: some View {
        let fromDate: Date = dateToShow.startOfDay
        let toDate: Date = dateToShow.endOfDay
        VStack {
            Text("bPmLabelMsg".local()).font(.headline)
            Text("\(fromDate.toStdString()) - \(toDate.toStdString())")
            InsightsClass.shared.showFullDayBPM(fromDate: fromDate, toDate: toDate)
            Spacer()
        }
    }
}

struct SymptomTimeLineRowHeader: View {
    let symptomsManager = SymptomsManager.shared
    var symptom: SymptomsData
    let showFullDate: Bool
    @Environment(\.presentationMode) var presentationMode
    
    init(symptom: SymptomsData, showFullDate: Bool) {
        self.symptom = symptom
        self.showFullDate = showFullDate
        // Initialize the @State variable with default values
    }
    
    var body: some View {
        if let symptRawValue = symptom.symptom, let handledSymptom = HandledSymptomsEvents(rawValue: symptRawValue) {
            NavigationLink {
                SymptomNotesUpdateView(symptom: symptom)
                    .modifier(MyRadialViewModifier(isList: true))
            } label: {
                HStack(alignment: .top) {
                    if HandledSymptomsEvents.dailyMoods.contains(handledSymptom) {
                        HStack {
                            Text(handledSymptom.image)
                            Text("\(symptRawValue.local())")
                        }
                        .font(.body)
                    } else {
                        HStack {
                            Image(systemName: handledSymptom.image)
                                .foregroundColor(handledSymptom.symptomColor)
                                .frame(width: 30, height: 30) // Optional: Use a fixed frame size for uniformity
                                .scaledToFit()
                            Text("\(symptRawValue.local())")
                        }
                        .font(.body)
                    }
                    Spacer()
                    if let endDate = symptom.endDate {
                        if showFullDate {
                            Text("\(endDate.toShort())")
                                .font(.caption)
                                .padding(.horizontal)
                                .multilineTextAlignment(.trailing)
                        } else {
                            Text("\(endDate.returnHHmm())")
                                .font(.caption)
                                .padding(.horizontal)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
        } else {
            Text(errorMsg.uppercased()).font(.headline).fontWeight(.bold).foregroundColor(.red)
        }
    }
}

struct SymptomTimeLineRow: View {
    var symptom: SymptomsData
    
    var body: some View {
        HStack(alignment: .top) {
            if symptom.isVideo() {
                VideoLogRowView(symptom: symptom)
            } else {
                SymptomRowCoreInfo(symptom: symptom)
                Spacer()
            }
        }
    }
}

struct SymptomRowCoreInfo: View {
    var symptom: SymptomsData
    
    var body: some View {
        let startDate: Date = symptom.startDate ?? Date()
        let endDate: Date = symptom.endDate ?? Date()
        let notes = symptom.notes ?? defaultQuickLogNote
        
        VStack(alignment: .leading) {
            if symptom.isNotLenghtZero() {
                Text(fromString + "\(startDate.returnHHmm()) " + toString + "\(endDate.returnHHmm())")
                let Lenght = symptom.Lenght()
                Text(LenghtString + "\(Lenght.hour ?? 0)h \(Lenght.minute ?? 0)m \(Lenght.second ?? 0)s")
            }
            if notes != defaultQuickLogNote {
                Text(notes)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if symptom.isVideo() {
                VideoAugumentedMetaDataView(symptom: symptom)
            }
        }
    }
}
