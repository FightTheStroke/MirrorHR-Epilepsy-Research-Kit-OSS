//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 23/10/23.
//

import Foundation
import SwiftUI
import OpenAIPackage
import UserNotifications
import MirrorHRTelemetryPackage

// MARK: - ViewModel

@MainActor
class MedicationViewModel: ObservableObject {
    @Published var userPrompt: String = ""
    @Published var medications: [Medication] = []
    @Published var showValidationView: Bool = false
    @Published var showError: Bool = false

    let openAIConnector: OpenAIConnector
    
    let promptPrefix = "Parse the epilepsy medication reminder text (it can be in English or in \(TelemetryHeader.shared.language): \""
    let promptSuffix = "\". Extract and organize the information for each medication mentioned exactly in this way: medication name, dose, form (pill, liquid, injectable, other), and schedule (time in 24-hour format with 2 digits for the hours and 2 digits for the minutes, days). Please provide the details in the following format:\n\nMedication: {medication_name}\nDose: {dose_amount}\nForm: {medication_form}\nSchedules:\n- Time: {time_1}, Days: {day_1, day_2, ...}\n- Time: {time_2}, Days: {day_1, day_2, ...}\n..."

    init(connector: OpenAIConnector = OpenAIConnector.shared) {
        self.openAIConnector = connector
    }
    
    func processPrompt(prompt: String) {
        Task {
            await processPromptInternal(prompt: prompt)
        }
    }
    
    func processPromptInternal(prompt: String) async {
        let augmentedPrompt: String = promptPrefix + prompt + promptSuffix
        do {
            guard let response = try await openAIConnector.processPrompt(prompt: augmentedPrompt) else {
                DispatchQueue.main.async {
                    self.showError = true
                }
                return
            }
            if let parsedData = parseMedicationData(from: response) {
                DispatchQueue.main.async { [self] in
                    medications = parsedData
                    showValidationView = true
                }
            } else {
                DispatchQueue.main.async {
                    self.showError = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.showError = true
            }
        }
    }

    func parseMedicationData(from response: String) -> [Medication]? {
        let lines = response.split(separator: "\n")
        var medications = [Medication]()
        var currentMedication: Medication?

        for line in lines {
            let components = line.split(separator: " ")
            guard components.count > 1 else { continue }

            switch components.first {
            case "Medication:":
                if let medication = currentMedication {
                    medications.append(medication)
                }
                currentMedication = Medication(name: String(components[1]), dose: "", form: .pill, schedules: [])
            case "Dose:":
                currentMedication?.dose = String(components[1])
            case "Form:":
                currentMedication?.form = MedicationForm(rawValue: String(components[1])) ?? .other
            case "-":
                guard components.count > 4 else { continue }
                let trimmedString = components[2].trimmingCharacters(in: CharacterSet(charactersIn: ","))
                let timeComponents = trimmedString.split(separator: ":").map(String.init)
                guard timeComponents.count == 2,
                      let hour = Int(timeComponents[0]),
                      let minute = Int(timeComponents[1]) else {
                    continue
                }
                let daysString = components[4...].joined()
                let days = parseDays(daysString)
                let schedule = Schedule(time: Time(hour: hour, minute: minute), days: days)
                currentMedication?.schedules.append(schedule)


            default:
                continue
            }
        }

        if let medication = currentMedication {
            medications.append(medication)
        }

        return medications.isEmpty ? nil : medications
    }

    func parseDays(_ daysString: String) -> [Day] {
        let dayStrings = daysString.split { $0 == "," || $0 == " " }.map(String.init)
        let days = dayStrings.compactMap { Day(rawValue: $0) }
        return days
    }


    func scheduleReminders() {
        let center = UNUserNotificationCenter.current()
        for med in medications {
            for schedule in med.schedules {
                for day in schedule.days {
                    let content = UNMutableNotificationContent()
                    content.title = "Medication Reminder"
                    content.interruptionLevel = .critical
                    content.body = "Time to take \(med.dose) pills of \(med.name)"
                    content.sound = .default
                    
                    var dateComponents = DateComponents()
                    dateComponents.hour = schedule.time.hour
                    dateComponents.minute = schedule.time.minute
                    dateComponents.weekday = dayToWeekday(day)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request)
                }
            }
        }
    }
    
    func dayToWeekday(_ day: Day) -> Int {
        switch day {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }

    struct EpilepsyMedication {
        let name: String
        let genericName: String?
        let form: [MedicationForm]
        //... Add any other relevant fields as necessary
    }

    enum MedicationForm: String, Codable {
        case pill, liquid, injectable, other
    }

    enum Day: String, Codable, CaseIterable {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
    }

    struct Time: Codable {
        var hour: Int
        var minute: Int
    }

    struct Schedule: Codable {
        var id: UUID = UUID()
        var time: Time
        var days: [Day]
    }

    struct Medication: Codable, Identifiable {
        var id: UUID = UUID()
        var name: String
        var dose: String
        var form: MedicationForm
        var schedules: [Schedule]
    }
    
    let epilepsyMedications: [EpilepsyMedication] = [
        EpilepsyMedication(name: "Keppra", genericName: "Levetiracetam", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Lamictal", genericName: "Lamotrigine", form: [.pill]),
        EpilepsyMedication(name: "Topamax", genericName: "Topiramate", form: [.pill]),
        EpilepsyMedication(name: "Depakote", genericName: "Divalproex sodium", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Zonisamide", genericName: "Zonisamide", form: [.pill]),
        EpilepsyMedication(name: "Dilantin", genericName: "Phenytoin", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Tegretol", genericName: "Carbamazepine", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Neurontin", genericName: "Gabapentin", form: [.pill]),
        EpilepsyMedication(name: "Lyrica", genericName: "Pregabalin", form: [.pill]),
        EpilepsyMedication(name: "Sabril", genericName: "Vigabatrin", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Felbatol", genericName: "Felbamate", form: [.pill]),
        EpilepsyMedication(name: "Briviact", genericName: "Brivaracetam", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Diamox", genericName: "Acetazolamide", form: [.pill]),
        EpilepsyMedication(name: "Epidiolex", genericName: "Cannabidiol", form: [.liquid]),
        EpilepsyMedication(name: "Xcopri", genericName: "Cenobamate", form: [.pill]),
        EpilepsyMedication(name: "Onfi", genericName: "Clobazam", form: [.pill]),
        EpilepsyMedication(name: "Klonopin", genericName: "Clonazepam", form: [.pill]),
        EpilepsyMedication(name: "Tranxene", genericName: "Clorazepate", form: [.pill]),
        EpilepsyMedication(name: "Acthar Gel", genericName: "Corticotropin", form: [.injectable]),
        EpilepsyMedication(name: "Valium", genericName: "Diazepam", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Aptiom", genericName: "Eslicarbazepine Acetate", form: [.pill]),
        EpilepsyMedication(name: "Peganone", genericName: "Ethotoin", form: [.pill]),
        EpilepsyMedication(name: "Zarontin", genericName: "Ethosuximide", form: [.liquid]),
        EpilepsyMedication(name: "Fintepla", genericName: "Fenfluramine", form: [.liquid]),
        EpilepsyMedication(name: "Cerebyx", genericName: "Fosphenytoin", form: [.injectable]),
        EpilepsyMedication(name: "Vimpat", genericName: "Lacosamide", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Ativan", genericName: "Lorazepam", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Celontin", genericName: "Methsuximide", form: [.pill]),
        EpilepsyMedication(name: "Versed", genericName: "Midazolam", form: [.liquid]),
        EpilepsyMedication(name: "Trileptal", genericName: "Oxcarbazepine", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Fycompa", genericName: "Perampanel", form: [.pill]),
        EpilepsyMedication(name: "Luminal", genericName: "Phenobarbital", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Mysoline", genericName: "Primidone", form: [.pill]),
        EpilepsyMedication(name: "Banzel", genericName: "Rufinamide", form: [.pill, .liquid]),
        EpilepsyMedication(name: "Diacomit", genericName: "Stiripentol", form: [.pill]),
        EpilepsyMedication(name: "Gabitril", genericName: "Tiagabine", form: [.pill]),
        EpilepsyMedication(name: "Zonegran", genericName: "Zonisamide", form: [.pill]),
        EpilepsyMedication(name: "Tolep", genericName: nil, form: [.pill])  // Tolep is used to treat both focal and generalized seizures.
    ]
}
