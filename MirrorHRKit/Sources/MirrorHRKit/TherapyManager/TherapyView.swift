//
//  File.swift
//
//
//  Created by Roberto D’Angelo on 26/04/22.
//

import Foundation
import SwiftUI
import SharedPkg
import CoreData
import Combine

@available(iOS 15, *)
public struct TherapyMainView: View {
    @ObservedObject var therapyManager: TherapyManager = .shared
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(therapyManager.therapies, id: \.id) { therapy in
                    RowTherapyView(therapy: therapy)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        therapyManager.deleteTherapy(therapyManager.therapies[index])
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: InsertUpdateTherapyView(navigationTitle: newTherapyString, backBtnTitle: navigationBackDefaultText)                    .modifier(MyRadialViewModifier(isList: true))
, label: {
                        Image(systemName: "plus.circle").foregroundColor(.accentColor)
                    })
                    .isDetailLink(false)
                    .foregroundColor(.accentColor)
                }
                ToolbarItem(placement: .principal) {
                    Text(therapiesNavTitle).font(.body.bold())
                        .font(.title)
                    
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .foregroundColor(.accentColor)
                }
            }
        }
        .alert(isPresented: $therapyManager.showYesNoAlert) {
            Alert(
                title: Text(confirmString),
                message: Text(therapyManager.alertYesNoMsg),
                primaryButton: .default(Text(yesString), action: therapyManager.alertYesAction),
                secondaryButton: .destructive(Text(noString), action: therapyManager.alertNoAction)
            )
        }
    }
}

@available(iOS 15, *)
public struct RowTherapyView: View {
    @ObservedObject var therapyManager: TherapyManager = .shared
    let therapy: Therapy
    @State var showDateExtender: Bool = false
    @State var currentTherapyEndDate: Date = TherapyManager.shared.currentTherapy?.endDate ?? Date()
    @State var currentTherapyStartDate: Date = TherapyManager.shared.currentTherapy?.startDate ?? Date()
    
    public var body: some View {
        let currentTherapy: Therapy? = therapyManager.currentTherapy
        let isCurrentTherapy: Bool = therapy == therapyManager.currentTherapy
        
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text(therapy.name?.uppercased() ?? noTherapyNameString)
                    Spacer()
                }
                .font(isCurrentTherapy ? .headline.bold() : .headline)
                .multilineTextAlignment(.center)
                
                HStack {
                    Text(therapy.validityDateInterval)
                    Spacer()
                    if isCurrentTherapy {
                        Button {
                            showDateExtender.toggle()
                        } label: {
                            Image(systemName: "calendar.badge.plus")
                        }
                    }
                }
                Text("")
                
                ForEach(Array(therapy.cocktailList.enumerated()), id: \.element) { index, cocktail in
                    HStack(alignment: .top) {
                        Image(systemName: String(index + 1) + ".circle")
                        RowCocktailView(cocktail: cocktail)
                    }
                    
                }
            }.padding(.top, 5)
            Spacer()
        }
        .foregroundColor(isCurrentTherapy ? stefiPurple : .primary)
        
        .sheet(isPresented: $showDateExtender) {
            VStack {
                HStack {
                    DatePicker(selection: $currentTherapyStartDate, displayedComponents: [.date]) {
                        Text(toString)
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Spacer()
                    Text ("-->")
                        .font(.headline)
                    Spacer()
                    
                    DatePicker(selection: $currentTherapyEndDate, displayedComponents: [.date]) {
                        Text(toString)
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                }
                Spacer()
                HStack {
                    Button("BtnCancelMsg".local(), role: .cancel) {
                        showDateExtender = false
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Spacer()
                    Button(saveBtnMsg) {
                        if let currentTherapy = currentTherapy {
                            therapyManager.updateTherapy(therapy: currentTherapy, newName: currentTherapy.name ?? "New Therapy", newStartDate: currentTherapyStartDate, newEndDate: currentTherapyEndDate, newCocktails: currentTherapy.cocktailList)
                        }
                        showDateExtender = false
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                }
                Spacer()
            }
            .padding()
            .presentationDetents([.height(250)])
        }
    }
}

@available(iOS 15, macOS 12, watchOS 8, *)
public struct InsertUpdateTherapyView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var therapyManager: TherapyManager = .shared
    
    let navigationTitle: String
    let backBtnTitle: String
    @State private var inputName: String = "Therapy" + Date().toDayMonthYear()
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addDay(number: 90)
    @State private var cocktails: [Cocktail] = []
    @State private var saveEnabled: Bool = false
    
    private var therapy: Therapy?
    
    init(therapy: Therapy? = nil, navigationTitle: String, backBtnTitle: String = navigationBackDefaultText) {
        if let therapy = therapy {
            self.therapy = therapy
            _inputName = State(initialValue: therapy.name ?? "")
            _startDate = State(initialValue: therapy.startDate ?? Date())
            _endDate = State(initialValue: therapy.endDate ?? Date().addDay(number: 90))
            _cocktails = State(initialValue: therapy.cocktailList)
        }
        self.navigationTitle = navigationTitle
        self.backBtnTitle = backBtnTitle
    }
    
    func save() {
        if let therapy = therapy {
            therapyManager.updateTherapy(therapy: therapy, newName: inputName, newStartDate: startDate, newEndDate: endDate, newCocktails: cocktails)
        } else {
            therapyManager.insertTherapy(name: inputName, startDate: startDate, endDate: endDate, cocktails: cocktails)
        }
    }
    
    public var body: some View {
        VStack {
            Form {
                MyTextField(fieldName: "Name:", bindingString: $inputName, isMandatory: true)
                HStack {
                    DatePicker(selection: $startDate, displayedComponents: [.date]) {
                        Text(fromString)
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                    Spacer()
                    Image(systemName: "arrow.right")
                    Spacer()
                    DatePicker(selection: $endDate, in: startDate ... Date().addDay(number: 3650), displayedComponents: [.date]) {
                        Text(toString)
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                }
                CocktailsMainView(cocktails: $cocktails)
            }
            .modifier(TherapyToolbarSaveViewModifier(navigationTitle: navigationTitle,
                                                     backBtnTitle: backBtnTitle,
                                                     saveAction: save,
                                                     saveEnabled: $saveEnabled))
        }
        .onChange(of: inputName) { _ in
            checkIsSaveEnabled()
        }
        .onChange(of: cocktails) { _ in
            checkIsSaveEnabled()
        }
    }
    
    func checkIsSaveEnabled() {
        if inputName.isEmpty || cocktails.isEmpty {
            DispatchQueue.main.async {
                saveEnabled = false
            }
        } else {
            DispatchQueue.main.async {
                saveEnabled = true
            }
        }
    }
}

public struct TherapyCurrentView: View {
    @ObservedObject var therapyManager: TherapyManager = .shared
    @Environment(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some View {
        VStack {
            if let currentTherapy = therapyManager.currentTherapy {
                RowTherapyView(therapy: currentTherapy)
            } else {
                Text(noCurrentTherapyText)
            }
        }
    }
}
