//
//  SymptomsTimeLineView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 08/02/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg
import MessageUI
import UniformTypeIdentifiers

struct InsightsCoreDataMainView: View {
    @Environment(\.editMode) private var editMode
    private let symptomsManager = SymptomsManager.shared
    @ObservedObject private var importExportViewModel = ImportExportViewModel.shared
    @ObservedObject private var blockingActionInProgressModel = BlockingActionInProgressModel.shared
    @State private var filterSeizuresOnly: Bool = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            SymptomsTimeLine()
                .modifier(MyRadialViewModifier(isList: true))
                .navigationBarTitleDisplayMode(.automatic)
                .navigationBarTitle(Tab.insights.title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                            .foregroundColor(.accentColor)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        myToolbarView
                            .foregroundColor(.accentColor)
                    }
                }
                .alert(confirmString, isPresented: $importExportViewModel.isShowingAlert, actions: {
                    importExportViewModel.myAlert.actions
                }, message: {
                    importExportViewModel.myAlert.message
                })
                .sheet(isPresented: $importExportViewModel.isShowingMailView) {
                    SendEmailToDocSheetView(isShowingMailView: $importExportViewModel.isShowingMailView, attachmentPath: importExportViewModel.attachmentPath, lastDays: importExportViewModel.howManyLastDays)
                }
                .fileImporter(
                    // if user cancel the window, isFileImporterShowing is false, but it's not importing!
                    isPresented: $importExportViewModel.isFileImporterShowing,
                    allowedContentTypes: [UTType.plainText],
                    allowsMultipleSelection: false
                ) { result in
                    importFunction(result)
                }
                .refreshable {
                    symptomsManager.fetch()
                }
                .searchable(text: $searchText)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onSubmit(of: .search) {
                    symptomsManager.filterBySearchText(by: searchText)
                }
                .onChange(of: searchText) { newValue in
                    if newValue.isEmpty {
                        symptomsManager.filterBySearchText(by: "")
                    }
                }
        }
    }
    
    var myToolbarView: some View {
        HStack {
            Button {
                withAnimation {
                    filterSeizuresOnly.toggle()
                    symptomsManager.filterSeizuresOnly(reset: filterSeizuresOnly ? false : true)
                }
            } label: {
                Image(systemName: HandledSymptomsEvents.seizure.image)
                    .foregroundColor(filterSeizuresOnly ? .green : .accentColor)
            }
            
            Menu {
                importExportViewModel.menuView
            } label: {
                if blockingActionInProgressModel.blockingActionIsInProgress {
                    ProgressView()
                } else {
                    Image(systemName: "square.and.arrow.up.circle")
                }
            }
            .disabled(importExportViewModel.status != .isNotActive)
            
            NavigationLink {
                InsightsLegendaView()
                    .modifier(MyRadialViewModifier(isList: true))
                
            } label: {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(Color.accentColor)
            }
        }
    }
    
    fileprivate func importFunction(_ result: Result<[URL], Error>) {
        switch result {
        case .success:
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                // trying to get access to url contents
                if CFURLStartAccessingSecurityScopedResource(selectedFile as CFURL) {
                    guard let csvContent = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                    // done accessing the url
                    CFURLStopAccessingSecurityScopedResource(selectedFile as CFURL)
                    importExportViewModel.restoreSymptoms(csvContent)
                } else {
                    mainDebugger.append("Permission error! in importing CSV")
                    DispatchQueue.main.async {
                        importExportViewModel.status = .error(description: "CanTReadTheCSVFileLocalized".local())
                    }
                }
            } catch {
                // Handle failure.
                mainDebugger.append(error.localizedDescription)
                DispatchQueue.main.async {
                    importExportViewModel.status = .error(description: error.localizedDescription)
                }
            }
        case .failure(let error):
            // Handle failure.
            mainDebugger.append(error.localizedDescription)
            DispatchQueue.main.async {
                importExportViewModel.status = .error(description: error.localizedDescription)
            }
        }
    }
}

struct InsightsCharts: View {
    @ObservedObject var symptomsManager = SymptomsManager.shared
    @State private var chartPerspective: Int = 0
    var symptomFilter: String?
    
    private var statsDictionary: [ChartSupportStruct] {
        switch chartPerspective {
        case 0:
            return symptomsManager.returnLast4WeeksStatsByWeek(for: symptomFilter)
        case 1:
            return symptomsManager.returnStatsByLast12Month(for: symptomFilter)
        case 2:
            return symptomsManager.returnStatsByWeekDay(for: symptomFilter)
        default:
            return []
        }
    }
    
    var body: some View {
        VStack {
            Picker(selection: $chartPerspective, label: Text("")) {
                Text("lastWeeksString".local()).tag(0).font(.caption)
                Text("lastMonthsString".local()).tag(1).font(.caption)
                Text("weekdaysString".local()).tag(2).font(.caption)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Group {
                if #available(iOS 16.0, *) {
                    CoreDataStatsChartV2(statsDictionary: statsDictionary, frameMaxHeight: 100)
                } else {
                    CoreDataStatsChart(statsDictionary: statsDictionary, frameMaxHeight: 100)
                        .frame(height: 100)
                }
            }
        }
    }
}


struct InsightsHeaderView: View {
    @ObservedObject var symptomsManager = SymptomsManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !symptomsManager.isSearching {
                let seizuresCount = symptomsManager.seizuresCount()
                if seizuresCount > 0 {
                    SinceLastSeizureView()
                }
            } else {
                let symptomsCount = symptomsManager.filteredSymptoms.count
                Text("\(symptomsCount) '\(symptomsManager.searchText)'")
                    .font(.title)
                if symptomsCount > 0 {
                    Text("\(symptomsManager.sinceLastEvent())").font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .multilineTextAlignment(.leading)
    }
}

struct InsightsRecapAndSharingView: View {
    @ObservedObject private var symptomsManager: SymptomsManager = .shared
    
    var body: some View {
        HStack {
            Spacer()
            let symptomsCount = symptomsManager.symptomsData.count
            Text("\(symptomsCount) \(logsSoFarMsg)").font(.callout)
            Spacer()
        }
    }
}

struct QueryBPMInProgressView: View {
    @ObservedObject private var healthKitTools = HealthKitTools.shared
    
    var body: some View {
        if healthKitTools.queryBPMInProgress {
            ProgressView(analyzingDataMsg)
                .scaleEffect(2, anchor: .center)
                .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                .foregroundColor(.primary)
        } else {
            EmptyView()
        }
    }
}

struct InsightsLegendaView: View {
    var body: some View {
        VStack(alignment: .leading) {
            InsightsFiltersLegendaView()
            Divider()
            InsightsSymptomsLegendaView()
            Divider()
            Text(insightClassInfoString).font(.headline)
            Divider()
            SymptomsManager.ImportView()
            Spacer()
        }
        .padding()
        .navigationTitle(legendaLabelMsg)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InsightsFiltersLegendaView: View {
    let chartFilters = SymptomsManager.shared.chartFilters
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(chartFilters, id: \.self) { chartFilter in
                HStack(alignment: .top) {
                    Image(systemName: chartFilter.image)
                    Text(chartFilter.localizedString())
                }
            }
        }
    }
}

struct InsightsSymptomsLegendaView: View {
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(HandledSymptomsEvents.SymptomCategory.allCases, id: \.self) { category in
                HStack(alignment: .top) {
                    Image(systemName: "rectangle.fill")
                        .foregroundColor(category.categoryColor)
                    Text(NSLocalizedString(category.rawValue, comment: ""))
                }
            }
        }
    }
}
