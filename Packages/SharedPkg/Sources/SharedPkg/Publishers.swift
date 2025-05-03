//
//  Publishers.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 27/09/2020.
//

import Combine
import Foundation
import RoberdanToolBox
import MirrorHRTelemetryPackage

public let mainEventsPublisher = PassthroughSubject<Events, Never>()
public let healthKitEventsPublisher = PassthroughSubject<HealthKitToolsEvents, Never>()
public let communicationErrorPublisher = PassthroughSubject<WatchCommunicationErrors, Never>()
public let keyParametersChanged = PassthroughSubject<Void, Never>()
public let eraseCommandCombinePublisher = PassthroughSubject<Void, Never>()
public let resetToDefaultValuesCommandPublisher = PassthroughSubject<Void, Never>()

public func dispatchMainEvent(_ event: Events, _ source: String ) {
    mainEventsPublisher.send(event)

    switch event {
    case .lastBPM, .alarm, .manualAlarm, .warning, .lowBatteryWatch, .handleSeizure, .handleFalseAlarm, .testSound, .medicationAlert, .streamingUnderstandAlert, .activePatientChanged, .medicationSnooze, .lowBatteryIphone:
        break
    case .stopFromIphone, .stopReceivedFromWatch, .stopFromRemoteStreaming:
        mainDebugger.append("MirrorHR Main Flow has been stopped by \(source)", .event)
    case .sessionBoot:
        mainDebugger.append("session booted at \(Date().toStdString())", .greenFlag)
    case .unclassifiedEvent:
        mainDebugger.append("Unclassified event happened", .error, sourceModule: source)
    case .criticalError:
        mainDebugger.append("Critical Error happened", .fatalError, sourceModule: source)
    case .termination:
        mainDebugger.append("Application terminated by the user", .error, sourceModule: source)
    case .noLocalData:
        mainDebugger.append("No Data event fired", .error, sourceModule: source)
    case .cantFireNotification:
        mainDebugger.append("Can't fire notification error", .fatalError, sourceModule: source)
    case .HealthAuthorizationError:
        mainDebugger.append("Health authorization error", .error, sourceModule: source)
    case .watchNotReachable:
        mainDebugger.append("Watch not reachable", .error, sourceModule: source)
    case .noStreamingData:
        mainDebugger.append("Not receiving data from the Remote MirrorHR", .error, sourceModule: source)
    }
}

public func dispatchEventCommunicationError(_ event: WatchCommunicationErrors, _ source: String) {
    communicationErrorPublisher.send(event)
    switch event {
    case .watchAppNotInstalled:
        mainDebugger.append("WhatchApp not installed", .fatalError, sourceModule: source)
    case .watchNotPaired:
        mainDebugger.append("WhatchApp not paired", .fatalError, sourceModule: source)
    case .cantCommunicateWithWatch:
        mainDebugger.append("App can't communicate with the Watch", .error, sourceModule: source)
    case .errorFromTheWatch(let errorMessage):
        mainDebugger.append("Error from the Watch: \(errorMessage.debugDescription)", .error, sourceModule: source)
    case .watchNotReachable:
        break
    case .cantStartTheSession:
        mainDebugger.append("Error from the Watch: Can't start the session", .error, sourceModule: "bootMirroHRFlow")
    case .soSorryError(let errorMessage):
        mainDebugger.append("Error from Communication: \(errorMessage)", .error, sourceModule: "bootMirroHRFlow")
    case .healthAuthorization(let errorMessage):
        mainDebugger.append("Health authorization error: \(errorMessage)", .error, sourceModule: "health")
    case .remoteMirrorHRNotActive:
        mainDebugger.append("Remote MirrorHR Is Not Active", .justALog, sourceModule: "Remote Streaming" )
    }
}

public func dispatchHealthKitEvents(event: HealthKitToolsEvents) {
    healthKitEventsPublisher.send(event)
}

public func updatedParametersBroadcasting() {
    keyParametersChanged.send()
}

