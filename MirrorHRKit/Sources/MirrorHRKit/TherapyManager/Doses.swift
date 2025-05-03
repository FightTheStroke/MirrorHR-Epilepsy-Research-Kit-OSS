//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 01/05/22.
//

import Foundation
import SwiftUI
import SharedPkg

public struct DosesMainView: View {
    @ObservedObject private var therapyManager: TherapyManager = .shared
    @Binding var doses: [Dose]
    private var showMenuPicker: Bool {
        !therapyManager.doses.isEmpty && doses != therapyManager.doses
    }
    
    public var body: some View {
        Section(header: drugsSectionHeader()) {
            List {
                ForEach(doses.unique(), id: \.id) { dose in
                    VStack {
                        HStack {
                            Text(dose.drug?.name ?? noDrugNameText).font(.body.bold())
                            Spacer()
                            Text("\(dose.drug?.shape ?? noDrugShapeText)")
                        }
                        HStack {
                            Text(therapyQuantityText + " \(dose.drug?.unit ?? noDrugUnitText)")
                            Text(String(format: "%.2f", dose.quantity))
                            Spacer()
//                            Text("shapes:")
//                            Text(String(format: "%.2f", dose.shapes))
                        }
                    }
                }
                .onDelete { indexSet in
                    doses.remove(atOffsets: indexSet)
                }
            }
        }
    }
    
    func drugsSectionHeader() -> some View {
        HStack {
            Text(drugDosesTitle)
                .foregroundColor(doses.isEmpty ? .red : .primary)
            Spacer()
            NavigationLink(destination: InsertDrugView(navigationTitle: newDrugString, backBtnTitle: navigationBackDefaultText, doses: $doses)                    .modifier(MyRadialViewModifier(isList: true))
, label: {
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
        ForEach(therapyManager.doses) {dose in
            if !doses.contains(dose), let drug = dose.drug, let drugUnit = drug.unit {
                Button(action: {
                    DispatchQueue.main.async {
//                        let newDose: Dose = dose
//                        newDose.id = UUI()
//                        doses.append(newDose)
                        doses.append(dose)
                    }
                }, label: {
                    let drugName: String = drug.name ?? "no Drug name"
                    let drugQty: String = String(format: "%.2f", dose.quantity)
                    let drugUnitString: String = drugUnit.description
                    let menuRow: String = drugName + "(" + drugQty + drugUnitString + ")"
                    Text(menuRow)
                })
            }
        }
    }
}

public struct InsertDrugView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var therapyManager: TherapyManager = .shared
    let navigationTitle: String
    let backBtnTitle: String
    
    @Binding var doses: [Dose]
    
    @State private var inputName: String = sampleDrugNameString
    @State private var inputUnit: DrugUnit = .mg
    @State private var inputShape: DrugShape = .pill
    @State private var inputQuantity: Double = 0
    @State private var inputShapes: Double = 0
    @State private var existingDrug: Drug?
    @State private var saveEnabled: Bool = false
    
    func save() {
        if let existingDrug = existingDrug {
            therapyManager.insertDose(drug: existingDrug, quantity: inputQuantity, shapes: inputShapes) {newDose in
                doses.append(newDose)
            }
        } else {
            therapyManager.insertDrug(name: inputName, unit: inputUnit.description, shape: inputShape.description) {newDrug in
                therapyManager.insertDose(drug: newDrug, quantity: inputQuantity, shapes: inputShapes) {newDose in
                    doses.append(newDose)
                }
            }
        }
    }
    
    public var body: some View {
        VStack {
            Form {
                HStack {
                    MyTextField(fieldName: "Name:", bindingString: $inputName, isMandatory: true)
                        .disabled(existingDrug != nil)
                    Menu {
                        buildMenu()
                    } label: {
                        Image(systemName: chevronDown)
                    }

                }
                MyGenericPickerView<DrugUnit>(labelText: therapyUnitText, binding: $inputUnit)
                    .disabled(existingDrug != nil)
                MyGenericPickerView<DrugShape>(labelText: therapyShapeText, binding: $inputShape)
                    .disabled(existingDrug != nil)

                HStack {
                    MyDoubleField(fieldName: therapyQuantityText, bindingDouble: $inputQuantity, isMandatory: true)
                    Text(inputUnit.description).frame(width: 50)
                }
//                HStack {
//                    MyDoubleField(fieldName: "Shapes:", bindingDouble: $inputShapes, isMandatory: false)
//                    Image(systemName: inputShape.image ?? "circle").frame(width: 50)
//                }
                
            }
            .modifier(TherapyToolbarSaveViewModifier(navigationTitle: navigationTitle,
                                                     backBtnTitle: backBtnTitle,
                                                     saveAction: save,
                                                    saveEnabled: $saveEnabled))
        }
        .onChange(of: inputName) { _ in
            checkIsSaveEnabled()
        }
        .onChange(of: inputQuantity) { _ in
            checkIsSaveEnabled()
        }
    }
    
    func checkIsSaveEnabled() {
        if inputName.isEmpty || inputQuantity == 0 {
            DispatchQueue.main.async {
                saveEnabled = false
            }
        } else {
            DispatchQueue.main.async {
                saveEnabled = true
            }
        }
    }
    
    func buildMenu() -> some View {
        VStack {
            Button(action: {
                existingDrug = nil
                inputName = ""
            }, label: {
                Text(newDrugString)
                    .font(.body.bold())
            })
            ForEach(therapyManager.drugs.unique()) {drug in
                Button(action: {
                    if let drugName = drug.name, let drugUnit = drug.unit, let drugShape = drug.shape {
                        DispatchQueue.main.async {
                            inputName = drugName
                            inputUnit = DrugUnit.valueFrom(description: drugUnit)
                            if let shape = DrugShape.valueFrom(description: drugShape) {
                                inputShape = shape
                            }
                            existingDrug = drug
                        }
                    }
                }, label: {
                    Text(drug.name ?? noDrugNameText)
                })
            }
        }
    }
}
