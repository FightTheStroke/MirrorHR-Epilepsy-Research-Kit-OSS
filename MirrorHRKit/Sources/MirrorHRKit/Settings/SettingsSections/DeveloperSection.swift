//
//  DeveloperSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg
import MirrorHRTelemetryPackage

extension SettingsView {
    var developerSection: SettingsSection {
        SettingsSection(
            id: "Developer",
            header: "Developer".local(),
            image: "ant",
            rows: [.custom(name: developerMode, AnyView(DeveloperModeView()))]
        )
    }
}

struct DeveloperModeView: View {
    @ObservedObject var settings = ProfileGenericSettings.shared
    @State private var showConfirmMessage: Bool = false
    @State private var alertConfirmBody: String = ""
    @State private var alertConfirmAction: () -> Void = {}
    
    var body: some View {
        VStack {
            Toggle(isOn: $settings.debugMode) {
                Text(developerMode.uppercased())
            }

            if settings.debugMode {
                List {
                    Divider()
                    HStack {
                        Image(systemName: "exclamationmark.circle").font(.title2)
                        Text(resetAllMsg.uppercased())
                            .font(.body.bold())
                            .fixedSize(horizontal: false, vertical: true).multilineTextAlignment(.center)
                    }
                    .padding()
                    .foregroundColor(.red)
                    .onTapGesture {
                        showConfirmMessage = true
                        alertConfirmBody = resetAllMsg.uppercased()
                        alertConfirmAction = sendResetEraseToEverySubscriber
                    }
                } 
                .alert(isPresented: $showConfirmMessage) {
                    Alert(
                        title: Text(confirmString),
                        message: Text(alertConfirmBody),
                        primaryButton: .default(Text(noString), action: {
                            showConfirmMessage = false}),
                        secondaryButton: .destructive(Text(yesString), action: {
                            alertConfirmAction()
                            showConfirmMessage = false
                        })
                    )
                }
            }
        }
    }
}
