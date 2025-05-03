//
//  JsonTherapy.swift
//  
//
//  Created by Roberto D’Angelo on 16/05/22.
//

import Foundation
import SharedPkg

extension Therapy { // Make it codable without making it codable :-)
    fileprivate struct DrugMirror: Codable {
        fileprivate var name: String
        fileprivate var shape: String
        fileprivate var unit: String
        fileprivate var id: UUID
        
        fileprivate init(name: String, shape: String, unit: String, id: UUID) {
            self.name = name
            self.shape = shape
            self.unit = unit
            self.id = id
        }
    }
    
    fileprivate struct DosesMirror: Codable {
        fileprivate var quantity: Double
        fileprivate var shapes: Double
        fileprivate var drug: DrugMirror
        fileprivate var id: UUID
        
        fileprivate init (quantity: Double, shapes: Double, drug: DrugMirror, id: UUID) {
            self.quantity = quantity
            self.shapes = shapes
            self.drug = drug
            self.id = id
        }
    }
    
    fileprivate struct CocktailMirror: Codable {
        fileprivate var name: String
        fileprivate var note: String?
        fileprivate var reminder: Date?
        fileprivate var doses: [DosesMirror]
        fileprivate var id: UUID?
        
        fileprivate init (name: String, note: String?, reminder: Date?, doses: [DosesMirror], id: UUID?) {
            self.name = name
            self.note = note
            self.reminder = reminder
            self.doses = doses
            self.id = id
        }
    }
    
    private struct TherapyMirror: Codable {
        fileprivate var name: String
        fileprivate var startDate: Date
        fileprivate var endDate: Date
        fileprivate var cocktails: [CocktailMirror]
        fileprivate var id: UUID
        
        fileprivate init(name: String, startDate: Date, endDate: Date, cocktails: [CocktailMirror], id: UUID) {
            self.name = name
            self.startDate = startDate
            self.endDate = endDate
            self.cocktails = cocktails
            self.id = id
        }
        
        public func jsonString() -> String {
            do {
                let jsonData = try JSONEncoder().encode(self)
                return String(data: jsonData, encoding: .utf8)!
            } catch {
                mainDebugger.append("can't encode TherapyMirror", .error, sourceModule: "TherapyMirror jsonString")
                return ""
            }
        }
        
        fileprivate static func loadFromJson(_ jsonString: String) -> TherapyMirror? {
            let data = Data(jsonString.utf8)
            return try? JSONDecoder().decode(TherapyMirror.self, from: data)
        }
        
        internal static func loadTherapyFromJson(_ jsonString: String) -> Therapy? {
            guard let therapyMirror = loadFromJson(jsonString) else {
                return nil
            }
            let newTherapy: Therapy = Therapy()
            newTherapy.id = therapyMirror.id
            newTherapy.name = therapyMirror.name
            newTherapy.startDate = therapyMirror.startDate
            newTherapy.endDate = therapyMirror.endDate
            
            let cocktails = therapyMirror.cocktails
            var newCocktails: [Cocktail] = []
            cocktails.forEach { cocktail in // cocktails
                var newDoses: [Dose] = []
                let doses = cocktail.doses
                doses.forEach { dose in // Doses and drug
                    let drug = dose.drug
                    let newDrug: Drug = Drug()
                    newDrug.id = drug.id
                    newDrug.name = drug.name
                    newDrug.unit = drug.unit
                    newDrug.shape = drug.shape
                    let newDose: Dose = Dose()
                    newDose.id = dose.id
                    newDose.quantity = dose.quantity
                    newDose.shapes = dose.shapes
                    newDose.drug = newDrug
                    newDoses.append(newDose)
                }
                let newCocktail: Cocktail = Cocktail()
                newCocktail.id = cocktail.id
                newCocktail.name = cocktail.name
                newCocktail.reminder = cocktail.reminder
                newCocktail.doses = NSSet(array: newDoses)
                newCocktails.append(newCocktail)
            }
            newTherapy.cocktails = NSSet(array: newCocktails)
            return newTherapy
        }
    }
    
    public var jsonString: (json: String, text: String) {
        guard let name = name, let startDate = startDate,
                let endDate = endDate, !cocktailList.isEmpty,
                let therapyId = id else {
            return ("", "")
        }
        var text: String = "\(name)\n\(startDate.toDayMonthYear()) -> \(endDate.toDayMonthYear())\n"
        var mirrorCocktails: [CocktailMirror] = []
        for cocktail in cocktailList {
            guard let cocktailName = cocktail.name, !cocktail.dosesList.isEmpty else {
                mainDebugger.append("no cocktails in therapy", .justALog)
                continue
            }
            
            let cocktailNote = cocktail.note ?? ""
            let cocktailReminder = cocktail.reminder
            let cocktailId = cocktail.id!
            var mirrorDoses: [DosesMirror] = []
            var doseText: String = ""
            for dose in cocktail.dosesList {
                guard let drugMirror = dose.drug, let drugName = drugMirror.name,
                        let drugUnit = drugMirror.unit, let drugShape = drugMirror.shape,
                        let drugId = drugMirror.id, let doseId = dose.id else {
                    continue
                }
                let drug: DrugMirror = DrugMirror(name: drugName, shape: drugShape, unit: drugUnit, id: drugId)
                mirrorDoses.append(DosesMirror(quantity: dose.quantity, shapes: dose.shapes, drug: drug, id: doseId))
                doseText += "\(drugName) \(dose.quantity)\n"
            }
            mirrorCocktails.append(CocktailMirror(name: cocktailName, note: cocktailNote, reminder: cocktailReminder, doses: mirrorDoses, id: cocktailId))
            text += "\(cocktailName)\n\(doseText)\n"
        }
        let mirrorTherapy: TherapyMirror = TherapyMirror(name: name, startDate: startDate, endDate: endDate, cocktails: mirrorCocktails, id: therapyId)
        
        let json = mirrorTherapy.jsonString()
        return (json, text)
    }
    
    public static func loadFromJson(_ jsonString: String) -> Therapy? {
        return TherapyMirror.loadTherapyFromJson(jsonString)
    }
}
