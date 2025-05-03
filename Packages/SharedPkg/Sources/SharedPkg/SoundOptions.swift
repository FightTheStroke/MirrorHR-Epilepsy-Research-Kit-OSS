//
//  SoundOptions.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 22/12/20.
//  Copyright © 2020 FightTheStroke Foundation. All rights reserved.
//

import Combine
import Foundation
import RoberdanToolBox
import SwiftUI

public final class SoundOptions: ObservableObject, Equatable, Codable, ResettableToDefaultSetting {
    enum Keys: StorageKey {
        case alarmSoundIndex
        case notificationSoundIndex
        case alarmSoundVolume
        case notificationSoundVolume
        
        var value: String {
            switch self {
            case .alarmSoundIndex: return "SoundOption.alarmSoundIndex"
            case .alarmSoundVolume: return "SoundOption.alarmSoundVolume"
            case .notificationSoundIndex: return "SoundOption.notificationSoundIndex"
            case .notificationSoundVolume: return "SoundOption.notificationSoundVolume"
            }
        }
    }
    
    public var resetToDefaultValues = AnyCancellable {}
    public static var shared = SoundOptions()
    
    public var alarmSoundOptions: [String] = defaultSoundAlarmOptions
    public var notificationSoundOptions: [String] = defaultSoundNotificationOptions
    
    @Published public var alarmSound: String = ""
    @Published public var notificationSound: String = ""
    @Published public var medicationReminderSound: String = "medicationReminderSound.mp3"
    
    @AppStorage(Keys.alarmSoundIndex.value) public var alarmSoundIndex: Int = defaultAlarmOptionIndex {
        didSet {
            alarmSound = alarmSoundOptions[alarmSoundIndex] + ".mp3"
        }
    }

    @AppStorage(Keys.notificationSoundIndex.value) public var notificationSoundIndex: Int = defaultNotificationOtionIndex {
        didSet {
            notificationSound = notificationSoundOptions[notificationSoundIndex] + ".mp3"
        }
    }

    
    @PublishedStored(key: Keys.alarmSoundVolume, defaultValue: defaultAlarmSoundVolume)
    public var alarmSoundVolume: Float {
        didSet {
            notificationSoundVolume = alarmSoundVolume // To keep the 2 volumes at the same level
        }
    }
    
    @PublishedStored(key: Keys.notificationSoundVolume, defaultValue: defaultNotificationSoundVolume)
    public var notificationSoundVolume: Float
    
    private init() {
        setStorage(UserDefaults.standard, into: self)
        self.handleMigrationIfNeeded()
        
        alarmSound = alarmSoundOptions[alarmSoundIndex] + ".mp3"
        notificationSound = notificationSoundOptions[notificationSoundIndex] + ".mp3"
        resetToDefaultValues = resetToDefaultValuesCommandPublisher
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: {
                self.reset()
                mainDebugger.append("ResetToDefaultValuesPublisher event received from SoundOptions class", .event)
            })
    }
    
    private func handleMigrationIfNeeded() {
        struct SoundOptionData: Codable {
            let alarmSoundIndex: Int?
            let notificationSoundIndex: Int?
            let alarmSoundVolume: Float?
            let notificationSoundVolume: Float?
        }
        
        let fileName = appName + "_Sounds"
        let userDefaults = UserDefaults.standard
        guard
            let fileContent = userDefaults.string(forKey: fileName),
            let fileContentData = fileContent.data(using: .utf8),
            let decodedData = try? JSONDecoder().decode(SoundOptionData.self, from: fileContentData)
        else {
            return
        }
        
        alarmSoundIndex = decodedData.alarmSoundIndex ?? defaultAlarmOptionIndex
        notificationSoundIndex = decodedData.notificationSoundIndex ?? defaultNotificationOtionIndex
        alarmSoundVolume = decodedData.alarmSoundVolume ?? defaultAlarmSoundVolume
        notificationSoundVolume = decodedData.notificationSoundVolume ?? defaultNotificationSoundVolume
        
        userDefaults.removeObject(forKey: fileName)
    }
    
    public func reset() {
        alarmSoundIndex = defaultAlarmOptionIndex
        notificationSoundIndex = defaultNotificationOtionIndex
        alarmSoundVolume = defaultAlarmSoundVolume
        notificationSoundVolume = defaultNotificationSoundVolume
    }
    
    public static func == (lhs: SoundOptions, rhs: SoundOptions) -> Bool {
        return lhs.alarmSoundIndex == rhs.alarmSoundIndex &&
        lhs.notificationSoundIndex == rhs.notificationSoundIndex
    }
    
    public static func binding<T>(
        for property: WritableKeyPath<SoundOptions, T>
    ) -> Binding<T> {
        .init(
            get: {
                SoundOptions.shared[keyPath: property]
            },
            set: { value in
                SoundOptions.shared[keyPath: property] = value
            }
        )
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case alarmSoundIndex
        case notificationSoundIndex
        case alarmSoundVolume
        case notificationSoundVolume
        case alarmSound
        case notificationSound
        case medicationReminderSound
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alarmSoundIndex = try container.decode(Int.self, forKey: .alarmSoundIndex)
        notificationSoundIndex = try container.decode(Int.self, forKey: .notificationSoundIndex)
        alarmSound = try container.decode(String.self, forKey: .alarmSound)
        notificationSound = try container.decode(String.self, forKey: .notificationSound)
        medicationReminderSound = try container.decode(String.self, forKey: .medicationReminderSound)

        setStorage(UserDefaults.standard, into: self)
        resetToDefaultValues = resetToDefaultValuesCommandPublisher
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: {
                self.reset()
            })
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alarmSoundIndex, forKey: .alarmSoundIndex)
        try container.encode(notificationSoundIndex, forKey: .notificationSoundIndex)
        try container.encode(alarmSound, forKey: .alarmSound)
        try container.encode(notificationSound, forKey: .notificationSound)
        try container.encode(medicationReminderSound, forKey: .medicationReminderSound)
    }
    
    /// Converts the current `SoundOptions` instance to a JSON string.
    /// - Returns: A JSON string representation of the `SoundOptions` instance, or `nil` if encoding fails.
    public func jsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Failed to encode SoundOptions: \(error)")
            return nil
        }
    }
    
    /// Updates the `SoundOptions` instance with the data from a given JSON string.
    /// - Parameter jsonString: A JSON string representation of `SoundOptions`.
    public func loadFromJson(jsonString: String) {
        let decoder = JSONDecoder()
        
        do {
            let jsonData = jsonString.data(using: .utf8)!
            let decodedOptions = try decoder.decode(SoundOptions.self, from: jsonData)
            
            DispatchQueue.main.async {
                // Update the current instance with the decoded values

                self.alarmSoundIndex = decodedOptions.alarmSoundIndex
                self.notificationSoundIndex = decodedOptions.notificationSoundIndex
                self.alarmSoundVolume = defaultAlarmSoundVolume
                self.notificationSoundVolume = defaultNotificationSoundVolume
                self.alarmSound = decodedOptions.alarmSound
                self.notificationSound = decodedOptions.notificationSound
                self.medicationReminderSound = decodedOptions.medicationReminderSound
            }
        } catch {
            print("Failed to decode SoundOptions: \(error)")
        }
    }
}

