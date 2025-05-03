//
//  WatchStatusView.swift
//
//
//  Created by Roberto D’Angelo on 04/09/22.
//

import Foundation
import SwiftUI
import SharedPkg
import MirrorHRTelemetryPackage

struct WatchStatusView: View {
    @ObservedObject var communicationManagerIos: CommunicationManagerIoS = .shared
    @ObservedObject var dataSourceManager: DataSourceManager = .shared
    
    @State var isPortrait: Bool
    
    @State private var showingAlert = false
    @State private var showPeersAlert = false
    
    var body: some View {
        Group {
            if isPortrait {
                HStack {
                    dataSourceIcons()
                }
            } else {
                VStack {
                    dataSourceIcons()
                }
            }
        }
    }
    
    @ViewBuilder
    func dataSourceIcons() -> some View {
        switch dataSourceManager.dataSource {
        case .diaryOnly:
            EmptyView() // nothing to show here, using EmptyView for clarity
        case .appleWatchPairedOnly:
            watchIcon
        case .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            Group {
                if isPortrait {
                    HStack {
                        watchIcon
                        InternetStreamingAsServerIconMenu()
                    }
                } else {
                    VStack {
                        watchIcon
                        InternetStreamingAsServerIconMenu()
                    }
                }
            }
        case .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
            InternetStreamingAsClientIconMenu()
        }
    }
    
    @ViewBuilder
    var watchIcon: some View {
        VStack {
            Menu {
                if communicationManagerIos.watchAppInstalledAndPaired {
                    buildWatchInfoMenu()
                } else {
                    buildNoAppInfoMenu()
                }
            } label: {
                (communicationManagerIos.watchAppInstalledAndPaired ? appleWatchWavesImage : noApp)
                    .foregroundColor(communicationManagerIos.watchAppInstalledAndPaired ? stefiGreen : stefiRed)
            }
        }
    }
    
    @ViewBuilder
    func buildWatchInfoMenu() -> some View {
        VStack {
            Text("StreamingConnectedTo".local())
            Text(communicationManagerIos.watchDeviceInfo?.deviceName ?? "unknown")
        }
    }
    
    func buildNoAppInfoMenu() -> some View {
        VStack {
            Text("watchMainErrorMsg".local())
                .lineLimit(nil)
        }
    }
}

struct WatchLowBatteryStatus: View {
    let lowWatchBattery = Image(systemName: "battery.25")
    
    var body: some View {
        lowWatchBattery
            .foregroundStyle(stefiRed)
    }
}

struct InternetStreamingAsClientIconMenu: View {
    @ObservedObject var networkMonitor: NetworkMonitor = .shared
    @ObservedObject var careGiversManager: CareGiversManager = .shared
    @State var selectedPatientID: UUID?

    var body: some View {
        VStack {
            Menu {
                if networkMonitor.isConnected {
                    Text("RemoteConnectedAndReceivingMsg".local())
                    // patients
                    if careGiversManager.patients.isEmpty {
                        EmptyCardView(message: "RemoteNoPatientAssociatedMsg".local())
                    } else {
                        Picker("RemoteSelectActivePatientMsg".local(), selection: $selectedPatientID) {
                            ForEach(careGiversManager.patients) { patient in
                                Text(patient.name).tag(patient.id as UUID?)
                            }
                        }
                        .onChange(of: selectedPatientID) { newValue in
                            if let id = newValue {
                                if let patient = careGiversManager.patients.first(where: { $0.id == id }) {
                                    careGiversManager.activatePatient(name: patient.name, uuid: patient.id, currentStatus: false)
                                }
                            } else {
                                careGiversManager.deactivateAllPatients()
                            }
                        }
                    }
                } else {
                    Text("RemoteThereIsNoInternetConnectionMsg".local())
                        .foregroundStyle(stefiRed)
                }
            } label: {
                if careGiversManager.patients.count > 1, let patient = careGiversManager.getActivePatient() {
                    Label("\(patient.name.truncated(to: 5))", systemImage: "person.circle")
                        .foregroundStyle(networkMonitor.isConnected ? .accentColor : stefiRed)
                }
            }
           
        }
        .onAppear {
            selectedPatientID = careGiversManager.getActivePatient()?.id
        }
    }
}

struct InternetStreamingAsServerIconMenu: View {
    @ObservedObject var networkMonitor: NetworkMonitor = .shared
    @ObservedObject var careGiversManager: CareGiversManager = .shared
    @ObservedObject var dataSourceManager: DataSourceManager = .shared
    
    @State private var foreGroundColor: Color = .accentColor

    var body: some View {
        Menu {
            if networkMonitor.isConnected {
                Text("RemoteConnectedToInternetMsg".local())
                Text("RemoteSendingDataToMsg".local())
                // patients
                if careGiversManager.caregivers.isEmpty {
                    EmptyCardView(message: "RemoteNoCaregiverAssociatedMsg".local())
                } else {
                        ForEach(careGiversManager.caregivers) { caregiver in
                            Text(caregiver.name).tag(caregiver.id as UUID?)
                        }
                }
            } else {
                Text("RemoteThereIsNoInternetConnectionMsg".local())
                    .foregroundStyle(stefiRed)
            }
        } label: {
            caregiverImage
                .foregroundStyle(foreGroundColor)
        }
        .onChange(of: networkMonitor.isConnected) { newValue in
            if !newValue {
                foreGroundColor = stefiRed
            }
        }
        .onChange(of: dataSourceManager.dataSource) { newValue in
            var returnColor: Color = .primary
            switch newValue {
                
            case .appleWatchPairedOnly, .diaryOnly, .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
                break
            case .appleWatchAndInternetKeyEventsStreamingAsServer:
                break
            case .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
                returnColor = stefiGreen
            }
            self.foreGroundColor = returnColor
        }
    }
}
