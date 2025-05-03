//
//  MainButtonViews.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 03/10/2020.
//

import Foundation
import SwiftUI
import SharedPkg
import MirrorHRTelemetryPackage

struct RealTimeMonitorStartStopButtonView: View {
    @EnvironmentObject private var mirrorHR: MirrorHRMainClass
    @EnvironmentObject var deviceOrientation: DeviceOrientation
    @ObservedObject private var dataSourceManager: DataSourceManager = .shared
    
    var body: some View {
        VStack (alignment: .center) {
            contentForDataSource(dataSource: dataSourceManager.dataSource)
        }
    }
    
    @ViewBuilder
    private func contentForDataSource(dataSource: DataSource) -> some View {
        switch dataSource {
        case .diaryOnly:
            diaryOnlyView
        case .appleWatchPairedOnly,
                .appleWatchAndInternetKeyEventsStreamingAsServer,
                .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            StartStopToggleView(realTimeMsg: "realTimeMsg".local())
        case .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
            StartStopRemoteBPMStreamingButtonView()
        }
    }
    
    private var diaryOnlyView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text("RemoteMustHaveWatchInfoMsg".local())
        }
        .font(.headline)
        .foregroundStyle(.red)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(defaultCornerRadius)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func StartStopToggleView(realTimeMsg: String) -> some View {
        Toggle(isOn: $mirrorHR.isRunning) {
            Text(realTimeMsg).font(.body.bold())
        }
        .toggleStyle(StartStopToggleStyle())
    }
}

struct ManualAlarmButtonView: View {
    @ObservedObject private var freshBpm = FreshBPM.shared
    var withLastUpdate: Bool
    
    var body: some View {
        HStack {
            if withLastUpdate {
                VStack {
                    Text(lastBpmMsg)
                    LastUpdateWas()
                    Text(secsAgoMsg)
                }
                .font(.caption)
            }
            Button(action: {
                dispatchMainEvent(.manualAlarm(metaData: .init(name: "BPM", valueInt: freshBpm.bpm)), "ManualAlarmButtonView")
            }, label: {
                Label("", systemImage: "bolt.heart")
                    .font(.title)
            })
            .foregroundColor(stefiAzure)
        }
    }
}

struct AlarmStatusButtonView: View {
    @ObservedObject var eventsManager = RealTimeEventsManager.shared
    @EnvironmentObject private var mirrorHR: MirrorHRMainClass
    @ObservedObject private var dataSourceManager: DataSourceManager = .shared
    
    var body: some View {
        switch dataSourceManager.dataSource {
        case .diaryOnly, .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
            EmptyView()
        case .appleWatchPairedOnly,  .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            Toggle(isOn: $eventsManager.alarmIsSilent) {
                Text(alarmMsg)
                    .font(.body.bold())
            }
            .toggleStyle(AlarmCheckmarkToggleStyle())
            .disabled(!mirrorHR.isRunning)
            .opacity(mirrorHR.isRunning ? 1 : 0.2)
        }
    }
}

struct StartStopToggleStyle: ToggleStyle {
    @EnvironmentObject private var mirrorHR: MirrorHRMainClass
    @EnvironmentObject private var deviceOrientation: DeviceOrientation
    @State private var showConfirmation: Bool = false
    let imgStart = "play.circle.fill"
    let imgStop = "stop.circle.fill"
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if deviceOrientation.orientation == .portrait {
                configuration.label
            }
            
            Rectangle()
                .foregroundColor(configuration.isOn ? .green : .secondary)
                .frame(width: 51, height: 31, alignment: .center)
                .overlay(
                    Image(systemName: configuration.isOn ? imgStop : imgStart)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .padding(.all, 3)
                        .offset(x: !configuration.isOn ? -11 : 11, y: 0)
                ).cornerRadius(defaultToggleCornerRadius)
                .onTapGesture {
                    if configuration.isOn {
                        showConfirmation = true
                    } else {
                        mirrorHR.startStopFrom(source: .iPhone)
                    }
                }
        }
        .alert(confirmString, isPresented: $showConfirmation, actions: {
            Button(role: .destructive) {
                mirrorHR.startStopFrom(source: .iPhone)
            } label: {
                Text(yesString)
            }
        })
    }
}

struct AlarmCheckmarkToggleStyle: ToggleStyle {
    @EnvironmentObject private var deviceOrientation: DeviceOrientation
    let mutedImg = "speaker.slash.circle.fill"
    let alarmOnImg = "speaker.wave.2.circle.fill"
    @State private var showConfirmation: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if deviceOrientation.orientation == .portrait {
                configuration.label
            }
            Rectangle()
                .foregroundColor(configuration.isOn ? .red : .green)
                .frame(width: 51, height: 31, alignment: .center)
                .overlay(
                    Image(systemName: configuration.isOn ? mutedImg : alarmOnImg)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .padding(.all, 3)
                        .offset(x: configuration.isOn ? -11 : 11, y: 0)
                ).cornerRadius(defaultToggleCornerRadius)
                .onTapGesture {
                    if !configuration.isOn {
                        showConfirmation = true
                    } else {
                        configuration.isOn.toggle()
                    }
                }
                .alert(confirmString, isPresented: $showConfirmation, actions: {
                    Button(role: .destructive) {
                        configuration.isOn.toggle()
                    } label: {
                        Text(yesString)
                    }
                })
        }
    }
}

public struct RemoteCommandsTestView: View {
    @ObservedObject private var dataSourceManager: DataSourceManager = .shared
    public var body: some View {
        VStack {
//            let careGiverName: String = TelemetryHeader.getUserName()
//            let careGiverID: String = TelemetryHeader.getUserID()
//            let patient = CareGiversManager.shared.getActivePatient()
//            let kidID: String = patient?.id.uuidString ?? TelemetryHeader.shared.currentUserID // for testing purposes only
//            let kidName: String = patient?.name ?? "cippaLippa"
//            Text("this ID: \(TelemetryHeader.shared.currentUserID)")
//            Text("Kid: \(kidName) \(kidID)")
//            Text("caregivername: \(careGiverName)")
//            Text("careGiverID: \(careGiverID)")
            
            Text("MainClass Status: \(MirrorHRMainClass.shared.status)")
            Text("DataSource: \(dataSourceManager.dataSource.rawValue)")
            Text("RemoteServerStatus: \(dataSourceManager.remoteServerStatus)")
//            let startcommand: RemoteCommand = .init(command: .startSteamingToCareGiver, careGiverName: careGiverName, careGiverID: careGiverID, kidID: kidID, kidName: kidName)
//            
//            let stopCommand: RemoteCommand = .init(command: .stopStreamingToCareGiver, careGiverName: careGiverName, careGiverID: careGiverID, kidID: kidID, kidName: kidName)
//            
//            let checkStatusCommand: RemoteCommand = .init(command: .careGiverCheckingRealTimeStatus, careGiverName: careGiverName, careGiverID: careGiverID, kidID: kidID, kidName: kidName)
            
            Button("Send Start Symptom") {
                MsNotificationHubViewModel.shared.testServer(command: .startSteamingToCareGiver)
            }
            Button("Send Stop symptom") {
                MsNotificationHubViewModel.shared.testServer(command: .stopStreamingToCareGiver)
            }
            
            Button("Send Check Status ") {
                MsNotificationHubViewModel.shared.testServer(command: .careGiverCheckingRealTimeStatus)
            }
            
            Button("Unknown Server Status") {
                dataSourceManager.changeRemoteserverStatus(to: .unknown)
            }
            
            Button("Chek local for symptom") {
                SymptomsManager.shared.appendSymptomLog(SymptomLog(.alarmFired))
                let aps: [AnyHashable: Any] = [
                    "aps": [
                        "localizedName": "Alarm fired",
                        "header": [
                            "userID": "F94A2BEE-FFCF-4D24-90E9-12FDE311D35F",
                            "buildVersion": "11",
                            "environment": "IS_DEBUG",
                            "countryCode": "IT",
                            "sessionID": "87C7F8E9-FAC9-4CD7-8DDC-8D7FBB14CE87",
                            "researchID": "",
                            "userType": "Returning user",
                            "timeStamp": "12-06-2024 20:09:47",
                            "appVersion": "15",
                            "caregivers": [
                                [
                                    "worldLocation": NSNull(),
                                    "id": "F94A2BEE-FFCF-4D24-90E9-12FDE311D35F",
                                    "isActive": true,
                                    "name": "Self caregiver",
                                    "type": "caregiver"
                                ]
                            ],
                            "systemVersion": "17.5",
                            "language": "en"
                        ],
                        "toBeNotified": true,
                        "event": "sympt_AlarmFired",
                        "notes": "",
                        "body": "Alarm fired (20:09 - 20:09)",
                        "symptom": "sympt_AlarmFired",
                        "soundName": "gentle.mp3",
                        "telemetryVersion": "4.0",
                        "value": "",
                        "isCritical": true,
                        "latitude": "37.785834",
                        "title": "Mario - MirrorHR",
                        "kidName": "Mario",
                        "longitude": "-122.406417",
                        "eventType": "SymptomsLogged",
                        "startDate": "12-06-2024 20:09:11",
                        "endDate": "12-06-2024 20:09:11",
                        "kidID": "F94A2BEE-FFCF-4D24-90E9-12FDE311D35F"
                    ]
                ]
                
                MsNotificationHubViewModel.shared.handleRemoteNotification(userInfo: aps)
            }
            
            Button("check location") {
                let jsonString = "{\"kidName\":\"Vero\",\"kidID\":\"F94A2BEE-FFCF-4D24-90E9-12FDE311D356\",\"careGiverID\":\"65449937-E410-474D-82B5-579DDAB968A0\",\"careGiverName\":\"Roberdan 15 pro\",\"command\":\"patientReplyHereIam\",\"longitude\":\"-122.406417\",\"latitude\":\"37.785834\"}"
                let testCommand: RemoteCommand = RemoteCommand(command: .patientReplyHereIam, careGiverName: "Roberdan 15 pro", careGiverID: "65449937-E410-474D-82B5-579DDAB968A0", kidID: "657EBB72-D407-4323-88A9-5853F77734A6", kidName: "Finto")
//                let testJson = testCommand.jsonString
//                let reverseCommand = RemoteCommand.loadFromJson(jsonString: testJson)
                let loadFroJ = RemoteCommand.loadFromJson(jsonString: jsonString)
                MsNotificationHubViewModel.shared.handleRemoteCommand(loadFroJ ?? testCommand)
            }
            
            Button("Reply client is off") {
                MsNotificationHubViewModel.shared.testServer(command: .patientReplyRealTimeStatusIsOff)
            }
            
            Button("Reply client is on") {
                MsNotificationHubViewModel.shared.testServer(command: .patientReplyRealTimeStatusIsOn)
            }
        }
        .lineLimit(nil)
        .multilineTextAlignment(.leading)
        .font(.caption)
    }
}

public struct StartStopRemoteBPMStreamingButtonView: View {
    @ObservedObject private var dataSourceManager: DataSourceManager = .shared
    let careGiversManager: CareGiversManager = .shared

    public var body: some View {
        VStack(alignment: .center) {
            switch dataSourceManager.remoteServerStatus {
            case .running, .stopped, .ready:
                Toggle(isOn: $dataSourceManager.remoteStreamingStartStopToggle) { }
                    .toggleStyle(StartStopInternetStreamingToggleStyle())
                    .padding()
            case .unknown:
                if CareGiversManager.shared.getActivePatient() != nil {
                    MyActionableButton(
                        idString: "StartStopRemoteBPMStreamingButtonView", 
                        activeMsg: "RemoteCheckStatusActiveMsg".local(),
                        disabledMsg: "RemoteCheckingStatusDisabledMsg".local(),
                        action: {
                            careGiversManager.sendRemoteCommandToActivePatient(command: .careGiverCheckingRealTimeStatus)
                        }
                    )
                }
            }
        }
    }
}

struct StartStopInternetStreamingToggleStyle: ToggleStyle {
    @ObservedObject private var mirrorHR: MirrorHRMainClass = .shared
    @ObservedObject private var deviceOrientation: DeviceOrientation = .shared
    @ObservedObject private var dataSourceManager: DataSourceManager = .shared
    
    let imgStart = "play.circle.fill"
    let imgStop = "stop.circle.fill"
    @State var isLoading: Bool = false
    
    func returnMsg() -> (msg: String, offColor: Color) {
        switch dataSourceManager.remoteServerStatus {
        case .running:
            return ("RemoteRunningMsgMaxTime".local(), .secondary)
        case .stopped:
            return ("RemoteRealTimeIsNotRunningMsg".local(), .secondary)
        case .unknown:
            return ("RemoteTryReceivingBpmsMsg".local(), .orange)
        case .ready:
            return ("RemoteReceivingBpmsFewMinsOnlyMsg".local(), .secondary)
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let isDisabled: Bool = isLoading || dataSourceManager.remoteServerStatus == .stopped
        let returnMsg = returnMsg()
        
        HStack {
            if deviceOrientation.orientation == .portrait {
                Text(returnMsg.msg)
                    .font(.body.bold())
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            
            ZStack {
                Rectangle()
                    .foregroundColor(configuration.isOn ? .green : returnMsg.offColor)
                    .frame(width: 51, height: 31, alignment: .center)
                    .overlay(
                        Image(systemName: configuration.isOn ? imgStop : imgStart)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .padding(.all, 3)
                            .offset(x: !configuration.isOn ? -11 : 11, y: 0)
                    ).cornerRadius(defaultToggleCornerRadius)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 51, height: 31, alignment: .center)
                        .background(Color.black.opacity(0.5))
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                }
            }
            .onTapGesture {
                guard !isLoading else { return } // Prevent multiple taps
                isLoading = true
                DispatchQueue.main.async {
                    mirrorHR.startStopFrom(source: .remoteStreaming)
                    isLoading = false
                    configuration.isOn.toggle()
                    // IMPORTANT: it sends the remote command to the kids
                    CareGiversManager.shared.sendRemoteCommandToActivePatient(command: configuration.isOn ? .startSteamingToCareGiver : .stopStreamingToCareGiver)
                }
            }
        }
        .disabled(isDisabled)
        .foregroundStyle(isDisabled ? .tertiary : .primary)
    }
}
