//
//  AboutSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SharedPkg
import SwiftUI

extension SettingsView {
    var backupRestoreSection: SettingsSection {
        SettingsSection(
            id: "BackupAndRestore",
            header: "BackupAndRestoreHeaderMsg".local(),
            image: "externaldrive",
            rows: [.custom(name: "BackupAndRestoreHeaderMsg".local(), AnyView(BackupView()),
                           isEnabled: true)], foregroundColor: stefiBlue)
    }
    
    var aboutSectionStuff: SettingsSection {
        SettingsSection(
            id: "About",
            header: aboutMsg,
            image: "info",
            rows: [
                .content(name: appNameString, text: shortAppName),
                .link(name: developerString, label: developerStringLabel, destination: URL(string: developerLinkDestination)!),
                .content(name: versionString, text: appVersion + " " + languageUI),
                .content(name: compatibilityString, text: compatibilityStringContent),
                .link(name: websiteString, label: aboutWebsiteString, destination: URL(string: linkDestinationString)!),
                .link(name: contactsString, label: contactLabelMsg, destination: URL(string: contactLinkDestination)!),
                .link(name: privacyPolicyString, label: privacyPolicyLinkLabel, destination: URL(string: privacyPolicyLinkDestination)!),
                .toggle(name: "privacyMsg".local(), binding: $viewModel.settings.privacyAccepted)
            ],
            foregroundColor: stefiBlue
        )
    }
    
    var researchSection: SettingsSection {
        SettingsSection(
            id: "ResearchSection",
            header: telemetrySectionString,
            image: "graduationcap",
            rows: [
                .custom(name: telemetrySectionString, AnyView(TelemetryConsensusViewNewSettings()), isEnabled: true)
            ],
            foregroundColor: stefiBlue
        )
    }
    
    var shareAndFeedback: some View {
        AnyView(
            HStack {
                Spacer()
                ShareAFeedbackLocalizedView().font(.body.bold()).foregroundColor(.green)
                Spacer()
            }
        )
    }
    
    var measurementsUnit: some View {
        HStack {
            SettingsRowView.labelWith(name: "measurementsUnitString".local())
            Picker("", selection: $viewModel.settings.measurementsUnit) {
                ForEach(MeasurementsUnit.allCases, id: \.self) {
                    Text($0.description)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}
