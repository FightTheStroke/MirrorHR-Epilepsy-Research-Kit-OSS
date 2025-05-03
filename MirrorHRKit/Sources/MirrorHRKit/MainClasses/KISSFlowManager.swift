//
//  KISSFlowManager.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 21/12/20.
//  Copyright © 2020 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SharedPkg
import SwiftUI
import RoberdanToolBox
import MirrorHRTelemetryPackage

// MARK: FlowManager - Keep It Simple and Stupid

final class KISSFlowManager: ObservableObject {
    static var shared = KISSFlowManager()
    private let dataSourceManager: DataSourceManager
    
    @Published var keyFlowThresholds = KeyFlowThresholds.shared
    @Published var currentStage: FlowStages = .stopped 
    
    @Published var firstAlarmReceivedAt: TimeInterval = 0.0 {
        didSet {
            if firstAlarmReceivedAt == 0.0 {
                alarmDispatched = false
                triageLenght = 0.0
            }
        }
    }

    var triageLenght: TimeInterval = 0.0
    var alarmDispatched: Bool = false
    private lazy var notificationManager: NotificationManager = .shared
    var lastBPMAnalyzedAt: TimeInterval = NSTimeIntervalSince1970
    var sessionID: UUID = UUID()

    private init(dataSourceManager: DataSourceManager = .shared) {
        self.dataSourceManager = dataSourceManager
    }
    
    // MARK: Analyze BPM State Machine
    func analyzeFlowForLocalBPM(_ bpm: Int) -> FlowStages {
        lastBPMAnalyzedAt = Date().timeIntervalSince1970

        // MARK: Alarm event
        if bpm <= keyFlowThresholds.alarmMin || bpm >= keyFlowThresholds.alarmMax {
            currentStage = .alarm
            if firstAlarmReceivedAt == 0.0 {
                firstAlarmReceivedAt = lastBPMAnalyzedAt
                triageLenght = 0.0
            } else {
                triageLenght = lastBPMAnalyzedAt - firstAlarmReceivedAt
            }
            if triageLenght >= Double(keyFlowThresholds.triageDeltaTimeBeforeFireAlarm) {
                dispatchMainEvent(.alarm(metaData: .init(name: "BPM", valueInt: bpm)), "KissFlowManager")
                alarmDispatched = true
            }
        } else if bpm <= keyFlowThresholds.warningMin || bpm >= keyFlowThresholds.warningMax {
            currentStage = .warning
            resetAlarm()
        } else if bpm < keyFlowThresholds.deepSleepMax {
            currentStage = .deepSleep
            resetAlarm()
        } else if bpm < keyFlowThresholds.lightSleepMax {
            currentStage = .lightSleep
            resetAlarm()
        } else {
            currentStage = .normal
            resetAlarm()
        }
        notificationManager.scheduleNewNoLocalDataNotification()
        return currentStage
    }

    func analyzeFlowForRemoteBPM(_ bpm: Int) -> FlowStages {
        lastBPMAnalyzedAt = Date().timeIntervalSince1970

        // MARK: Alarm event
        if bpm <= keyFlowThresholds.alarmMin || bpm >= keyFlowThresholds.alarmMax {
            currentStage = .alarm
        } else if bpm <= keyFlowThresholds.warningMin || bpm >= keyFlowThresholds.warningMax {
            currentStage = .warning
        } else if bpm < keyFlowThresholds.deepSleepMax {
            currentStage = .deepSleep
        } else if bpm < keyFlowThresholds.lightSleepMax {
            currentStage = .lightSleep
        } else {
            currentStage = .normal
        }
        return currentStage
    }
    
    func returnColorOnlyForBPM(_ bpm: Int) -> UIColor {
        if bpm <= keyFlowThresholds.alarmMin || bpm >= keyFlowThresholds.alarmMax {
            return FlowStages.alarm.chartColor
        } else if bpm <= keyFlowThresholds.warningMin || bpm >= keyFlowThresholds.warningMax {
            return FlowStages.warning.chartColor
        } else if bpm < keyFlowThresholds.deepSleepMax {
            return FlowStages.deepSleep.chartColor
        } else if bpm < keyFlowThresholds.lightSleepMax {
            return FlowStages.lightSleep.chartColor
        } else if bpm == 0 {
            return FlowStages.stopped.chartColor
        } else {
            return FlowStages.normal.chartColor
        }
    }
    
    public func start(sessionID: UUID, dataSource: DataSource) {
        self.sessionID = sessionID
        currentStage = .running
        lastBPMAnalyzedAt = Date().timeIntervalSince1970
        firstAlarmReceivedAt = 0.0
        switch dataSource {
        case .diaryOnly, .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
            break
        case .appleWatchPairedOnly, .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            notificationManager.scheduleNewNoLocalDataNotification()
        }
    }

    public func resetAlarm() {
        firstAlarmReceivedAt = 0.0
    }

    public func stop() {
        currentStage = .stopped
        firstAlarmReceivedAt = 0.0
        notificationManager.removePendingNoDataCheckNotifications()
    }
}
