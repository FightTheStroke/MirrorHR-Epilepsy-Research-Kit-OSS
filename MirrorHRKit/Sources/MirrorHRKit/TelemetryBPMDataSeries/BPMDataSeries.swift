//
//  TelemetryBPMDataSeries.swift
//  
//
//  Created by Roberto D’Angelo on 11/08/22.
//

import Foundation
import SharedPkg
import MirrorHRTelemetryPackage

internal class TelemetryBpmDataMessage: Codable {
    private var eventType: String = Telemetries.realTimeTelemetrySession(jsonString: "").eventType
    public var header: TelemetryHeader
    public var sessionStats: SessionStats?
    public var dataSeries: [TelemetryBpmData]
    public var iosDeviceVersion: String?
    public var watchOSVersion: String?
    
    struct TelemetryBpmData: Codable, Equatable {
        public var date: String
        public var bpm: Int
        public var flowStage: String
        
        public init(date: Date, bpm: Int, flowStage: String) {
            self.date = date.toStdString()
            self.bpm = bpm
            self.flowStage = flowStage
        }
    }
    
    public init() {
        dataSeries = []
        sessionStats = nil
        header = TelemetryHeader.shared
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func clear() {
        self.header = TelemetryHeader.shared
        dataSeries = []
        sessionStats = nil
    }
    
    public func jsonString() -> String {
        self.header = TelemetryHeader.shared // doing this to secure timestamp is updated to when it's encoded
        do {
            let jsonData = try JSONEncoder().encode(self)
            let returnString = String(data: jsonData, encoding: .utf8)!
            return returnString
        } catch {
            mainDebugger.append(error.localizedDescription, .error, sourceModule: "TelemetryBpmDataMessage - jsonString")
            return ""
        }
    }
}
