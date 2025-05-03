//
//  CoreFunctions.swift
//  
//
//  Created by Roberto D’Angelo on 04/09/22.
//

import Foundation
import SharedPkg
import MultipeerConnectivity
import MirrorHRTelemetryPackage

// MARK: StreamingManager Core functions
extension LocalStreamingManager {
    @MainActor
    public func setupAsClient() {
        isServer = false
        isClient = true
    }
    
    @MainActor
    public func setupAsServer() {
        isServer = true
        isClient = false
    }
    
    // Start sending data (if it's the server device and streaming is enabled)
    public func startServer() {
        guard isEnabled, isServer else {
            return
        }
        peers.removeAll()
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        advertiserAssistant = MCNearbyServiceAdvertiser(
            peer: myPeerId,
            discoveryInfo: nil,
            serviceType: LocalStreamingManager.service)
        advertiserAssistant?.delegate = self
        advertiserAssistant?.startAdvertisingPeer()
        dispatchTelemetryEvent(event: .streaming(status: "StartingServer"))
    }
    
    // Join the stream (if it's the client device and streaming is enabled)
    public func join() {
        guard isEnabled, isClient else {
            return
        }
        peers.removeAll()
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        guard let window = keyWindow, let session = session else {
            return
        }
        dispatchTelemetryEvent(event: .streaming(status: "Joining"))
        let mcBrowserViewController = MCBrowserViewController(serviceType: LocalStreamingManager.service, session: session)
        mcBrowserViewController.delegate = self
        window.rootViewController?.present(mcBrowserViewController, animated: true)
    }
    
    public func leaveStream() { // just in case run it without further controls
        guard isEnabled else {
            return
        }
        connectedToStream = false
        advertiserAssistant?.stopAdvertisingPeer()
        session = nil
        advertiserAssistant = nil
        dispatchTelemetryEvent(event: .streaming(status: "LeavingStreaming"))
    }
}
