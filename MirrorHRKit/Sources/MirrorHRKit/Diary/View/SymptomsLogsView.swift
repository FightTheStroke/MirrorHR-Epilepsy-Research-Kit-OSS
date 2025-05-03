//
//  SymptomsLogsView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 14/02/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Combine
import MirrorHRTelemetryPackage
import SharedPkg
import SwiftUI

class NavigationController: ObservableObject {
    static var shared: NavigationController = NavigationController()
    @Published var isInSymptomsLogMainView: Bool = false
}

struct SymptomsLogsView: View {
    @ObservedObject private var navigationController: NavigationController =
        .shared
    @State var allPossibleSymptomsDictionary = HandledSymptomsEvents
        .allPossibleSymptomsDictionary
    let labelSymbol = "calendar.badge.clock"
    @State private var searchText = ""

    func sectionHeader(_ category: HandledSymptomsEvents.SymptomCategory)
        -> some View
    {
        Text(category.rawValue.local())
            .font(.headline).fontWeight(.bold)
    }

    var body: some View {
        NavigationView {
            VStack {
                symptomsList
                    .searchable(
                        text: $searchText,
                        prompt: "SymptomSearchBarSearchString".local()
                    )
                    .listStyle(.automatic)
                    .gesture(
                        DragGesture()
                            .onChanged({ _ in
                                UIApplication.shared.endEditing()
                            })
                    )
            }
            .modifier(MyRadialViewModifier(isList: true))
            .navigationTitle(logASymptomMsg4LogsView)
        }
    }

    var symptomsList: some View {
        List {
            if self.searchText.isEmpty {
                Section {
                    FastLogInDiary()
                    MoodTrackerView(showHeaderInView: true)
                }
            }
            ForEach(
                Array(allPossibleSymptomsDictionary.keys).sorted(by: {
                    $0.diaryOrder < $1.diaryOrder
                }), id: \.self
            ) { category in
                let filteredSymptomsForCategory = self.filteredSymptoms(
                    for: category)
                if !filteredSymptomsForCategory.isEmpty
                    || self.searchText.isEmpty
                {
                    Section(
                        header: Text(category.rawValue.local())
                            .font(.headline)
                            .bold()
                    ) {
                        ForEach(filteredSymptomsForCategory, id: \.id) {
                            quickLog in
                            SymptomsQuickLogAppendView(
                                quickLog: quickLog, symptom: quickLog.symptom)
                        }
                    }
                }
            }
        }
        .listStyle(.automatic)
    }

    func filteredSymptoms(for category: HandledSymptomsEvents.SymptomCategory)
        -> [SymptomLog]
    {
        // First, filter the symptoms based on the search text.
        let filteredSymptoms =
            allPossibleSymptomsDictionary[category]?.filter { handledSymptom in
                handledSymptom.symptom.localizedString().lowercased().contains(
                    searchText.lowercased()) || searchText.isEmpty
            } ?? []

        // Then, sort the filtered symptoms by their localized, lowercased string representation.
        let sortedFilteredSymptoms = filteredSymptoms.sorted {
            (symptomLog1, symptomLog2) -> Bool in
            return symptomLog1.symptom.localizedString().lowercased()
                < symptomLog2.symptom.localizedString().lowercased()
        }

        return sortedFilteredSymptoms
    }

    private func refresh() {
        if navigationController.isInSymptomsLogMainView {
            allPossibleSymptomsDictionary =
                HandledSymptomsEvents.allPossibleSymptomsDictionary
        }
    }
}
