//
//  RealTimeView.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 28/09/2020.
//

import SwiftUI
import SharedPkg
import RoberdanToolBox

struct RealTimeView: View {
    @ObservedObject private var mirrorHR: MirrorHRMainClass = .shared
    @ObservedObject private var deviceOrientation: DeviceOrientation = .shared
    @ObservedObject private var eventsManager = RealTimeEventsManager.shared
    @ObservedObject private var alarm = Alarm.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if deviceOrientation.orientation == .portrait {
                // MARK: Portrait
                VStack {
                    BPMRealtimeView()
                    if eventsManager.handleAlarmView {
                        RealTimeAlarmHandlingView()
                    }
                    mirrorHR.realTimeChart
                        .onChange(of: colorScheme) { _ in
                            DispatchQueue.main.async {
                                mirrorHR.realTimeChart.sciChartSurface.backgroundColor = UIColor.systemBackground
                            }
                        }
                }
                .sheet(isPresented: $eventsManager.isShowingMailView) {
                    SendEmailToDocSheetView(isShowingMailView: $eventsManager.isShowingMailView, attachmentPath: eventsManager.xlsImportExportFullPath, lastDays: 2)
                }
            } else {
                // MARK: LANDSCAPE
                HStack(alignment: .top) {
                    VStack(spacing: 0) {
                        BPMRealtimeView()
                        mirrorHR.realTimeChart
                            .onChange(of: colorScheme) { _ in
                                DispatchQueue.main.async {
                                    mirrorHR.realTimeChart.sciChartSurface.backgroundColor = UIColor.systemBackground
                                }
                            }
                    }
                    
                    if eventsManager.handleAlarmView {
                        RealTimeAlarmHandlingView()
                    }
                }
                .background(Color(UIColor.systemBackground))
                .edgesIgnoringSafeArea(.all)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        .modifier(MyRadialViewModifier(isList: false))

        .onAppear {
            askHealthAuthorization(healthAuthorizationManager: HealthAuthorizationManager())
        }
    }
}

struct RealTimeViewCommandBar: View {
    @ObservedObject private var keyFlowThresholds = KeyFlowThresholds.shared
    @ObservedObject private var mirrorHR: MirrorHRMainClass = .shared
    @ObservedObject private var communicationManager: CommunicationManagerIoS = .shared
    @ObservedObject private var settings: ProfileGenericSettings = .shared
    @ObservedObject private var deviceOrientation: DeviceOrientation = .shared
    
    private var isError: Bool {
        if case .error(_) = mirrorHR.status {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        let opacity = isError ? 0.2 : 1.0
        Group {
            if deviceOrientation.orientation == .portrait {
                HStack {
                    RealTimeMonitorStartStopButtonView()
                        .opacity(opacity)
                    Spacer()
                    AlarmStatusButtonView()
                }
                .disabled(isError)
            } else {
                VStack(alignment: .trailing) {
                    RealTimeMonitorStartStopButtonView()
                        .opacity(opacity)
                    AlarmStatusButtonView()
                }
                .disabled(isError)
            }
        }
    }
}

struct MainChartLegendaView: View {
    var body: some View {
        HStack(alignment: .top) {
            Text(legendaLabelMsg)
                .font(.caption)
            VStack(alignment: .center) {
                Image(systemName: "rectangle.fill")
                    .foregroundColor(FlowStages.alarm.chartColor.color)
                Text(alarmMsg)
                    .font(.caption)
            }
            
            VStack(alignment: .center) {
                Image(systemName: "rectangle.fill")
                    .foregroundColor(FlowStages.warning.chartColor.color)
                Text(warningMsg)
                    .font(.caption)
            }
            
            VStack(alignment: .center) {
                Image(systemName: "rectangle.fill")
                    .foregroundColor(FlowStages.deepSleep.chartColor.color)
                Text(deepSleepLabelMsg)
                    .font(.caption)
            }
            
            VStack(alignment: .center) {
                Image(systemName: "rectangle.fill")
                    .foregroundColor(FlowStages.lightSleep.chartColor.color)
                Text(lightSleepLabelMsg)
                    .font(.caption)
            }
            VStack(alignment: .center) {
                Image(systemName: "rectangle.fill")
                    .foregroundColor(FlowStages.normal.chartColor.color)
                Text(awakeLabelMsg)
                    .font(.caption)
            }
        }.multilineTextAlignment(.center)
    }
}
