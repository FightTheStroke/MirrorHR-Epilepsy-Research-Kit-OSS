//
//  EventsHandling.swift
//  
//
//  Created by Roberto D’Angelo on 04/09/22.
//

import Foundation
import SharedPkg

// MARK: Handling events, basically mirroring events from the main phone to the other
extension LocalStreamingManager {
    public func handleEvents(event: Events) {
        switch event {
        case .stopFromIphone, .stopReceivedFromWatch:
            sendStopStreaming()
            leaveStream()
        case .sessionBoot:
            sendStartStreaming()
            join()
        case .cancelledJoinStream, .streamingUnderstandAlert, .testSound, .cantFireNotification, .HealthAuthorizationError:
            break
        case .warning, .noLocalData, .unclassifiedEvent, .handleSeizure, .handleFalseAlarm, .medicationAlert, .medicationSnooze:
            sendEvent(event)
        case .alarm, .manualAlarm, .lowBatteryWatch, .lowBatteryIphone,
                .criticalError, .termination:
            sendEvent(event)
        case .lastBPM(let bpm, _):
            if isServer {
                sendBPM(bpm)
            }
        case .watchNotReachable, .stopFromRemoteStreaming:
            break
        case .noStreamingData(metaData: let metaData):
            sendEvent(event)
        }
    }
}
