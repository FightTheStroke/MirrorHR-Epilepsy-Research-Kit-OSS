//
//  NextReminderHomeView.swift
//
//
//  Created by Roberto D’Angelo on 25/09/23.
//

import Foundation
import SwiftUI
import SharedPkg

public struct NextReminderHomeView: View {
    @ObservedObject var medicationManager: MedicationManager = .shared
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("NextMedication".local())
                        .font(.title2).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
                Spacer()
                NavigationLink {
                    NextMedicationHomeView()
                        .modifier(MyRadialViewModifier(isList: true))
                } label: {
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(Color.accentColor)
            }
            
            
            if let nextReminder = medicationManager.medicationReminders.first {
                let nextReminderDate = medicationManager.getNextTriggerDateFor(nextReminder)
                Text(nextReminderDate?.toHomeString() ?? "RemindersNotSet".local())
                Divider()
                WeekMedicationView()
            } else {
                Text("RemindersNotSet".local())
            }
        }
    }
}

public struct NextMedicationHomeView: View {
    public var body: some View {
        Form {
            MedicationManagerView(showHeader: false, showTitle: false)
        }
        .navigationTitle(medicationAlarmViewTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    MedicationManager.shared.scheduleMedicationReminder()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                    }
                }
                
            }
        }
    }
}

public struct WeekMedicationView: View {
    @ObservedObject private var symptomsManager: SymptomsManager = .shared
    let medicationManager = MedicationManager.shared
    
    @State private var selectedDaysStatus: [MedicationManager.MedicationStatus?] = Array(repeating: .loading, count: 7)
    let daysOfWeek: [String] = {
        var symbols = Calendar.current.shortWeekdaySymbols
        let firstDayOfLocaleWeek = Calendar.current.firstWeekday
        let range = firstDayOfLocaleWeek..<firstDayOfLocaleWeek+7
        return range.map { symbols[($0 - 1) % 7] }
    }()
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("ThisWeekMedicationAtGlance".local())
                    .font(.title2).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                Spacer()
                NavigationLink {
                    NextMedicationHomeView()
                        .modifier(MyRadialViewModifier(isList: true))
                } label: {
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(Color.accentColor)
            }
            .padding(.bottom)
            
            
            HStack {
                Spacer()
                ForEach(0..<daysOfWeek.count, id: \.self) { index in
                    WeekDayButtonView(
                        day: daysOfWeek[index],
                        status: $selectedDaysStatus[index]
                    )
                    Spacer()
                }
            }
        }
        .onAppear {
            refresh()
        }
        .onChange(of: symptomsManager.symptomsData) { _ in
            refresh()
        }
    }
    
    func refresh() {
        Task {
            do {
                let statusArray = await medicationManager.medicationStatusForCurrentWeek()
                DispatchQueue.main.async {
                    self.selectedDaysStatus = statusArray
                }
            }
        }
    }
    
}



public struct WeekDayButtonView: View {
    let day: String
    @Binding var status: MedicationManager.MedicationStatus?
    
    var isToday: Bool {
        let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1
        let daySymbols = Calendar.current.shortWeekdaySymbols
        return day == daySymbols[todayIndex]
    }
    
    public var body: some View {
        VStack {
            if status == .loading {
                ProgressView()
            } else {
                Image(systemName: status != nil ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(colorForStatus())
            }
            Text(day)
                .font(.caption)
        }
        .cornerRadius(defaultCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
    
    func colorForStatus() -> Color {
        switch status {
        case .taken:
            return .green
        case .missed:
            return .red
        case .partial:
            return .yellow
        case .overdose:
            return .purple
        case .none, .loading:
            return .gray
        }
    }
}

