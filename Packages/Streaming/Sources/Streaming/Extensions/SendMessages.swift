//
//  SendMessages.swift
//  
//
//  Created by Roberto D’Angelo on 04/09/22.
//

import Foundation
import MultipeerConnectivity
import Combine
import SharedPkg
import SwiftUI
import MirrorHRTelemetryPackage

// MARK: public interfaces to send data like bpm etc. Use only these and not the internal send function
public extension LocalStreamingManager {
    func sendBPM(_ bpm: Int) {
        guard isEnabled, isServer else {
            return
        }
        let message: StreamingMessage = .init(type: .bpm, displayName: myPeerId.displayName, valueInt: bpm)
        send(message)
    }
    
    func sendStartStreaming() {
        guard isEnabled, isServer else {
            return
        }
        startServer()
        let message: StreamingMessage = .init(type: .start2Listen, displayName: myPeerId.displayName)
        send(message)
    }
    
    func sendStopStreaming() {
        guard isEnabled, isServer, connectedToStream else {
            return
        }
        let message: StreamingMessage = .init(type: .stop2Listen, displayName: myPeerId.displayName)
        send(message)
    }
    
    func sendEvent(_ event: Events) {
        guard isEnabled, isServer else {
            return
        }
        let message: StreamingMessage = .init(type: .event, displayName: myPeerId.displayName, event: event)
        send(message)
    }
    
    func sendMessage(_ msg: String) {
        guard isEnabled, connectedToStream else {
            return
        }
        
        let message: StreamingMessage = .init(type: .justAMessage, displayName: myPeerId.displayName, body: msg)
        send(message)
    }
    
    func sendKeyFlowThresholds(_ keyFlowThresholds: KeyFlowThresholds = KeyFlowThresholds.shared) {
        guard isEnabled, connectedToStream, isServer else {
            return
        }
        let message: StreamingMessage = .init(type: .keyFlowThresholds, displayName: myPeerId.displayName, body: keyFlowThresholds.jsonString)
        send(message)
    }
}
