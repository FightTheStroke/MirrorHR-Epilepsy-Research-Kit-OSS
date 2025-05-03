//
//  CoreBPMView.swift
//
//
//  Created by Roberto D’Angelo on 31/07/22.
//

import Foundation
import SwiftUI
import SharedPkg
import RoberdanToolBox
import MirrorHRTelemetryPackage

struct CoreBPMView: View {
    @ObservedObject private var kISSFlowManager = KISSFlowManager.shared
    @EnvironmentObject private var mirrorHR: MirrorHRMainClass
    @EnvironmentObject private var deviceOrientation: DeviceOrientation
    @ObservedObject private var dataSourceManager: DataSourceManager = .shared
    
    var body: some View {
        HStack(alignment: .center) {
            switch mirrorHR.status {
            case .stopped:
                StoppedMsgView()
            case .running:
                RunningView()
            case .booting:
                ProgressView(bootingProgressMsg)
                    .scaleEffect(1, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    .foregroundColor(.primary)
            case .delayedStop:
                ProgressView()
                
            case .error(let mirrorHRError):
                switch mirrorHRError {
                case .watchAppNotInstalled, .watchNotPaired, .cantCommunicateWithWatch, .cantStartTheSession:
                    errorLabel(with: mirrorHRError.description, image: "exclamationmark.octagon", color: stefiRed)
                case .errorFromTheWatch(let errorMessage):
                    errorLabel(with: "\(mirrorHRError.description) \(errorMessage)", image: "exclamationmark.octagon", color: stefiRed)
                case .watchNotReachable:
                    VStack(alignment: .center) {
                        errorLabel(with: mirrorHRError.description, image: "exclamationmark.triangle", color: stefiRed)
                        Image("watchfacestart")
                    }
                case .soSorryError, .healthAuthorization, .remoteMirrorHRNotActive:
                    errorLabel(with: mirrorHRError.description, image: "exclamationmark.octagon", color: stefiRed)
                }
            }
        }
    }
    
    func errorLabel(with text: String, image: String, color: Color) -> some View {
        Label(text, systemImage: image)
            .foregroundColor(color)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .font(.body.bold())
            .padding(.bottom)
    }
}

struct StoppedMsgView: View {
    @ObservedObject private var dataSourceManager: DataSourceManager = .shared
    @ObservedObject private var careGiversManager: CareGiversManager = .shared
    
    private func returnMsg() -> String {
        if dataSourceManager.dataSource.isClientOnly {
            switch dataSourceManager.remoteServerStatus {
            case .ready: return "RealTimeRemoteActiveMsg".local()
            case .stopped: return "RealTimeRemoteOffMsg".local()
            case .unknown:
                if careGiversManager.getActivePatient()?.id.uuidString != nil {
                    return "RemoteRealtimeUnkwongMsg".local()
                } else {
                    return "RemoteNoPatientSelectedMsg".local()
                }
            case .running: 
                return "RemoteFetchingDataMsg".local()
            }
        } else {
            return realTimeOffMsg
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(returnMsg())
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .foregroundColor(.primary)
                .padding(.horizontal)
        }
    }
}

struct RunningView: View {
    @ObservedObject private var kISSFlowManager = KISSFlowManager.shared
    @ObservedObject var lastBPM = FreshBPM.shared

    var body: some View {
        if kISSFlowManager.currentStage == .noLocalData {
            FlashingMessageView(message: "NoDataEventStringV2".local(), captionMsg: "NoDataEventCaptionV2".local(), goToWebURL: "https://support.apple.com/en-us/HT204562")
        } else if kISSFlowManager.currentStage == .noInternetStreamData {
            FlashingMessageView(message: "RemoteNoDataKeyMsg".local(), captionMsg: "RemoteNoDataCaptionMsg".local(), goToWebURL: nil)
        } else {
            if lastBPM.bpm != 0 {
                HStack(alignment: .center) {
                    Text("\(lastBPM.bpm)")
                        .font(.system(size: largeTitleSize).weight(.black))
                        .foregroundColor(lastBPM.color)
                        .contentTransition(.numericText())
                }
            } else {
                ProgressView()
            }
        }
    }
}
