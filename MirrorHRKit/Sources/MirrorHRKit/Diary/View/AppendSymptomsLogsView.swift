//
//  AppendSymptomsLogsView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 10/02/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg
import MirrorHRTelemetryPackage

struct SymptomsQuickLogAppendView: View {
    
    @State var quickLog: SymptomLog
    let symptom: HandledSymptomsEvents
    let navigationController: NavigationController = .shared
    @State var btnPressed: Bool = false
    @State var isInputingDetails: Bool = false
    
    var body: some View {
        VStack() {
            NavigationLink(
                destination:QuickLogDetailView(quickLog: quickLog, isInputingDetails: $isInputingDetails),
                isActive: $isInputingDetails
            ) {
                Image(systemName: btnPressed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(btnPressed ? .green : .primary)
                    .help(quickLog.savedStatus.toolTip)
                    .font(.headline)
                    .onTapGesture {
                        if !btnPressed {
                            quickSave()
                            withAnimation {
                                btnPressed = true
                            }
                            // Re-enable after 1 second to secure it saves properly
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    btnPressed = false
                                    quickLog = SymptomLog(symptom)
                                }
                            }
                        }
                  }
                HStack {
                    Image(systemName: quickLog.symptom.image)
                        .foregroundColor(quickLog.symptom.symptomColor)
                        .frame(width: 30, height: 30) // Optional: Use a fixed frame size for uniformity
                        .scaledToFit()
                    Text("\(quickLog.symptom.localizedString())".capitalizingFirstLetter())
                }
                .font(.body)
            }
            .disabled(btnPressed)
        }
        .onChange(of: isInputingDetails) { newValue in
            if !newValue {
                DispatchQueue.main.async {
                    navigationController.isInSymptomsLogMainView = true
                    self.btnPressed = quickLog.savedStatus != .unSaved
                    if self.btnPressed {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                btnPressed = false
                                quickLog = SymptomLog(symptom)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Save function
    func quickSave() {
        DispatchQueue.main.async {
            quickLog.startDate = Date()
            quickLog.saveLog(timeUnit: .seconds, symptomLenght: 0, notes: "")
        }
    }
}

struct QuickLogDetailView: View {
    @ObservedObject var quickLog: SymptomLog
    @Binding var isInputingDetails: Bool // Navigate back
    
    @ObservedObject private var confirmationDialog: ConfirmationsDialogManager = .shared
    @State private var symptomLenght: Int =  0
    @State private var timeUnit: TimeUnits = .minutes
    @State private var notes: String
    
    init(quickLog: SymptomLog, isInputingDetails: Binding<Bool>) {
        self._quickLog = ObservedObject(initialValue: quickLog)
        self._isInputingDetails = isInputingDetails
        self._notes = State(initialValue: quickLog.notes ?? defaultQuickLogNote)
    }
    
    public var body: some View {
        if quickLog.symptom == .medicationChange {
            TherapyEditView(showHeader: false)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: navigationBarLeadingItem)
        } else {
            Form {
                VStack(alignment: .leading) {
                    DatePicker("whenQuestion".local(), selection: $quickLog.startDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .onChange(of: quickLog.startDate) { _ in
                            changeSavedStatus(to: .unSaved)
                        }
                    if quickLog.symptom.hasLenght {
                        InputSymptomLenght(symptomLenght: $symptomLenght, timeUnit: $timeUnit)
                    }
                    
                    Text("notesString".local())
                        .font(.headline)
                    
                    TextEditor(text: $notes)
                        .foregroundColor(Color.primary)
                        .frame(height: 150)
                        .keyboardType(.default)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary).opacity(0.5))
                        .onChange(of: notes) { newValue in
                            changeSavedStatus(to: .unSaved)
                        }
                }
                .onChange(of: symptomLenght) { _ in
                    changeSavedStatus(to: .unSaved)
                }
            }
            .onAppear(perform: {
                quickLog.startDate = Date()
            })
            .navigationBarTitle("\(quickLog.symptom.localizedString())")
            .modifier(MyRadialViewModifier(isList: true))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        btnAction(for: .update)
                    } label: {
                        Text(quickLog.savedStatus != .unSaved ? "savedBtnMsg".local() : saveBtnMsg)
                            .foregroundColor(quickLog.savedStatus != .unSaved ? .green : .accentColor)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: navigationBarLeadingItem)
        }
    }
    
    var navigationBarLeadingItem: some View {
        Button(action: {
            if quickLog.savedStatus == .unSaved {
                btnAction(for: .confirm)
            } else {
                btnAction(for: .cancel)
            }
        })
        {
            HStack {
                Image(systemName: "chevron.left")
                Text("logASymptomMsg4LogsView".local())
            }
        }
    }
    
    private func changeSavedStatus(to newStatus: SymptomLog.SavedStatus) {
        DispatchQueue.main.async {
            if quickLog.savedStatus != newStatus {
                self.quickLog.savedStatus = newStatus
            }
        }
    }
    
    private func btnAction(for action: BtnAction) {
        switch action {
        case .save:
            DispatchQueue.main.async {
                self.quickLog.saveLog(timeUnit: timeUnit, symptomLenght: symptomLenght, notes: notes)
                self.confirmationDialog.dismiss()
                self.isInputingDetails = false
            }
        case .update:
            DispatchQueue.main.async {
                self.quickLog.savedStatus = .updating
                self.quickLog.saveLog(timeUnit: timeUnit, symptomLenght: symptomLenght, notes: notes)
                self.isInputingDetails = false
            }
        case .dontSave:
            DispatchQueue.main.async {
                self.confirmationDialog.dismiss()
                self.isInputingDetails = false
            }
        case .cancel:
            DispatchQueue.main.async {
                self.isInputingDetails = false
            }
        case .confirm:
            confirmationDialog.show(
                title: "AlertConfirmMsgText",
                message: "therapyAlertYesNoSaveMsg",
                actions: AnyView(
                    VStack {
                        Button(yesString, action: {btnAction(for: .save)})
                        Button(noString, role: .destructive) { btnAction(for: .dontSave) }
                    }
                )
            )
        }
    }
    
    enum BtnAction {
        case save
        case dontSave
        case cancel
        case confirm
        case update
    }
}

struct InputSymptomLenght: View {
    @Binding var symptomLenght: Int
    @Binding var timeUnit: TimeUnits
    @State var isEditing: Bool = false
    
    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
    
    var body: some View {
        HStack {
            Text(LenghtString.local())
            TextField("", value: $symptomLenght, formatter: numberFormatter, onEditingChanged: { (editingChanged) in
                if editingChanged {
                    isEditing = true
                }
            })
            .font(isEditing ? .body : .body.bold())
            .foregroundColor(isEditing ? .primary : .accentColor)
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
            .textFieldStyle(.roundedBorder)
            .onTapGesture(perform: UIApplication.shared.endEditing)
            
            Text(timeUnit.rawValue.local())
            Menu {
                buildMenu()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.body.bold())
            }
            
            if isEditing {
                Button {
                    UIApplication.shared.endEditing()
                    isEditing = false
                } label: {
                    Image(systemName: "checkmark.circle")
                        .font(.body.bold())
                }
            }
        }
    }
    
    func buildMenu() -> some View {
        VStack {
            ForEach(TimeUnits.allCases, id: \.self) { unit in
                Button(action: {
                    self.timeUnit = unit
                }, label: {
                    Text(unit.rawValue.local())
                })
            }
            ForEach(lenghtSecondsLogOptions, id: \.self) { value in
                Button(action: {
                    self.timeUnit = .seconds
                    self.symptomLenght = value
                }, label: {
                    Text("\(value)" + "secondsIndicatorString".local())
                })
            }
            ForEach(lenghtMinutesLogsOptions, id: \.self) { value in
                Button(action: {
                    self.timeUnit = .minutes
                    self.symptomLenght = value
                }, label: {
                    Text("\(value)" + "minutesIndicatorString".local())
                })
            }
            
        }
    }
}
