//
//  InsightsFiltersView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 24/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg

struct InsightsFiltersView: View {
    @ObservedObject var symptomsManager = SymptomsManager.shared
    @State private var showPicker: Bool = false
    var showingPickerFilters: [HandledSymptomsEvents] = [.byDate, .filter]
    var showChart: Bool
    
    var body: some View {
        VStack {
            HStack {
                ForEach(symptomsManager.chartFilters, id: \.self) { filter in
                    Spacer()
                    RadioButton(showPicker: $showPicker, filter: filter, showingPickerFilters: showingPickerFilters)
                        .padding(5)
                    Spacer()
                }
            }
            if showPicker {
                if symptomsManager.chartFilter == .byDate {
                    ShowFilterDatePickerView()
                } else {
                    ShowFilterSymptomPickerView()
                }
            }
            if showChart {
                InsightsCharts()
            }
        }
    }
}

struct RadioButton: View {
    @ObservedObject var symptomsManager = SymptomsManager.shared
    @Binding var showPicker: Bool
    @State private var isButtonSelected: Bool = false
    
    var filter: HandledSymptomsEvents
    var showingPickerFilters: [HandledSymptomsEvents]

    var body: some View {
        Button {
            symptomsManager.chartFilter = filter
            if showingPickerFilters.contains(symptomsManager.chartFilter) {
                showPicker.toggle()
            } else {
                showPicker = false
            }
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: filter.image)
            }
            .foregroundColor(filter == symptomsManager.chartFilter ? .accentColor : .secondary)
            .font(filter == symptomsManager.chartFilter ? .body.bold() : .body)
        }
    }
}

struct ShowFilterSymptomPickerView: View {
    @ObservedObject var symptomsManager = SymptomsManager.shared
    var body: some View {
        Picker("", selection: $symptomsManager.subChartFilter) {
            ForEach(HandledSymptomsEvents.allPossibleFilters, id: \.self) {
                Text($0.rawValue.local())
            }
        }
        .pickerStyle(WheelPickerStyle())
    }
}

struct ShowFilterDatePickerView: View {
    @ObservedObject var symptomsManager = SymptomsManager.shared
    @State private var dateFrom = SymptomsManager.shared.oldestSymptomDate().startOfDay
    @State private var dateTo = Date().endOfDay

    var body: some View {
        HStack {
            DatePicker(selection: $dateFrom, in: ...dateTo, displayedComponents: [.date]) {
                Text(fromString)
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
            Image(systemName: "arrow.right")
            Spacer()
            DatePicker(selection: $dateTo, in: dateFrom ... Date(), displayedComponents: [.date]) {
                Text(toString)
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
            Button {
                dateFrom = SymptomsManager.shared.oldestSymptomDate().startOfDay
                dateTo = Date().endOfDay
            } label: {
                Image(systemName: "paintbrush")
            }.padding(.horizontal)
        }
        .padding()
        .onChange(of: dateFrom, perform: { newValue in
            symptomsManager.filterByDataRange(from: newValue, to: dateTo)
        })
        .onChange(of: dateTo) { newValue in
            symptomsManager.filterByDataRange(from: dateFrom, to: newValue)
        }
        .onAppear {
            symptomsManager.filterByDataRange(from: dateFrom, to: dateTo)
        }
        .onDisappear {
            symptomsManager.filterByDataRange(from: dateFrom, to: dateTo)
        }
    }
}
