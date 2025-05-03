//
//  Make Therapies codable.swift
//
//
//  Created by Roberto D’Angelo on 16/06/24.
//

import Foundation
import CoreData

extension Therapy {
    struct CodableTherapy: Codable {
        let id: UUID
        let name: String
        let startDate: Date
        let endDate: Date
        let cocktails: [Cocktail.CodableCocktail]
    }

    var codableObject: CodableTherapy {
        return CodableTherapy(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            startDate: self.startDate ?? Date(),
            endDate: self.endDate ?? Date(),
            cocktails: (self.cocktails?.allObjects as! [Cocktail]).map { $0.codableObject }
        )
    }
    
    func update(from codable: CodableTherapy, context: NSManagedObjectContext) {
        self.id = codable.id
        self.name = codable.name
        self.startDate = codable.startDate
        self.endDate = codable.endDate
        self.cocktails = NSSet(array: codable.cocktails.map { codableCocktail in
            let cocktail = Cocktail(context: context)
            cocktail.update(from: codableCocktail, context: context)
            return cocktail
        })
    }
}

extension Cocktail {
    struct CodableCocktail: Codable {
        let id: UUID
        let name: String
        let note: String
        let reminder: Date?
        let doses: [Dose.CodableDose]
    }

    var codableObject: CodableCocktail {
        return CodableCocktail(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            note: self.note ?? "",
            reminder: self.reminder,
            doses: (self.doses?.allObjects as! [Dose]).map { $0.codableObject }
        )
    }
    
    func update(from codable: CodableCocktail, context: NSManagedObjectContext) {
        self.id = codable.id
        self.name = codable.name
        self.note = codable.note
        self.reminder = codable.reminder
        self.doses = NSSet(array: codable.doses.map { codableDose in
            let dose = Dose(context: context)
            dose.update(from: codableDose, context: context)
            return dose
        })
    }
}

extension Dose {
    struct CodableDose: Codable {
        let id: UUID
        let quantity: Double
        let shapes: Double
        let drug: Drug.CodableDrug
    }

    var codableObject: CodableDose {
        return CodableDose(
            id: self.id ?? UUID(),
            quantity: self.quantity,
            shapes: self.shapes,
            drug: self.drug?.codableObject ?? Drug.CodableDrug(id: UUID(), name: "", shape: "", unit: "")
        )
    }
    
    func update(from codable: CodableDose, context: NSManagedObjectContext) {
        self.id = codable.id
        self.quantity = codable.quantity
        self.shapes = codable.shapes
        self.drug = Drug(context: context)
        self.drug?.update(from: codable.drug, context: context)
    }
}

extension Drug {
    struct CodableDrug: Codable {
        let id: UUID
        let name: String
        let shape: String
        let unit: String
    }

    var codableObject: CodableDrug {
        return CodableDrug(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            shape: self.shape ?? "",
            unit: self.unit ?? ""
        )
    }
    
    func update(from codable: CodableDrug, context: NSManagedObjectContext) {
        self.id = codable.id
        self.name = codable.name
        self.shape = codable.shape
        self.unit = codable.unit
    }
}
