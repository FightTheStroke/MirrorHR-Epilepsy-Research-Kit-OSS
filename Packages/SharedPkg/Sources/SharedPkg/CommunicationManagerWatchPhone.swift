//
//  CommunicationManagerShared.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 17/03/2020.
//  Copyright © 2020 Roberto D’Angelo. All rights reserved.
//

import Foundation
import Combine
import RoberdanToolBox
import SwiftUI

public enum Command: Codable {
    private enum CodingKeys: String, CodingKey { case start, stop, battery, handShake, confirmFlowParametersUpdate, delayedStop, error, simulateAlarm, parentalControl }
    private enum StartKeys: String, CodingKey { case source, destination, deviceName, deviceVersion, timestamp }
    private enum HandShakeKeys: String, CodingKey { case deviceName, deviceVersion }
    private enum StopKeys: String, CodingKey { case source, destination, timestamp }
    private enum DelayedStopKeys: String, CodingKey { case source, destination, timestamp, forHowLong }
    private enum BatteryKeys: String, CodingKey { case batteryLevel, timestamp }
    private enum ErrorKeys: String, CodingKey { case source, destination, errorMessage }
    private enum ParentalControlKeys: String, CodingKey { case parentalControlValue }

    case start(source: DeviceModels, destination: DeviceModels, deviceName: String, deviceVersion: String, timestamp: TimeInterval)
    case stop(source: DeviceModels, destination: DeviceModels, timestamp: TimeInterval)
    case error(source: DeviceModels, destination: DeviceModels, errorMessage: String)
    case delayedStop(source: DeviceModels, destination: DeviceModels, timestamp: TimeInterval, forHowLong: TimeInterval)
    case battery(batteryLevel: Float, timestamp: TimeInterval)
    case handShake(deviceName: String, deviceVersion: String)
    case confirmFlowParametersUpdate
    case parentalControl(parentalControlValue: Bool)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let startContainer = try? container.nestedContainer(keyedBy: StartKeys.self, forKey: .start),
           let timestamp = try? startContainer.decode(Double.self, forKey: .timestamp),
           let source = try? startContainer.decode(DeviceModels.self, forKey: .source),
           let deviceName = try? startContainer.decode(String.self, forKey: .deviceName),
           let deviceVersion = try? startContainer.decode(String.self, forKey: .deviceVersion),
           let destination = try? startContainer.decode(DeviceModels.self, forKey: .destination) {
            self = .start(source: source, destination: destination, deviceName: deviceName, deviceVersion: deviceVersion, timestamp: timestamp)
        } else if let stopContainer = try? container.nestedContainer(keyedBy: StopKeys.self, forKey: .stop),
                  let timestamp = try? stopContainer.decode(Double.self, forKey: .timestamp),
                  let source = try? stopContainer.decode(DeviceModels.self, forKey: .source),
                  let destination = try? stopContainer.decode(DeviceModels.self, forKey: .destination) {
            self = .stop(source: source, destination: destination, timestamp: timestamp)
        } else if let lowBatteryContainer = try? container.nestedContainer(keyedBy: BatteryKeys.self, forKey: .battery),
                  let batteryLevel = try? lowBatteryContainer.decode(Float.self, forKey: .batteryLevel),
                  let timestamp = try? lowBatteryContainer.decode(Double.self, forKey: .timestamp) {
            self = .battery(batteryLevel: batteryLevel, timestamp: timestamp)
        } else if let handShakeContainer = try? container.nestedContainer(keyedBy: HandShakeKeys.self, forKey: .handShake),
                  let deviceName = try? handShakeContainer.decode(String.self, forKey: .deviceName),
                  let deviceVersion = try? handShakeContainer.decode(String.self, forKey: .deviceVersion) {
            self = .handShake(deviceName: deviceName, deviceVersion: deviceVersion)
        } else if let parentalControlContainer = try? container.nestedContainer(keyedBy: ParentalControlKeys.self, forKey: .parentalControl),
                  let parentalControlValue = try? parentalControlContainer.decode(Bool.self, forKey: .parentalControlValue) {
            self = .parentalControl(parentalControlValue: parentalControlValue)
        } else if container.contains(.confirmFlowParametersUpdate) {
            self = .confirmFlowParametersUpdate
        } else if let delayedStopContainer = try? container.nestedContainer(keyedBy: DelayedStopKeys.self, forKey: .delayedStop),
                  let timestamp = try? delayedStopContainer.decode(Double.self, forKey: .timestamp),
                  let source = try? delayedStopContainer.decode(DeviceModels.self, forKey: .source),
                  let destination = try? delayedStopContainer.decode(DeviceModels.self, forKey: .destination),
                  let forHowLong = try? delayedStopContainer.decode(Double.self, forKey: .forHowLong) {
            self = .delayedStop(source: source, destination: destination, timestamp: timestamp, forHowLong: forHowLong)
        } else if let errorContainer = try? container.nestedContainer(keyedBy: ErrorKeys.self, forKey: .error),
                  let source = try? errorContainer.decode(DeviceModels.self, forKey: .source),
                  let destination = try? errorContainer.decode(DeviceModels.self, forKey: .destination),
                  let errorMessage = try? errorContainer.decode(String.self, forKey: .errorMessage) {
            self = .error(source: source, destination: destination, errorMessage: errorMessage)
        } else {
            mainDebugger.append("unrecognized command received", .error)
            throw NSError(domain: "Command codable", code: 1003, userInfo: [NSLocalizedDescriptionKey: "unrecognized command received"])
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .start(source, destination, deviceName, deviceVersion, timestamp):
            var startContainer = container.nestedContainer(keyedBy: StartKeys.self, forKey: .start)
            try startContainer.encode(timestamp, forKey: .timestamp)
            try startContainer.encode(source, forKey: .source)
            try startContainer.encode(destination, forKey: .destination)
            try startContainer.encode(deviceName, forKey: .deviceName)
            try startContainer.encode(deviceVersion, forKey: .deviceVersion)
        case let .stop(source, destination, timestamp):
            var stopContainer = container.nestedContainer(keyedBy: StopKeys.self, forKey: .stop)
            try stopContainer.encode(source, forKey: .source)
            try stopContainer.encode(destination, forKey: .destination)
            try stopContainer.encode(timestamp, forKey: .timestamp)
        case let .battery(batteryLevel, timestamp):
            var lowBatteryContainer = container.nestedContainer(keyedBy: BatteryKeys.self, forKey: .battery)
            try lowBatteryContainer.encode(batteryLevel, forKey: .batteryLevel)
            try lowBatteryContainer.encode(timestamp, forKey: .timestamp)
        case let .handShake(deviceName, deviceVersion):
            var handShakeContainer = container.nestedContainer(keyedBy: HandShakeKeys.self, forKey: .handShake)
            try handShakeContainer.encode(deviceName, forKey: .deviceName)
            try handShakeContainer.encode(deviceVersion, forKey: .deviceVersion)
        case let .parentalControl(parentalControlValue):
            var parentalControlContainer = container.nestedContainer(keyedBy: ParentalControlKeys.self, forKey: .parentalControl)
            try parentalControlContainer.encode(parentalControlValue, forKey: .parentalControlValue)
        case .confirmFlowParametersUpdate:
            try container.encode(true, forKey: .confirmFlowParametersUpdate)
        case let .delayedStop(source: source, destination: destination, timestamp: timestamp, forHowLong: forHowLong):
            var delayedStopContainer = container.nestedContainer(keyedBy: DelayedStopKeys.self, forKey: .delayedStop)
            try delayedStopContainer.encode(source, forKey: .source)
            try delayedStopContainer.encode(destination, forKey: .destination)
            try delayedStopContainer.encode(timestamp, forKey: .timestamp)
            try delayedStopContainer.encode(forHowLong, forKey: .forHowLong)
        case let .error(source: source, destination: destination, errorMessage: errorMessage):
            var errorContainer = container.nestedContainer(keyedBy: ErrorKeys.self, forKey: .error)
            try errorContainer.encode(errorMessage, forKey: .errorMessage)
            try errorContainer.encode(source, forKey: .source)
            try errorContainer.encode(destination, forKey: .destination)
        }
    }
    
    public func jsonString() -> String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode jsonstring", .error)
            return ""
        }
    }
    
    public static func loadFromJson(jsonString: String) -> Command? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(Command.self, from: data)
    }
}

public struct BPMFromWatch: Codable, Equatable {
    public var bpm: Int
    public var startDate: Date
    public var endDate: Date
    
    public var detectedAt: TimeInterval {
        endDate.timeIntervalSince1970
    }
    
    public var intervalSinceLast: TimeInterval {
        Date().timeIntervalSince1970 - detectedAt
    }
    
    public init(bpm: Int = 0, startDate: Date = Date(), endDate: Date = Date()) {
        self.bpm = bpm
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public mutating func boot() {
        bpm = 0
        startDate = Date()
        endDate = startDate
    }
    
    public mutating func stop() {
        bpm = 0
        startDate = Date()
        endDate = startDate
    }
    
    public func jsonString() -> String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode jsonstring", .error)
            return ""
        }
    }
    
    public static func loadFromJson(jsonString: String) -> BPMFromWatch? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(BPMFromWatch.self, from: data)
    }
}

public struct SessionMessage: Codable {
    private enum Fields: String {
        case bpmFromWatch
        case command
        case flowParameters
    }
    
    public var bpmFromWatch: BPMFromWatch?
    public var command: Command?
    public var flowParameters: KeyFlowThresholds?
    
    public init(bpmFromWatch: BPMFromWatch? = nil, command: Command? = nil, flowParameters: KeyFlowThresholds? = nil) {
        self.bpmFromWatch = bpmFromWatch
        self.command = command
        self.flowParameters = flowParameters
    }
    
    public init(messageDictionary: [String: Any]) {
        if let bpmJson = messageDictionary[Fields.bpmFromWatch.rawValue] as? String {
            bpmFromWatch = BPMFromWatch.loadFromJson(jsonString: bpmJson)
        }
        
        if let commandJson = messageDictionary[Fields.command.rawValue] as? String {
            command = Command.loadFromJson(jsonString: commandJson)
        }
        
        if let flowParametersUpdateJson = messageDictionary[Fields.flowParameters.rawValue] as? String {
            flowParameters = KeyFlowThresholds.loadFromJson(jsonString: flowParametersUpdateJson)
        }
    }
    
    public func messageDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary[Fields.bpmFromWatch.rawValue] = bpmFromWatch?.jsonString()
        dictionary[Fields.command.rawValue] = command?.jsonString()
        dictionary[Fields.flowParameters.rawValue] = flowParameters?.jsonString
        return dictionary
    }
    
    public func jsonString() -> String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode jsonstring", .error)
            return ""
        }
    }
    
    public static func loadFromJson(jsonString: String) -> SessionMessage? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(SessionMessage.self, from: data)
    }
}
