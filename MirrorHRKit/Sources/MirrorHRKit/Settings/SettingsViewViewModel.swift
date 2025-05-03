//
//  SettingsViewViewModel.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Combine
import SwiftUI
import SharedPkg

extension SettingsView {
    class SettingsViewModel: ObservableObject {
        static var shared: SettingsViewModel = SettingsViewModel()
        
        @Published var keyFlowThresholds: KeyFlowThresholds
        @Published var settings: ProfileGenericSettings
        @Published var sounds: SoundOptions
        
        let symptomsManager: SymptomsManager
        let storage: UserDefaults
        let application: UIApplication

        @Published var showingAlert: Bool = false

        init(
            keyFlowThresholds: KeyFlowThresholds = .shared,
            profileGenericSettings: ProfileGenericSettings = .shared,
            sounds: SoundOptions = .shared,
            symptomsManager: SymptomsManager = .shared,
            storage: UserDefaults = .standard,
            application: UIApplication = .shared
        ) {
            self.keyFlowThresholds = keyFlowThresholds
            self.settings = profileGenericSettings
            self.sounds = sounds
            self.symptomsManager = symptomsManager
            self.storage = storage
            self.application = application
        }

        func testAlarm() {
            showingAlert = true
            mainDebugger.append("Test Alarm button pressed at \(Date().toStdString())")
            dispatchMainEvent(.testSound(critical: true, delay: 30), "Test Alarm in Settings View")
        }

        func callEmergencyNumber() {
            guard let number = URL(string: "tel://\(settings.emergencyNumber)") else { return }
            application.open(number)
        }
    }
}
