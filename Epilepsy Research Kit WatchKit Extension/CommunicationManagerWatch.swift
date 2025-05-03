//
//  CommunicationManagerWatch.swift
//  Epilepsy Research Kit WatchKit App
//
//  Created by Roberto D’Angelo on 24/09/22.
//  Copyright © 2022 FightTheStroke Foundation. All rights reserved.
//

import HealthKit
import SharedPkg
import SwiftUI
import WatchConnectivity

final class CommunicationManagerWatch: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = CommunicationManagerWatch()
    private lazy var mirrorHRWorkOut = MirrorHRWorkOut.shared

    @Published var batteryStatus: Int = 0
    @Published var reachability: Bool = false
    public let wcSession: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    public typealias CommunicationReplyHandler = (([String: Any]) -> Void)

    public func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error: Error?) {
        if let err = error {
            mainDebugger.append("CommunicationManagerShared Completed activation with error: \(err.localizedDescription)", .error)
        } else {
            mainDebugger.append("CommunicationManagerShared Completed activation succesfully!", .greenFlag)
        }
    }
    
    public override init() {
        super.init()
        wcSession?.delegate = self
        wcSession?.activate()
        Task { await handShakeWithPhone() }
        DispatchQueue.main.async {
            self.batteryStatus = self.checkBatteryStatus()
        }

        // check battery status every 20 minutes (= 1200 seconds)
        Timer.scheduledTimer(withTimeInterval: 1200, repeats: true) { _ in
            DispatchQueue.main.async {
                self.batteryStatus = self.checkBatteryStatus()
            }
        }
    }
    
    func startSession() {
        wcSession?.delegate = self
        wcSession?.activate()
    }
    
    // Live messaging! App has to be reachable
    public var validReachableSession: WCSession? {
        if let session = validSession, session.isReachable {
            return session
        }
        return nil
    }
    
    public func sendCommand(_ command: Command) {
        let sessionMessage = SessionMessage(command: command)
        mainDebugger.append("sending command from Watch: \(command.jsonString())", .justALog)
        sendMessage(message: sessionMessage.messageDictionary())
    }
    
    // MARK: - Send Message
    public func sendMessage(
        message: [String: Any],
        replyHandler: (([String: Any]) -> Void)? = { _ in
//            print(reply)
        },
        errorHandler: ((Error) -> Void)? = { err in
            mainDebugger.append("Error sending the message: \(err)", .error, sourceModule: "CommunicationManagerWatch - sendMessage")
        }
    ) {
        validReachableSession?.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    
    private func startFromPhone() {
        DispatchQueue.main.async {
            self.mirrorHRWorkOut.workOutState = .running(source: .iPhone)
        }
    }
    
    private func stopFromPhone(_: TimeInterval) {
        DispatchQueue.main.async { [self] in
            mirrorHRWorkOut.workOutState = .stopped(source: .iPhone)
        }
    }
    
    private func updateParentalControl(_ newStatus: Bool) {
        DispatchQueue.main.async {
            self.mirrorHRWorkOut.parentalControl = newStatus
        }
    }
    
    private func delayStopFromPhone(forHowLong: TimeInterval) {
        DispatchQueue.main.async { [self] in
            mirrorHRWorkOut.workOutState = .delayedStop(forHowLong: forHowLong)
        }
    }
    
    public func startFromWatch() {
        mirrorHRWorkOut.parentalControl = false
        // just to be sure watch is connected to the phone. If it is, then the phone will send the updated value, if not it will be possible to start/stop in any case from the watch
        let deviceInfo = getDeviceInfo()
        sendCommand(.start(source: .appleWatch, destination: .iPhone,
                           deviceName: deviceInfo.deviceName,
                           deviceVersion: deviceInfo.deviceVersion,
                           timestamp: Date().timeIntervalSince1970))
        _ = checkBatteryStatus()
    }
    
    public func stopFromWatch() {
        sendCommand(.stop(source: .appleWatch, destination: .iPhone, timestamp: Date().timeIntervalSince1970))
    }
    
    
    public func getDeviceInfo() -> (deviceName: String, deviceVersion: String) {
        let deviceVersion = WKInterfaceDevice.current().systemVersion
        let deviceName = WKInterfaceDevice.current().systemName
        return (deviceName, deviceVersion)
    }
    
    func session(_: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        // MARK: handling Commands from Phone
        
        mainDebugger.append("message received from phone: \(message) - going to process it now")
        let sessionMessage = SessionMessage(messageDictionary: message)
        var replyDictionary = [String: Any]()
        if let command = sessionMessage.command {
            if let replyFromCommand = processMessageCommand(command) {
                replyDictionary = replyFromCommand
            }
        }
        replyHandler(replyDictionary)
    }
    
    private func processMessageCommand(_ command: Command) -> [String: Any]? {
        var replyDictionary: [String: Any]?
        switch command {
        case .start:
            startFromPhone()
            mainDebugger.append("cmd start received from phone", .event)
        case let .stop(_, _, timestamp):
            stopFromPhone(timestamp)
            mainDebugger.append("cmd stop received from phone", .event)
        case .handShake:
//            print(deviceName + " " + deviceVersion)
            mainDebugger.append("HandShake from Phone received", .event)
           break
        case .battery:
            _ = checkBatteryStatus()
            mainDebugger.append("battery level sent to phone")
        case .confirmFlowParametersUpdate:
            // TODO: implement here
            mainDebugger.append("flow parameters handling not implemented yet")
        case let .delayedStop(_, _, _, forHowLong: forHowLong):
            // do nothing as
            delayStopFromPhone(forHowLong: forHowLong)
        case .error(source: _, destination: _, errorMessage: let errormessage):
            mainDebugger.append("error has been generated on the watch side: \(errormessage)", .error)
        case let .parentalControl(parentalControlValue: parentalControl):
            updateParentalControl(parentalControl)
        }
        replyDictionary = ["CMDEXECUTED": true]
        mainDebugger.append("Command received from phone to watch: \(command.jsonString()), replied with CMDEXECUTED")
        return replyDictionary
    }
    
    public func handShakeWithPhone() async {
        let deviceInfo = getDeviceInfo()
        sendCommand(.handShake(deviceName: deviceInfo.deviceName, deviceVersion: deviceInfo.deviceVersion))
    }
}

extension CommunicationManagerWatch {
    func sendMessageData(data: Data,
                         replyHandler: ((Data) -> Void)? = nil,
                         errorHandler: ((Error) -> Void)? = nil) {
        validReachableSession?.sendMessageData(data, replyHandler: replyHandler, errorHandler: errorHandler)
        mainDebugger.append("sending Data: \(data)", .event)
    }
    
    public func session(_: WCSession, didReceiveMessageData _: Data) {
        // handle receiving message data
        DispatchQueue.main.async {
            // make sure to put on the main queue to update UI!
        }
    }
    
    // Called when WCSession reachability is changed.
    public func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [self] in
            reachability = session.isReachable
            mainDebugger.append("session reachability changed to: \(reachability)")
        }
    }
    
    @objc public var validSession: WCSession? {
        // paired - the user has to have their device paired to the watch
        // watchAppInstalled - the user must have your watch app installed
        
        // Note: if the device is paired, but your watch app is not installed
        // consider prompting the user to install it for a better experience
        wcSession
    }
    
    // Sender
    func transferUserInfo(userInfo: [String: Any]) -> WCSessionUserInfoTransfer? {
        validSession?.transferUserInfo(userInfo)
    }
    
    public func session(_: WCSession, didFinish _: WCSessionUserInfoTransfer, error _: Error?) {
        // implement this on the sender if you need to confirm that
        // the user info did in fact transfer
    }
    
    // Receiver
    public func session(_: WCSession, didReceiveUserInfo _: [String: Any] = [:]) {
        // handle receiving user info
        DispatchQueue.main.async {
            // make sure to put on the main queue to update UI!
        }
    }
    
    // MARK: Transfer File
    
    // Sender
    @discardableResult func transferFile(file: NSURL, metadata: [String: Any]) -> WCSessionFileTransfer? {
        validSession?.transferFile(file as URL, metadata: metadata)
    }
    
    public func session(_: WCSession, didFinish _: WCSessionFileTransfer, error: Error?) {
        if let err = error {
            mainDebugger.append("Error sending session data file to phone: \(err.localizedDescription)", .error)
        } else {
            mainDebugger.append("File successfully sent and deleted", .greenFlag)
        }
    }
    
    // Receiver
    public func session(_: WCSession, didReceive _: WCSessionFile) {
        // handle receiving file
        DispatchQueue.main.async {
            // make sure to put on the main queue to update UI!
        }
    }
}
