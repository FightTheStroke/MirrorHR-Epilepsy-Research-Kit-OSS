//
//  TherapyManager.swift
//
//
//  Created by Roberto D’Angelo on 26/04/22.
//

import Foundation
import Combine
import SharedPkg
import CoreData

public class TherapyManager: ObservableObject, ErasableClass {
    static var shared: TherapyManager = TherapyManager()
    
    @Published var therapies = [Therapy]()
    @Published var cocktails = [Cocktail]()
    @Published var doses = [Dose]()
    @Published var drugs = [Drug]()
    
    @Published var showYesNoAlert: Bool = false
    @Published var alertYesNoMsg: String = ""
    
    var alertYesAction: () -> Void = {}
    var alertNoAction: () -> Void = {}
    
    public var eraseCommandSubscriber = AnyCancellable {}
    internal var context = PersistenceController.shared.container.viewContext
    internal let fetchTherapy = NSFetchRequest<NSFetchRequestResult>(entityName: "Therapy")
    internal let fetchCocktail = NSFetchRequest<NSFetchRequestResult>(entityName: "Cocktail")
    internal let fetchDose = NSFetchRequest<NSFetchRequestResult>(entityName: "Dose")
    internal let fetchDrug = NSFetchRequest<NSFetchRequestResult>(entityName: "Drug")

    internal let dataSort = NSSortDescriptor(key: "startDate", ascending: false)
    internal var predicate: NSPredicate?
    
    internal init() {
        fetch()
        eraseCommandSubscriber = eraseCommandCombinePublisher
            .sink {
                self.clearAllItems()
            }
        mainDebugger.append("TherapyManager initialization done")
    }
    
    public func fetch() {
        DispatchQueue.main.async { [self] in
            fetchTherapy.sortDescriptors = [dataSort]
            fetchTherapy.predicate = predicate
            do {
                therapies = try (context.fetch(fetchTherapy) as? Array)!
                cocktails = try (context.fetch(fetchCocktail) as? Array)!
                doses = try (context.fetch(fetchDose) as? Array)!
                drugs = try (context.fetch(fetchDrug) as? Array)!
            } catch {
                logFetchError(error: error)
                return
            }
            mainDebugger.append("TherapyManager fetches done", .event)
        }
    }
    
    public func clearAllItems() {
        therapies.forEach(context.delete)
        cocktails.forEach(context.delete)
        doses.forEach(context.delete)
        drugs.forEach(context.delete)
        save()
        mainDebugger.append("just deleted all therapy data from coredata")
    }
    
    private func logFetchError(error: Error) {
        let nsError = error as NSError
        let msg = "Unresolved error in Therapy Fetch" + "\(nsError), \(nsError.userInfo)"
        mainDebugger.append(msg, .error, sourceModule: "TherapyManager logFetchError")
    }
    
    public func save() {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            let msg = "Unresolved error in Therapy Save" + "\(nsError), \(nsError.userInfo)"
            mainDebugger.append(msg, .error, sourceModule: "TherapyManager save")
            return
        }
        fetch()
        mainDebugger.append("Therapy saved the data", .greenFlag)
    }
    
    public func insertTherapy(name: String, startDate: Date, endDate: Date, cocktails: [Cocktail], saveSymptomLog: Bool = true) {
        let newTherapy = Therapy(context: context)
        newTherapy.id = UUID()
        if name.isEmpty {
            newTherapy.name = "Therapy \(startDate.returnDDmmYY())-\(endDate.returnDDmmYY())"
        } else {
            newTherapy.name = name
        }
        newTherapy.startDate = startDate
        newTherapy.endDate = endDate
        newTherapy.cocktails = NSSet(array: cocktails)
        save()
        if saveSymptomLog {
            let quickLog = SymptomLog(.medicationChange)
            quickLog.startDate = Date()
            quickLog.endDate = Date()
            let jsonString = newTherapy.jsonString
            quickLog.jsonMetaData = jsonString.json
            quickLog.notes = jsonString.text
            quickLog.append { savedStatus in
                mainDebugger.append("\(quickLog.rawValue) \(savedStatus)")
            }
        }
    }
    
    public func updateTherapy(therapy: Therapy, newName: String,
                       newStartDate: Date, newEndDate: Date,
                       newCocktails: [Cocktail]) {
        therapy.name = newName
        therapy.startDate = newStartDate
        therapy.endDate = newEndDate
        therapy.cocktails = NSSet(array: newCocktails)
        save()
    }
    
    @MainActor public func insertCocktail(name: String, doses: [Dose], reminder: Date?, notes: String, completion: @escaping (_ newCockail: Cocktail) -> Void) {
        let medicationManager: MedicationManager = MedicationManager.shared

        let newCocktail = Cocktail(context: context)
        newCocktail.id = UUID()
        newCocktail.doses = NSSet(array: doses)
        newCocktail.reminder = reminder
        newCocktail.name = name
        save()
        if let reminder = reminder {
            medicationManager.scheduleTherapyAssociatedMedicationReminder(recurrence: .wholeWeek, atTime: reminder)
        }
        completion(newCocktail)
    }
    
    public func updateCocktail(cocktail: Cocktail, newName: String, doses: [Dose], reminder: Date, notes: String) {
        cocktail.name = newName
        cocktail.doses = NSSet(array: doses)
        if remindersImplemented {
            cocktail.reminder = reminder
        } else {
            cocktail.reminder = nil
        }
        cocktail.note = notes
        save()
    }
    
    public func deleteTherapy(_ therapy: Therapy) {
        mainDebugger.append("deleting \(String(describing: therapy.id))")
        context.delete(therapy)
        save()
    }
    
    public func deleteCocktail(_ cocktail: Cocktail) {
        context.delete(cocktail)
        save()
    }
    
    // MARK: Codable implementation
    struct CodableTherapyManager: Codable {
        var therapies: [Therapy.CodableTherapy]
        var cocktails: [Cocktail.CodableCocktail]
        var doses: [Dose.CodableDose]
        var drugs: [Drug.CodableDrug]
    }

    public func jsonString() throws -> String {
        let codableTherapyManager = CodableTherapyManager(
            therapies: therapies.map { $0.codableObject },
            cocktails: cocktails.map { $0.codableObject },
            doses: doses.map { $0.codableObject },
            drugs: drugs.map { $0.codableObject }
        )
        let jsonData = try JSONEncoder().encode(codableTherapyManager)
        return String(data: jsonData, encoding: .utf8)!
    }

    public func loadFromJson(jsonString: String) throws {
        let jsonData = jsonString.data(using: .utf8)!
        let codableTherapyManager = try JSONDecoder().decode(CodableTherapyManager.self, from: jsonData)
        
        clearAllItems()

        DispatchQueue.main.async {[self] in
            for codableTherapy in codableTherapyManager.therapies {
                let therapy = Therapy(context: context)
                therapy.update(from: codableTherapy, context: context)
                therapies.append(therapy)
            }
            
            for codableCocktail in codableTherapyManager.cocktails {
                let cocktail = Cocktail(context: context)
                cocktail.update(from: codableCocktail, context: context)
                cocktails.append(cocktail)
            }
            
            for codableDose in codableTherapyManager.doses {
                let dose = Dose(context: context)
                dose.update(from: codableDose, context: context)
                doses.append(dose)
            }
            
            for codableDrug in codableTherapyManager.drugs {
                let drug = Drug(context: context)
                drug.update(from: codableDrug, context: context)
                drugs.append(drug)
            }
            save()
        }
    }
}

extension TherapyManager { // DRUG MANAGEMENT
    func insertDrug(name: String, unit: String, shape: String, completion: @escaping (_ newDrug: Drug) -> Void) {
        let newDrug = Drug(context: context)
        newDrug.id = UUID()
        if name.isEmpty {
            newDrug.name = newDrugString
        } else {
            newDrug.name = name
        }
        newDrug.unit = unit
        newDrug.shape = shape
        save()
        completion(newDrug)
    }
    
    func updateDrug(drug: Drug, newName: String, newUnit: String, newShape: String) {
        drug.name = newName
        drug.shape = newShape
        drug.unit = newUnit
        save()
    }
    
    func deleteDrug(drug: Drug) {
        context.delete(drug)
        save()
    }
}

extension TherapyManager { // DOSES MANAGEMENT
    func insertDose(drug: Drug, quantity: Double, shapes: Double, completion: @escaping (_ newDose: Dose) -> Void) {
        let newDose = Dose(context: context)
        newDose.id = UUID()
        newDose.quantity = quantity
        newDose.shapes = shapes
        newDose.drug = drug
        save()
        completion(newDose)
    }
    
    func deleteDose(dose: Dose) {
        context.delete(dose)
        save()
    }
}

extension TherapyManager { // current therapy
    var currentTherapy: Therapy? {
        let currTherapy = therapies.filter { therapy in
            let now = Date()
            guard let startDate = therapy.startDate, let endDate = therapy.endDate else {
                return false
            }
            return startDate < now && endDate > now
        }
        return currTherapy.isEmpty ? nil : currTherapy.first
    }
    
    public func loadFromJsonAndSave(_ jsonString: String,
                                           completion: @escaping (Result<Therapy?, Error>) -> Void) {
        guard let loadTherapy = Therapy.loadFromJson(jsonString) else {
            completion(.success(nil))
            return
        }
        
        if let index = therapies.firstIndex(of: loadTherapy) {
            completion(.success(therapies[index])) // it's already stores so avoid to duplicate it
        } else {
            var newTherapy = Therapy(context: context)
            newTherapy = loadTherapy
            save()
            completion(.success(newTherapy))
            return
        }
    }
}

extension TherapyManager { // Sample data generation
    func generateSample() {
        let newDrug = Drug(context: context)
        newDrug.id = UUID()
        newDrug.name = "Tegretol Cippa"
        newDrug.shape = DrugShape.pill.description
        newDrug.unit = "mg"
        
        let newDrug2 = Drug(context: context)
        newDrug2.id = UUID()
        newDrug2.name = "Depakin Lippa"
        newDrug2.shape = DrugShape.other.description
        newDrug2.unit = "ml"
        
        let newDose = Dose(context: context)
        newDose.id = UUID()
        newDose.quantity = 0.5
        newDose.shapes = 0.2
        newDose.drug = newDrug
        
        let newDose2 = Dose(context: context)
        newDose2.id = UUID()
        newDose2.quantity = 0.4
        newDose2.shapes = 1
        newDose2.drug = newDrug2
        
        let newCocktail = Cocktail(context: context)
        newCocktail.id = UUID()
        newCocktail.name = "cocktail 1"
        newCocktail.reminder = Date()
        newCocktail.doses = [newDose, newDose2] // NSSet(array: cocktails)
        
        let newCocktail2 = Cocktail(context: context)
        newCocktail2.id = UUID()
        newCocktail2.name = "cocktail 2"
        newCocktail2.reminder = Date().addDay(number: 2)
        newCocktail2.doses = [newDose2] // NSSet(array: cocktails)
        
        let newTherapy = Therapy(context: context)
        newTherapy.id = UUID()
        newTherapy.name = "Terapia 1"
        newTherapy.startDate = Date()
        newTherapy.endDate = Date().addDay(number: 4)
        newTherapy.cocktails = [newCocktail, newCocktail2]
        
        let newTherapy2 = Therapy(context: context)
        newTherapy2.id = UUID()
        newTherapy2.name = "Terapia 2"
        newTherapy2.startDate = Date()
        newTherapy2.endDate = Date().addDay(number: 4)
        newTherapy2.cocktails = [newCocktail2]
        save()
    }
}

