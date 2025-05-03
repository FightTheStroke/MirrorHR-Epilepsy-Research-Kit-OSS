//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 23/10/23.
//

import Foundation
import SwiftUI

public struct MedicationInputView: View {
    @ObservedObject var viewModel: MedicationViewModel = MedicationViewModel()
    @State private var currentIndex: Int = 0
    @State private var next: Bool = false
    
    public init() {
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Text(sampleReminders[currentIndex])
            
            Button("Process") {
                viewModel.processPrompt(prompt: sampleReminders[currentIndex])
                next = false
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text("Error"), message: Text("Unable to process input. Please enter manually."), dismissButton: .default(Text("OK")))
            }
            
            if viewModel.showValidationView, !next {
                MedicationValidationView(viewModel: viewModel)
            } else {
                Text ("Thinking")
            }
            
            
            Button("Next Sample") {
                if currentIndex < sampleReminders.count - 1 {
                    currentIndex += 1
                    next = true
                }
            }
            
            Spacer()
        }
        .padding()
    }
}


public struct MedicationInputViewReal: View {
    @ObservedObject var viewModel: MedicationViewModel = MedicationViewModel()

    public init() {
        
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            TextField("Enter your medication schedule", text: $viewModel.userPrompt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 150)
                .autocorrectionDisabled()
                .padding()

            Button("Process") {
                viewModel.processPrompt(prompt: viewModel.userPrompt)
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text("Error"), message: Text("Unable to process input. Please enter manually."), dismissButton: .default(Text("OK")))
            }

            if viewModel.showValidationView {
                MedicationValidationView(viewModel: viewModel)
            }
            Spacer()
        }
        .padding()
    }
}

public struct MedicationValidationView: View {
    @ObservedObject var viewModel: MedicationViewModel

    public var body: some View {
        VStack(spacing: 16) {
            List(viewModel.medications) { med in
                VStack(alignment: .leading) {
                    Text(med.name).font(.headline)
                    Text("\(med.dose) pills")
                    ForEach(med.schedules, id: \.id) { schedule in
                        Text("\(schedule.days.map { $0.rawValue }.joined(separator: ", ")) at \(String(format: "%02d:%02d", schedule.time.hour, schedule.time.minute))")
                    }
                }
            }

            Button("Schedule Reminders") {
                viewModel.scheduleReminders()
            }
        }
    }
}
