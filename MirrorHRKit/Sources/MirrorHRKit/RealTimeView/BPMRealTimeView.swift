//
//  BPMRealtimeView.swift
//  
//
//  Created by Roberto D’Angelo on 31/07/22.
//

import Foundation
import SwiftUI
import RoberdanToolBox
import SharedPkg

struct BPMRealtimeView: View {
    @ObservedObject var lastBPM = FreshBPM.shared
    @ObservedObject private var kISSFlowManager = KISSFlowManager.shared
    @ObservedObject private var keyFlowThresholds = KeyFlowThresholds.shared
    @ObservedObject private var deviceOrientation: DeviceOrientation = .shared
    @ObservedObject private var mirrorHR: MirrorHRMainClass = .shared
    @ObservedObject private var eventsManager = RealTimeEventsManager.shared
    @ObservedObject private var dataSourceManager = DataSourceManager.shared
    @EnvironmentObject var showSheet: SheetViewController

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DetectOrientation()
            if deviceOrientation.orientation == .portrait {
                // MARK: Portrait
                HStack {
                    WatchStatusView(isPortrait: true)
                    if eventsManager.showLowBatterySymbol {
                        WatchLowBatteryStatus()
                    }
                    Spacer()
                    if mirrorHR.isRunning {
                        HStack {
                            Text(lastBpmMsg)
                            LastUpdateWas()
                            Text(secsAgoMsg)
                        }
                    } else {
                        Label(bPmLabelMsg, systemImage: dataSourceManager.dataSource == .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer ? "arrow.up.heart.fill": "heart.fill")
                    }
                    Spacer()
                    Button(action: {
                        DispatchQueue.main.async {
                            showSheet.reset()
                            showSheet.navigationTitle = "keySettingsNavigationTitleMsg".local()
                            showSheet.sheetContentView = AnyView(KeySettingsView())
                            showSheet.okActionText = closeButtonString
                            showSheet.sheetVisible = true
                        }
                    }, label: {
                        Label("", systemImage: "slider.horizontal.3")
                            .foregroundColor(.accentColor)
                    })
                }
                .font(.body)
                .padding([.top, .horizontal])
                .cornerRadius(defaultViewCornerRadius, corners: [.topLeft, .topRight])
                
                if eventsManager.handleAlarmView {
                    HStack(alignment: .center) {
                        Spacer()
                        CoreBPMView()
                        Spacer()
                        RealTimeViewCommandBar().padding()
                    }
                } else {
                    VStack(spacing: 0) {
                        CoreBPMView()
                        RealTimeViewCommandBar()
                            .padding([.bottom, .horizontal])
// #if DEBUG
// TODO: remove the line below, it's for testing purposes only
//    RemoteCommandsTestView()
// #endif
                    }
                }
            } else { // MARK: Landscape
                HStack {
                    if !eventsManager.handleAlarmView {
                        NightClockView(textColor: eventsManager.handleAlarmView ? .primary : .secondary, isAnAlarm: false)
                            .padding(.horizontal)
                    }
                    Spacer()
                    CoreBPMView()
                    Spacer()
                    if mirrorHR.isRunning, eventsManager.handleAlarmView {
                        HStack {
                            VStack {
                                Text(lastBpmMsg)
                                LastUpdateWas()
                                Text(secsAgoMsg)
                            }
                            RealTimeViewCommandBar()
                        }
                        .padding(.horizontal)
                    }
                    
                    if !eventsManager.handleAlarmView {
                        RealTimeViewCommandBar()
                            .padding()
                    }
                }
                .padding(.horizontal)
                .cornerRadius(defaultViewCornerRadius, corners: [.bottomLeft, .bottomRight])
            }
        }
    }
}
