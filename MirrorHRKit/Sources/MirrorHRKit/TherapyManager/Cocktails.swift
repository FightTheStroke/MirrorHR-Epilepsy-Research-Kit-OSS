//
//  Cocktails.swift
//
//
//  Created by Roberto D’Angelo on 30/04/22.
//

import Foundation
import SwiftUI
import SharedPkg
import Combine

@available(iOS 15, *)
public struct CocktailsMainView: View {
    @Binding var cocktails: [Cocktail]
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject private var therapyManager: TherapyManager = .shared
    private var showMenuPicker: Bool {
        !therapyManager.cocktails.isEmpty && cocktails != therapyManager.cocktails
    }
    
    public var body: some View {
        Section(header: cocktailSectionHeader()) {
            List {
                ForEach(cocktails, id: \.id) { cocktail in
                    RowSelectCocktailView(cocktail: cocktail)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        cocktails.remove(at: index)
                    }
                }
            }
        }
    }
    
    func cocktailSectionHeader() -> some View {
        HStack {
            Text(cocktailSectionTitle).foregroundColor(cocktails.isEmpty ? .red : .primary)
            Spacer()
            NavigationLink(destination: InsertRoutinesView(cocktails: $cocktails, navigationTitle: newCocktailString, backBtnTitle: navigationBackDefaultText)                    .modifier(MyRadialViewModifier(isList: true)), label: {
                Image(systemName: "plus.circle")
            }).isDetailLink(false)
            
            if showMenuPicker {
                Menu {
                    buildMenu()
                } label: {
                    Image(systemName: chevronDown)
                }
            }
        }
        .font(.body.bold())
    }
    
    func buildMenu() -> some View {
        ForEach(therapyManager.cocktails.unique()) {cocktail in
            if !cocktails.contains(cocktail) {
                Button(action: {
                    DispatchQueue.main.async {
//                        let newCocktail: Cocktail = cocktail
//                        newCocktail.id = UUID()
//                        cocktails.append(newCocktail)
                        cocktails.append(cocktail)
                    }
                }, label: {
                    Text(cocktail.name ?? noCocktailNameText)
                })
            }
        }
    }
}

@available(iOS 15, *)
public struct RowSelectCocktailView: View {
    var cocktail: Cocktail
    @ObservedObject var medicationManager = MedicationManager.shared
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(cocktail.name ?? noCocktailNameText).font(.body.bold())
                
                ForEach(cocktail.dosesList) { dose in
                    HStack {
                        Text(dose.drug?.name ?? noDrugNameText)
                        Spacer()
                        Text(String(format: "%.2f", dose.quantity))
                        Text(dose.drug?.unit ?? noDrugUnitText)
//                      Text(String(format: "%.2f", dose.shapes))
                    }
                }
            }
            Spacer()
        }
    }
}

public struct RowCocktailView: View {
    var cocktail: Cocktail
    @State private var checked: Bool = false
    @ObservedObject var medicationManager = MedicationManager.shared

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(cocktail.name?.capitalizingFirstLetter() ?? noCocktailNameText)
                    .font(.body.bold())
                Spacer()
            }
            ForEach(cocktail.dosesList) { dose in
                if let drug = dose.drug {
                    HStack(alignment: .top) {
                        Text(drug.name ?? noDrugNameText)
                        Spacer()
                        Text(String(format: "%.2f", dose.quantity) + "\(drug.unit ?? "")")
                        if let shape = DrugShape.valueFrom(description: drug.shape ?? "noshape"), let shapeImg = shape.image {
                            Image(systemName: shapeImg)
                        }
                    }
                }
            }
            Text("")
        }
    }
}

@available(iOS 15, *)
public struct InsertRoutinesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var therapyManager: TherapyManager = .shared

    @Binding var cocktails: [Cocktail]
    let navigationTitle: String
    let backBtnTitle: String
    
    @State private var inputName: String = sampleRoutineNameText
    @State private var inputReminder: Date = Date()
    @State private var inputNotes: String = ""
    @State private var doses: [Dose] = []
    @State private var saveEnabled: Bool = false
    @State private var enableReminder: Bool = false
   
    func save() {
        if enableReminder {
            therapyManager.insertCocktail(name: inputName, doses: doses, reminder: inputReminder, notes: inputNotes) {newCocktail in
                cocktails.append(newCocktail)
            }
        } else {
            therapyManager.insertCocktail(name: inputName, doses: doses, reminder: nil, notes: inputNotes) {newCocktail in
                cocktails.append(newCocktail)
            }
        }
    }
    
    func checkIsSaveEnabled() {
        if inputName.isEmpty || doses.isEmpty {
            DispatchQueue.main.async {
                saveEnabled = false
            }
        } else {
            DispatchQueue.main.async {
                saveEnabled = true
            }
        }
    }
    
    public var body: some View {
        VStack {
            Form {
                MyTextField(fieldName: "Name:", bindingString: $inputName, isMandatory: true)
                if remindersImplemented {
                    Toggle(enableReminderString, isOn: $enableReminder)
                }
                if enableReminder {
                    HStack {
                        DatePicker(selection: $inputReminder, displayedComponents: [.hourAndMinute]) {
                            Text(reminderAtString)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Spacer()
                    }
                }
                MyTextField(fieldName: "Note:", bindingString: $inputNotes, isMandatory: false)
                DosesMainView(doses: $doses)
            }
            .modifier(TherapyToolbarSaveViewModifier(navigationTitle: navigationTitle,
                                                     backBtnTitle: backBtnTitle,
                                                     saveAction: save,
                                                    saveEnabled: $saveEnabled))
        }
        .onChange(of: inputName) { _ in
            checkIsSaveEnabled()
        }
        .onChange(of: doses) { _ in
            checkIsSaveEnabled()
        }
    }
}

public struct UpdateRoutinesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var therapyManager: TherapyManager = .shared

    private var cocktail: Cocktail
    let navigationTitle: String
    let backBtnTitle: String

    @State private var inputName: String = sampleRoutineNameText
    @State private var inputReminder: Date = Date()
    @State private var inputNotes: String = ""
    @State private var doses: [Dose] = []
    @State private var saveEnabled: Bool = false
    @State private var enableReminder: Bool = false
    
    init(_ cocktail: Cocktail, navigationTitle: String, backBtnTitle: String = navigationBackDefaultText) {
        self.cocktail = cocktail
        _inputName = State(initialValue: cocktail.name ?? "")
        _inputReminder = State(initialValue: cocktail.reminder ?? Date())
        _inputNotes = State(initialValue: cocktail.note ?? "")
        _doses = State(initialValue: cocktail.dosesList)
        self.navigationTitle = navigationTitle
        self.backBtnTitle = backBtnTitle
    }
   
    func save() {
        therapyManager.updateCocktail(cocktail: cocktail, newName: inputName,
                                      doses: doses,
                                      reminder: inputReminder,
                                      notes: inputNotes
                                    )
    }
    
    public var body: some View {
        VStack {
            Form {
                MyTextField(fieldName: "Name:", bindingString: $inputName, isMandatory: true)
                if remindersImplemented {
                    Toggle(enableReminderString, isOn: $enableReminder)
                }
                if enableReminder {
                    HStack {
                        DatePicker(selection: $inputReminder, displayedComponents: [.hourAndMinute]) {
                            Text(reminderAtString)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Spacer()
                    }
                }
                MyTextField(fieldName: "Note:", bindingString: $inputNotes, isMandatory: false)
                DosesMainView(doses: $doses)
            }
            .modifier(TherapyToolbarSaveViewModifier(navigationTitle: navigationTitle,
                                                     backBtnTitle: backBtnTitle,
                                                     saveAction: save,
                                                    saveEnabled: $saveEnabled))
        }
        .onChange(of: inputName) { newValue in
            if newValue.isEmpty {
                self.saveEnabled = false
            } else {
                self.saveEnabled = true
            }
        }
        .onChange(of: doses) { newValue in
            if newValue.isEmpty {
                self.saveEnabled = false
            } else {
                self.saveEnabled = true
            }
        }
    }
}
