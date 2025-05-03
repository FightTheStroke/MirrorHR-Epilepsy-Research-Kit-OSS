//
//  CareGiversManager.swift
//
//
//  Created by Roberto D’Angelo on 01/06/24.
//

import Foundation
import OSLog
import Combine

public class CareGiversManager: ObservableObject, Codable {
    public static let shared: CareGiversManager = CareGiversManager()
    private let personsKey = "PersonsKeyV5"
    private let oldCaregiversKey = "CareGiversIDsV4"
    private let oldPatientsKey = "KidsIDsV4"
    private var isInitializing: Bool = true
    static let logger = Logger(subsystem: "Telemetry", category: "StreamingViaInternetManager")
    
    public var currentUserName: String = "unknown"
    public var currentUserID: String = "unknown"
    
    internal var persons: [Person] = [] {
        didSet {
            if !isInitializing {
                UserDefaultsManager.saveToUserDefaults(key: personsKey, data: persons)
                updateCaregiversAndPatients()
                updateStreamingPreferences()
            }
        }
    }
    
    public var eraseCommandSubscriber: AnyCancellable = AnyCancellable {}
    
    @Published public var caregivers: [Person] = []
    @Published public var patients: [Person] = []
    
    private init() {
        isInitializing = true
        currentUserName = TelemetryHeader.getUserName()
        currentUserID = TelemetryHeader.getUserID()
        migrateOldDataIfNeeded()
        loadFromUserDefaults()
        updateCaregiversAndPatients()
        updateStreamingPreferences()
        isInitializing = false
        eraseCommandSubscriber = eraseCommandCombinePublisher
            .sink {
                self.clearAllItems()
            }
    }
    
    public required init(from decoder: Decoder) throws {
        isInitializing = true

        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentUserName = try container.decode(String.self, forKey: .currentUserName)
        currentUserID = try container.decode(String.self, forKey: .currentUserID)
        persons = try container.decode([Person].self, forKey: .persons)
        
        // Additional initialization
        migrateOldDataIfNeeded()
        loadFromUserDefaults()
        updateCaregiversAndPatients()
        updateStreamingPreferences()
        isInitializing = false
    }
    
    private func loadFromUserDefaults() {
        persons = UserDefaultsManager.loadFromUserDefaults(key: personsKey) ?? []
    }
    
    public func clearAllItems() {
        persons = []
        updateCaregiversAndPatients()
    }
    
    internal func updateCaregiversAndPatients() {
        DispatchQueue.main.async { [self] in
            caregivers = persons.filter { $0.type == .caregiver }
            patients = persons.filter { $0.type == .patient }
        }
    }
    
    private func updateStreamingPreferences() {
        if caregivers.isEmpty {
            dispatchDataSourceChange(.appleWatchPairedOnly)
        }
    }
    
    public func getActivePatient() -> Person? {
        return persons.first(where: { $0.type == .patient && $0.isActive })
    }
}

extension CareGiversManager {
    enum CodingKeys: String, CodingKey {
        case currentUserName
        case currentUserID
        case persons
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentUserName, forKey: .currentUserName)
        try container.encode(currentUserID, forKey: .currentUserID)
        try container.encode(persons, forKey: .persons)
    }
    
    public func validateInput(name: String, uuidString: String) -> Bool {
        !name.isEmpty && UUID(uuidString: uuidString) != nil
    }
    
    public func addPerson(name: String, uuid: UUID, type: PersonType) {
        let isActive = (type == .caregiver)
        let newPerson = Person(name: name, id: uuid, isActive: isActive, type: type)
        addPerson(person: newPerson)
    }
    
    public func addPerson(name: String?, uuid: String?, type: PersonType) {
        guard let name = name, let uuidString = uuid, let uuid = UUID(uuidString: uuidString) else {
            CareGiversManager.logger.log("Invalid name or UUID string provided.")
            return
        }
        let isActive = (type == .caregiver)
        let newPerson = Person(name: name, id: uuid, isActive: isActive, type: type)
        addPerson(person: newPerson)
    }
    
    public func updateWorldLocation(for uuidString: String, worldLocation: WorldLocation, type: PersonType) {
        if let uuid = UUID(uuidString: uuidString), let index = persons.firstIndex(where: { $0.id == uuid && $0.type == type }) {
            persons[index].worldLocation = worldLocation
            UserDefaultsManager.saveToUserDefaults(key: personsKey, data: persons)  // Ensure changes are saved
            updateCaregiversAndPatients()
        }
    }
    
    public func getWorldLocation(for uuid: UUID, type: PersonType) -> WorldLocation? {
        if let index = persons.firstIndex(where: { $0.id == uuid && $0.type == type }) {
            return persons[index].worldLocation
        } else {
            return nil
        }
    }
    
    public func updatePerson(name: String, uuid: UUID, isActive: Bool, type: PersonType) {
        if let index = persons.firstIndex(where: { $0.id == uuid && $0.type == type }) {
            persons[index].name = name
            persons[index].isActive = isActive
            UserDefaultsManager.saveToUserDefaults(key: personsKey, data: persons)  // Ensure changes are saved
            updateCaregiversAndPatients()
        }
    }
    
    public func activatePatient(uuid: UUID) {
        if let index = persons.firstIndex(where: { $0.id == uuid && $0.type == .patient }) {
            persons[index].isActive = true
            UserDefaultsManager.saveToUserDefaults(key: personsKey, data: persons)  // Ensure changes are saved
            updateCaregiversAndPatients()
        }
    }

    
    public func removePerson(uuid: UUID, type: PersonType) {
        if let index = persons.firstIndex(where: { $0.id == uuid && $0.type == type }) {
            persons.remove(at: index)
            updateCaregiversAndPatients()
        }
        updateStreamingPreferences()
    }
    
    private func addPerson(person: Person) {
        guard !persons.contains(where: { $0.id == person.id && $0.type == person.type }) else {
            return
        }
        persons.append(person)
        updateCaregiversAndPatients()
    }
}

extension CareGiversManager {
    // Migrate from previous version of data structure
    private func migrateOldDataIfNeeded() {
        // Load old caregivers data
        if let oldCaregivers: [OldCareGiverStruct] = UserDefaultsManager.loadFromUserDefaults(key: oldCaregiversKey) {
            let migratedCaregivers = oldCaregivers.map { Person(name: $0.name, id: $0.id, isActive: true, type: .caregiver) }
            persons.append(contentsOf: migratedCaregivers)
            UserDefaultsManager.removeFromUserDefaults(key: oldCaregiversKey)
        }
        
        // Load old patients data
        if let oldPatients: [OldCareGiverStruct] = UserDefaultsManager.loadFromUserDefaults(key: oldPatientsKey) {
            let migratedPatients = oldPatients.map { Person(name: $0.name, id: $0.id, isActive: false, type: .patient) }
            persons.append(contentsOf: migratedPatients)
            UserDefaultsManager.removeFromUserDefaults(key: oldPatientsKey)
        }
        // Save migrated data to new key
        if !persons.isEmpty {
            UserDefaultsManager.saveToUserDefaults(key: personsKey, data: persons)
        }
    }
    
    public func jsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Failed to encode CareGiversManager: \(error)")
            return nil
        }
    }
    
    public func loadFromJson(jsonString: String) {
        let decoder = JSONDecoder()
        
        do {
            let jsonData = jsonString.data(using: .utf8)!
            let decodedManager = try decoder.decode(CareGiversManager.self, from: jsonData)
            
            // Update the current instance with the decoded values
            self.currentUserName = decodedManager.currentUserName
            self.currentUserID = decodedManager.currentUserID
            self.persons = decodedManager.persons
            
            updateCaregiversAndPatients()
            updateStreamingPreferences()
        } catch {
            print("Failed to decode CareGiversManager: \(error)")
        }
    }
}

extension CareGiversManager {
    /// Sends a remote command to the active patient.
    ///
    /// This function constructs a `RemoteCommandFromCareGiverToKid` object using the provided command,
    /// the current caregiver's name, ID, and the active patient's ID. It then sends this command to the active
    /// patient via telemetry. If no active patient is found, it logs an appropriate message.
    ///
    /// - Parameter command: The command to be sent to the active patient.
    public func sendRemoteCommandToActivePatient(command: RemoteCommands) {
        guard let activePatient = getActivePatient() else {
            // No active patients available to send the remote command to.
            return
        }
        
        let careGiverName = TelemetryHeader.getUserName()
        let careGiverID = TelemetryHeader.getUserID()
        let patientID = activePatient.id.uuidString
        let patientName = activePatient.name
        
        let remoteCommand = RemoteCommand(
            command: command,
            careGiverName: careGiverName,
            careGiverID: careGiverID,
            kidID: patientID,
            kidName: patientName
        )
        
        dispatchTelemetryEvent(event: .remoteCommand(command: remoteCommand))
//        ToastManager.shared.showToast(message: "Sending \(command) to active patient", image: "info.bubble")
    }
    
    public func sendRemotCommandToMyCareGivers(command: RemoteCommands) {
        let patientID = TelemetryHeader.getUserID()
        let patientName = TelemetryHeader.getUserName()
        
        for caregiver in self.caregivers {
            let careGiverName = caregiver.name
            let careGiverID = caregiver.id.uuidString
            let remoteCommand = RemoteCommand(command: command, careGiverName: careGiverName, careGiverID: careGiverID, kidID: patientID, kidName: patientName)
            dispatchTelemetryEvent(event: .remoteCommand(command: remoteCommand))
        }
//        ToastManager.shared.showToast(message: "Sending \(command) to all caregivers", image: "info.bubble")
    }
}

public enum PersonType: String, Codable {
    case caregiver
    case patient
}

public class Person: Identifiable, Codable {
    public static func == (lhs: Person, rhs: Person) -> Bool {
        lhs.id == rhs.id
    }
    
    public var name: String
    public var id: UUID
    public var isActive: Bool
    public var type: PersonType
    public var worldLocation: WorldLocation?
    
    public init(name: String, id: UUID, isActive: Bool, type: PersonType, worldLocation: WorldLocation? = nil) {
        self.name = name
        self.id = id
        self.isActive = isActive
        self.type = type
        self.worldLocation = worldLocation
    }
    
    public func changeActiveStatus(to: Bool) {
        isActive = to
    }
    
    // Custom encoding and decoding to handle the `type` and `worldLocation` properties
    enum CodingKeys: String, CodingKey {
        case name
        case id
        case isActive
        case type
        case worldLocation
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(UUID.self, forKey: .id)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        type = try container.decode(PersonType.self, forKey: .type)
        worldLocation = try container.decodeIfPresent(WorldLocation.self, forKey: .worldLocation)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(type, forKey: .type)
        try container.encode(worldLocation, forKey: .worldLocation)
    }
    
    public func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["name"] = name
        dictionary["id"] = id.uuidString // UUID deve essere convertito in una stringa
        dictionary["isActive"] = isActive
        dictionary["type"] = type.rawValue // Assumo che `PersonType` abbia una rappresentazione `rawValue` (ad esempio se è un enum con tipo String o Int)
        
        if let location = worldLocation {
            dictionary["worldLocation"] = location.toDictionary() // Assumo che `WorldLocation` abbia un metodo `toDictionary()`
        }

        return dictionary
    }

}

public struct OldCareGiverStruct: Identifiable, Codable {
    public var name: String
    public var id: UUID
}

extension CareGiversManager {
    
}
