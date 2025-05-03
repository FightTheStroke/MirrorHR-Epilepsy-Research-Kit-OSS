//
//  File.swift
//
//
//  Created by Roberto D’Angelo on 21/08/22.
//

import Combine
import Foundation
import MirrorHRTelemetryPackage
import RoberdanToolBox
import SharedPkg
import SwiftUI

final class FreshBPM: ObservableObject, Codable {
    static var shared = FreshBPM()
    
    private let mirrorHRMainClass: MirrorHRMainClass = MirrorHRMainClass.shared
    private let kissFlowManager: KISSFlowManager = KISSFlowManager.shared
    private let dataSourceManager: DataSourceManager = .shared
    private var telemetryBpmConsent: Bool = Telemetries.symptomsLogged(
        notificationSupportStruct: NotificationSupportStruct()
    ).isOn
    
    @Published var bpm: Int = 0 {
        didSet {
            DispatchQueue.main.async { [self] in
                switch mirrorHRMainClass.status {
                case .stopped:
                    // Basically, if it receives a bpm while the app is stopped it means there was a communication de-sync, so it's safer to align the status and stop also the watch
                    switch dataSourceManager.dataSource {
                    case .diaryOnly:
                        break
                    case .appleWatchPairedOnly,
                            .appleWatchAndInternetKeyEventsStreamingAsServer,
                            .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
                        if kissFlowManager.currentStage == .stopped {
                            mirrorHRMainClass.sendStopFromIphoneToWatch()
                        }
                        // remote start and stop it's handled with RemoteServerStatus and remoteStreamingStartStopToggle
                    case .internetStreamingAsClientForKeyEventsOnly:
                        break
                    case .internetStreamingAsClientForKeyEventsAndBPMs:
                        break
                    }
                case .running:
                    // app is running so let's just analyze the fresh bpm
                    analyzeFreshBPM()
                case let .booting(source: source):
                    // good: app is booting and it's receiving a fresh bpm, let's change status and analyze the new bpm
                    mirrorHRMainClass.status = .running(source: source)
                    analyzeFreshBPM()
                case .delayedStop:
                    // no action required on the phone app as delayedStop applies only to the watch
                    break
                case let .error(error: error):
                    // updated on Aug 8 2020: if there is a communication error this class should do nothing and let the main class handle it, or it will start an infinite loop of notification errors
                    // if main app status is on error and still  I receive a bpm I should be able to continue the session automatically, usually it's a communication error
                    switch error {
                    case .watchAppNotInstalled, .watchNotReachable,
                            .watchNotPaired, .cantCommunicateWithWatch,
                            .cantStartTheSession, .errorFromTheWatch:
                        mirrorHRMainClass.status = .booting(source: .appleWatch)
                        analyzeFreshBPM()
                    case .soSorryError, .healthAuthorization,
                            .remoteMirrorHRNotActive:
                        break
                    }
                }
            }
        }
    }
    
    @Published var eventStage: FlowStages = .stopped
    @Published var color: Color = FlowStages.stopped.chartColor.color
    @Published var receivedAt: TimeInterval = NSTimeIntervalSince1970
    
    private var lastBPMReceivedAt: TimeInterval = 0
    private var sentAt: TimeInterval = NSTimeIntervalSince1970
    var sessionID: UUID = UUID()
    
    public init() {
    }
    
    func landFreshBPM(_ bpmFromWatch: BPMFromWatch) {
        if !DataSourceManager.shared.dataSource.shouldReceiveFreshBPMs {
            return
        }
        
        DispatchQueue.main.async { [self] in
            guard bpmFromWatch.bpm != 0 else {
                return
            }
            bpm = bpmFromWatch.bpm
            sentAt = bpmFromWatch.detectedAt
        }
        let metaData: EventMetaData = .init(
            name: "LASTBPMAT", valueTimeInterval: bpmFromWatch.detectedAt)
        dispatchMainEvent(.lastBPM(bpm, metaData: metaData), "FreshBPM")
    }
    
    // MARK: analyzeFreshBPM is where new received BPMs are analyzed and a lot of magic happens
    func analyzeFreshBPM() {
        let gotItNow: Date = Date()
        switch dataSourceManager.dataSource {
        case .diaryOnly, .internetStreamingAsClientForKeyEventsOnly:
            return  // it should not receive BPMs when in diaryOnly mode or when only receiving key events
            
        case .appleWatchPairedOnly,
                .appleWatchAndInternetKeyEventsStreamingAsServer,
                .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer,
                .internetStreamingAsClientForKeyEventsAndBPMs:
            
            let eventStage: FlowStages
            if dataSourceManager.dataSource
                == .internetStreamingAsClientForKeyEventsAndBPMs
            {
                eventStage = KISSFlowManager.shared.analyzeFlowForRemoteBPM(bpm)
            } else {
                eventStage = KISSFlowManager.shared.analyzeFlowForLocalBPM(bpm)
            }
            
            commonBPMAnalysis(eventStage: eventStage, gotItNow: gotItNow)
            
            if dataSourceManager.dataSource
                == .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer
            {
                let bpmToBeSent: RemoteBPM = RemoteBPM(
                    bpmValue: bpm, date: gotItNow)
                dispatchTelemetryEvent(
                    event: .remoteBPM(remoteBPM: bpmToBeSent))
            }
        }
    }
    
    private func commonBPMAnalysis(eventStage: FlowStages, gotItNow: Date) {
        
        // Verify if there is data in the series
        if mirrorHRMainClass.bpmDataSeries.count > 0 {
            // Get the last value of `x`
            let lastXValue = mirrorHRMainClass.bpmDataSeries.xValues.value(
                at: mirrorHRMainClass.bpmDataSeries.count - 1)  // Last x value
            
            // Ensure that `lastXValue` is a `Date` and is less than the new value `gotItNow`
            if let lastDate = lastXValue as? Date, gotItNow <= lastDate {
                debugLog(
                    "Attempting to append an out-of-order value to the data series",
                    isImportant: true, module: "commonBPMAnalysis")
                return
            }
        }
        
        // Verify the validity of the `bpm` value
        guard bpm >= 0, bpm <= 300 else {
            debugLog(
                "Invalid BPM value: \(bpm)", isImportant: true,
                module: "commonBPMAnalysis")
            return
        }
        color = eventStage.chartColor.color
        mirrorHRMainClass.bpmDataSeries.append(x: gotItNow, y: bpm)
        
        // Zoom only if there are at least two points
        if mirrorHRMainClass.bpmDataSeries.count > 1 {
            mirrorHRMainClass.realTimeChart.sciChartSurface.zoomExtents()
        }
        
        receivedAt = gotItNow.timeIntervalSince1970
        lastBPMReceivedAt = Date().timeIntervalSince1970
        
        if telemetryBpmConsent {
            let lastTelemetryDate: String =
            mirrorHRMainClass.telemetryBpmDataMessage.dataSeries.last?.date
            ?? ""
            if lastTelemetryDate != gotItNow.toStdString() {
                let newTelemetry = TelemetryBpmDataMessage.TelemetryBpmData(
                    date: gotItNow, bpm: bpm, flowStage: eventStage.description)
                mirrorHRMainClass.telemetryBpmDataMessage.dataSeries.append(
                    newTelemetry)
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case bpm, eventStage, color, receivedAt
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bpm, forKey: .bpm)
        try container.encode(eventStage.rawValue, forKey: .eventStage)
        try container.encode(UIColor(color).toHexString(), forKey: .color)
        try container.encode(receivedAt, forKey: .receivedAt)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bpm = try container.decode(Int.self, forKey: .bpm)
        let eventStageInt = try container.decode(Int.self, forKey: .eventStage)
        eventStage = FlowStages(rawValue: eventStageInt) ?? .stopped
        receivedAt = try container.decode(
            TimeInterval.self, forKey: .receivedAt)
        let colorUIHex = try container.decode(String.self, forKey: .color)
        color = Color(UIColor(hexString: colorUIHex))
    }
    
    public var jsonString: String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode jsonstring", .error)
            return ""
        }
    }
}
