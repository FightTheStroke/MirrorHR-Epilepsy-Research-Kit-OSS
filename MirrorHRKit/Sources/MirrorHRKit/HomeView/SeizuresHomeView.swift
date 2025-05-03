//
//  SeizuresHomeView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 01/10/23.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Charts
import Foundation
import MessageUI
import SharedPkg
import SwiftUI
import UniformTypeIdentifiers

struct SeizuresHomeView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var symptomsManager = SymptomsManager.shared
    @ObservedObject private var importExportViewModel = ImportExportViewModel
        .shared
    @ObservedObject private var blockingActionInProgressModel =
    BlockingActionInProgressModel.shared
    @State private var showChart: Bool = false
    @State private var filterSeizuresOnly: Bool = true
    
    var body: some View {
        SeizuresHomeTimeLine()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    myToolbarView
                }
            }
            .alert(
                confirmString,
                isPresented: $importExportViewModel.isShowingAlert,
                actions: {
                    importExportViewModel.myAlert.actions
                },
                message: {
                    importExportViewModel.myAlert.message
                }
            )
            .sheet(isPresented: $importExportViewModel.isShowingMailView) {
                SendEmailToDocSheetView(
                    isShowingMailView: $importExportViewModel.isShowingMailView,
                    attachmentPath: importExportViewModel.attachmentPath,
                    lastDays: importExportViewModel.howManyLastDays)
            }
            .fileImporter(
                // if user cancel the window, isFileImporterShowing is false, but it's not importing!
                isPresented: $importExportViewModel.isFileImporterShowing,
                allowedContentTypes: [UTType.plainText],
                allowsMultipleSelection: false
            ) { result in
                importFunction(result)
            }
    }
    
    var myToolbarView: some View {
        HStack(alignment: .center) {
            EditButton()
            Section {
                Menu {
                    importExportViewModel.menuViewHome
                } label: {
                    if blockingActionInProgressModel.blockingActionIsInProgress
                    {
                        ProgressView()
                    } else {
                        Image(systemName: "square.and.arrow.up.circle")
                    }
                }
                .disabled(importExportViewModel.status != .isNotActive)
            }
        }
    }
    
    fileprivate func importFunction(_ result: Result<[URL], Error>) {
        switch result {
        case .success:
            do {
                guard let selectedFile: URL = try result.get().first else {
                    return
                }
                // trying to get access to url contents
                if CFURLStartAccessingSecurityScopedResource(
                    selectedFile as CFURL)
                {
                    guard
                        let csvContent = String(
                            data: try Data(contentsOf: selectedFile),
                            encoding: .utf8)
                    else { return }
                    // done accessing the url
                    CFURLStopAccessingSecurityScopedResource(
                        selectedFile as CFURL)
                    importExportViewModel.restoreSymptoms(csvContent)
                } else {
                    mainDebugger.append("Permission error! in importing CSV")
                    DispatchQueue.main.async {
                        importExportViewModel.status = .error(
                            description: "CanTReadTheCSVFileLocalized".local())
                    }
                }
            } catch {
                // Handle failure.
                mainDebugger.append(error.localizedDescription)
                DispatchQueue.main.async {
                    importExportViewModel.status = .error(
                        description: error.localizedDescription)
                }
            }
        case .failure(let error):
            // Handle failure.
            mainDebugger.append(error.localizedDescription)
            DispatchQueue.main.async {
                importExportViewModel.status = .error(
                    description: error.localizedDescription)
            }
        }
    }
}

struct SeizuresHomeTimeLine: View {
    @ObservedObject var symptomsManager = SymptomsManager.shared
    @Environment(\.editMode) private var editMode
    
    var filteredLogs: [Date: [SymptomsData]] {
        let nonNilDates = symptomsManager.symptomsData.filter {
            $0.startDate != nil
        }
        let nonDefaultDates = nonNilDates.filter {
            $0.startDate != Date(timeIntervalSince1970: 0)
        }
        
        return Dictionary(
            grouping: nonDefaultDates, by: { $0.startDate!.startOfDay }
        ).compactMapValues { (symptomsLog) -> [SymptomsData]? in
            let filteredSymptoms = symptomsLog.filter { symptom in
                symptom.symptom == HandledSymptomsEvents.seizure.rawValue
                || symptom.symptom
                == HandledSymptomsEvents.videoSeizureLog.rawValue
            }
            return filteredSymptoms.isEmpty ? nil : filteredSymptoms
        }
    }
    
    var body: some View {
        List {
            SinceLastSeizureView()
            InsightsCharts(
                symptomFilter: HandledSymptomsEvents.seizure.rawValue)
            
            ForEach(
                filteredLogs
                    .sorted(by: { $0.key > $1.key }),
                id: \.key
            ) { date, symptomsLogs in
                Section(
                    header: HStack {
                        Text(date.sinceTodayString()).font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                        Spacer()
                        if ProfileGenericSettings.shared.appleWatchEnabled {
                            NavigationLink {
                                BPMOfTheWholeDayView(dateToShow: date)
                                    .modifier(
                                        MyRadialViewModifier(isList: true)
                                    )
                                    .navigationBarTitle(date.dateHeader())
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                Image(systemName: "heart.text.square")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                ) {
                    ForEach(
                        symptomsLogs.sorted(by: {
                            ($0.startDate ?? .distantPast)
                            > ($1.startDate ?? .distantPast)
                        })
                    ) { log in
                        VStack(alignment: .leading) {
                            SymptomTimeLineRowHeader(
                                symptom: log, showFullDate: false)
                            SymptomTimeLineRow(symptom: log)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let symptomToDelete = symptomsLogs[index]
                            symptomsManager.deleteSymptom(for: symptomToDelete)
                        }
                    }
                }
            }
        }
        .listStyle(.automatic)
        .modifier(MyRadialViewModifier(isList: true))
    }
}
