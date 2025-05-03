//
//  TherapyDBEditViews.swift
//  
//
//  Created by Roberto D’Angelo on 15/05/22.
//

import Foundation
import SwiftUI
import SharedPkg

public struct TherapyDBEditView: View {
    @ObservedObject var therapyManager: TherapyManager = .shared
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert: Bool = false
    @State private var showConfirmDelete: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack {
            List {
                NavigationLink {
                    TherapyEditView(showHeader: false)
                        .modifier(MyRadialViewModifier(isList: true))
                } label: {
                    Text(therapiesNavTitle)
                }
                NavigationLink {
                    TherapyRoutinesEditView()
                        .modifier(MyRadialViewModifier(isList: true))

                } label: {
                    Text(cocktailSectionTitle)
                }
                NavigationLink {
                    TherapyDrugsEditView()
                        .modifier(MyRadialViewModifier(isList: true))

                } label: {
                    Text(drugsSectionTitle)
                }
                
                Button(action: {
                    showConfirmDelete = true
                }, label: {
                    Text(clearAllTherapyDataMsg)
                        .foregroundColor(.red)
                })
            }
            Spacer()
        }
        .navigationTitle(editUpdateAllTherapyDB)
        .navigationBarTitleDisplayMode(.automatic)
        .alert(isPresented: $therapyManager.showYesNoAlert) {
            Alert(
                title: Text("confirmString".local()),
                message: Text(therapyManager.alertYesNoMsg),
                primaryButton: .default(Text(yesString), action: therapyManager.alertYesAction),
                secondaryButton: .destructive(Text(noString), action: therapyManager.alertNoAction)
            )
        }
        .alert(confirmString, isPresented: $showConfirmDelete, actions: {
            Button(role: .destructive) {
                therapyManager.clearAllItems()
            } label: {
                Text(yesString)
            }
        }, message: {
            Text(confirmDeleteAllTherapyData)
        })
    }
}

public struct TherapyRoutinesEditView: View {
    @ObservedObject var therapyManager: TherapyManager = .shared
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        List {
            ForEach(therapyManager.cocktails.unique(), id: \.id) {cocktail in
                RowSelectCocktailView(cocktail: cocktail)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let deleteCandidate = therapyManager.cocktails[index]
                    if let currentTherapy = therapyManager.currentTherapy,
                       !currentTherapy.cocktailList.contains(deleteCandidate) { // CAN'T REMOVE CURRENT THERAPY Cocktails
                        therapyManager.deleteCocktail(deleteCandidate)
                    } else {
                        showingAlert = true
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: InsertRoutinesView(cocktails: $therapyManager.cocktails, navigationTitle: newCocktailString, backBtnTitle: navigationBackDefaultText)                    .modifier(MyRadialViewModifier(isList: true))
, label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                })
                .isDetailLink(false)
            }
            ToolbarItem(placement: .principal) {
                Text(cocktailSectionTitle).font(.body.bold())
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .foregroundColor(.accentColor)
            }
        }
        .alert("warningMsg".local(), isPresented: $showingAlert, actions: {
            Button(role: .cancel, action: {
                DispatchQueue.main.async {
                    self.showingAlert = false
                }
            }, label: {
                Text(gotItMsg)
            })
        }, message: {
            Text(cantDeleteAsUsedInCurrentTherapy)
        })
    }
}

public struct TherapyDrugsEditView: View {
    @ObservedObject var therapyManager: TherapyManager = .shared
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert: Bool = false
    
    public init() {}

    public var body: some View {
        List {
            ForEach(therapyManager.drugs.unique(), id: \.id) {drug in
                HStack(alignment: .center) {
                    Text(drug.name ?? noDrugNameText)
                    Spacer()
                    Text("\(drug.unit ?? "")")
                    if let shape = DrugShape.valueFrom(description: drug.shape ?? "noshape"), let shapeImg = shape.image {
                        Image(systemName: shapeImg)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let deleteCandidate = therapyManager.drugs[index]
                    if let currentTherapy = therapyManager.currentTherapy,
                       !currentTherapy.drugsList.contains(deleteCandidate) { // CAN'T REMOVE CURRENT THERAPY Cocktails
                        therapyManager.deleteDrug(drug: deleteCandidate)
                    } else {
                        showingAlert = true
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: NewDrugInputView(navigationTitle: newDrugString, backBtnTitle: navigationBackDefaultText).modifier(MyRadialViewModifier(isList: true))
, label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                })
                .isDetailLink(false)
            }
            ToolbarItem(placement: .principal) {
                Text(drugsSectionTitle).font(.body.bold())
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .foregroundColor(.accentColor)
            }
        }
        .alert("warningMsg".local(), isPresented: $showingAlert, actions: {
            Button(role: .cancel, action: {
                DispatchQueue.main.async {
                    self.showingAlert = false
                }
            }, label: {
                Text(gotItMsg)
            })
        }, message: {
            Text(cantDeleteAsUsedInCurrentTherapy)
        })
    }
}

public struct TherapyEditView: View {
    @ObservedObject var therapyManager: TherapyManager = .shared
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert: Bool = false
    let showHeader: Bool
    
    public init(showHeader: Bool) {
        self.showHeader = showHeader
    }

    public var body: some View {
        VStack {
            if showHeader {
                TherapyMainViewHeder()
            }
            List {
                ForEach(therapyManager.therapies, id: \.id) { therapy in
                    RowTherapyView(therapy: therapy)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let deleteCandidate = therapyManager.therapies[index]
                        if let currentTherapy = therapyManager.currentTherapy,
                           currentTherapy != deleteCandidate { // CAN'T REMOVE CURRENT THERAPY
                            therapyManager.deleteTherapy(deleteCandidate)
                        } else {
                            showingAlert = true
                        }
                    }
                }
            }
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: InsertUpdateTherapyView(navigationTitle: newTherapyString, backBtnTitle: navigationBackDefaultText)                    .modifier(MyRadialViewModifier(isList: true))
, label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                })
                .isDetailLink(false)
                .foregroundColor(.accentColor)
            }
            ToolbarItem(placement: .principal) {
                Text(therapiesNavTitle).font(.body.bold())
                    .foregroundColor(.accentColor)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .foregroundColor(.accentColor)
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
        .alert("warningMsg".local(), isPresented: $showingAlert, actions: {
            Button(role: .cancel, action: {
                DispatchQueue.main.async {
                    self.showingAlert = false
                }
            }, label: {
                Text(gotItMsg)
            })
        }, message: {
            Text(cantDeleteAsUsedInCurrentTherapy)
        })
    }
}

public struct NewDrugInputView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var therapyManager: TherapyManager = .shared
    let navigationTitle: String
    let backBtnTitle: String
    
    @State private var inputName: String = sampleDrugNameString
    @State private var inputUnit: DrugUnit = .mg
    @State private var inputShape: DrugShape = .pill
    @State private var saveEnabled: Bool = false
    
    public init(navigationTitle: String, backBtnTitle: String) {
        self.navigationTitle = navigationTitle
        self.backBtnTitle = backBtnTitle
    }

    func save() {
        therapyManager.insertDrug(name: inputName, unit: inputUnit.description, shape: inputShape.description) { _ in
            mainDebugger.append("New Drug \(inputName) saved")
            }
    }
    
    public var body: some View {
        VStack {
            Form {
                MyTextField(fieldName: "Name:", bindingString: $inputName, isMandatory: true)
                MyGenericPickerView<DrugUnit>(labelText: therapyUnitText, binding: $inputUnit)
                MyGenericPickerView<DrugShape>(labelText: therapyShapeText, binding: $inputShape)
            }
            .modifier(TherapyToolbarSaveViewModifier(navigationTitle: navigationTitle,
                                                     backBtnTitle: backBtnTitle,
                                                     saveAction: save,
                                                    saveEnabled: $saveEnabled)
            )
        }
        .onChange(of: inputName) { _ in
            checkIsSaveEnabled()
        }
    }
    
    func checkIsSaveEnabled() {
        if inputName.isEmpty {
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

public struct TherapyMainViewHeder: View {
    @ObservedObject var therapyManager: TherapyManager = .shared

    public init() {}

    public var body: some View {
        HStack {
            Spacer()
            Button(action: {
                SheetViewController.shared.reset()
                SheetViewController.shared.cancelActionText = closeButtonString
                SheetViewController.shared.cancelActionImage = "xmark"
                SheetViewController.shared.sheetContentView = AnyView(TherapyEditView(showHeader: false))
                SheetViewController.shared.sheetVisible = true
            }, label: {
                HStack {
                    Image(systemName: "plus.circle")
                    Text(addButtonString)
                }
            })
        }
        .font(.body.bold())
        .padding()
    }
}
