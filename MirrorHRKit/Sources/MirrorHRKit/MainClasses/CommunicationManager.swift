//
//  CommunicationManager.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 23/10/2020.
//

import Foundation
import SwiftUI
import WatchConnectivity
import SharedPkg
import Combine
import MirrorHRTelemetryPackage
import RoberdanToolBox

public final class CommunicationManagerIoS: NSObject, WCSessionDelegate, ObservableObject, @preconcurrency StreamingSubscriber {
    public static let shared = CommunicationManagerIoS()
    private var mirrorHR = MirrorHRMainClass.shared
    private var settings = ProfileGenericSettings.shared
    private var keyFlowThresholds = KeyFlowThresholds.shared
    @Published var watchBatteryLevel: Int = 0
    @Published var watchAppInstalledAndPaired: Bool = false
    @Published var reachability: Bool = false
    public let wcSession: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    public typealias CommunicationReplyHandler = (([String: Any]) -> Void)
    typealias CommunicationMessage = [String: Any]
    typealias CommunicationErrorHandler = ((Error) -> Void)
    public var streamingMessagesSubscriber: AnyCancellable = AnyCancellable {}
    internal var deviceInfo: (deviceName: String, deviceVersion: String) = ("", "")
    internal var watchDeviceInfo: (deviceName: String, deviceVersion: String)?
    private let sessionQueue = DispatchQueue(label: "com.mirror-labs.Epilepsy-Research-Kit.communicationSessionQueue")
    private var lastWatchNotReachableDispatchTime: Date?
    private let dataSourceManager: DataSourceManager = .shared
    
    public override init() {
        super.init()
        wcSession?.delegate = self
        wcSession?.activate()
        deviceInfo = getDeviceInfo()
        streamingMessagesSubscriber = streamingEventsPublisher
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: { message in
                DispatchQueue.main.async {
                    self.handleStreamingMessage(message)
                    mainDebugger.append("Streaming message received: \(message)")
                }
            })
    }
    
    public func sendCommand(_ command: Command) {
        let sessionMessage = SessionMessage(command: command)
        mainDebugger.append("sending command from iPhone: \(command.jsonString())", .justALog)
        sendMessage(message: sessionMessage.messageDictionary())
    }
    
    // MARK: generic Sending messages
    public func sendMessage(
        message: [String: Any],
        replyHandler: (([String: Any]) -> Void)? = { _ in
            //            print(reply)
        },
        errorHandler: ((Error) -> Void)? = { err in
            mainDebugger
                .append("Error sending the message: \(err)", .error, sourceModule: "Communication Manager Shared - iOS sendMessage")
        }
    ) {
        validReachableSession?.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    public func sessionDidBecomeInactive(_: WCSession) {
        mainDebugger.append("CommunicationManagerShared session did become inactive", .justALog)
    }
    
    public func sessionDidDeactivate(_: WCSession) {
        mainDebugger.append("CommunicationManagerShared session did deactivated", .justALog)
    }
    
    public func getDeviceInfo() -> (deviceName: String, deviceVersion: String) {
        let deviceVersion = UIDevice.current.systemVersion
        let deviceName = UIDevice.current.systemName
        return (deviceName, deviceVersion)
    }
    
    public func session(
        _ session: WCSession,
        activationDidCompleteWith _: WCSessionActivationState,
        error _: Error?
    ) {
        if !dataSourceManager.dataSource.shouldHandleWatchSession {
            return
        }
        
        // Executing the whole flow within the main queue to be consistent, limit mistakes and simplify code
        DispatchQueue.main.async { [self] in
            if let session = wcSession, session.isWatchAppInstalled, session.isPaired {
                watchAppInstalledAndPaired = true
                mainDebugger.append("wcSession activated", .greenFlag)
            } else {
                if let session = wcSession {
                    if !session.isWatchAppInstalled {
                        watchAppInstalledAndPaired = false
                        dispatchEventCommunicationError(.watchAppNotInstalled, "CommunicationManagerIoS")
                    } else if !session.isPaired {
                        watchAppInstalledAndPaired = false
                        dispatchEventCommunicationError(.watchNotPaired, "CommunicationManagerIoS")
                    } else {
                        watchAppInstalledAndPaired = true // it might simply not being reachable
                    }
                }
            }
            mainDebugger.append("wc session activation complete", .greenFlag)
        }
    }
    
    // MARK: Receiver handling Commands received from WATCH
    // swiftlint:disable cyclomatic_complexity
    /// Receives commands from the watch
    
    public func session(_: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        let sessionMessage = SessionMessage(messageDictionary: message)
        
        // Handling commands
        if let command = sessionMessage.command {
            mainDebugger.append("Command received from watch: \(command.jsonString()) at \(Date().toStdString())", .event)
            switch command {
            case let .start(source, _, deviceName, deviceVersion, _):
                DispatchQueue.main.async { [self] in
                    mirrorHR.status = .booting(source: source)
                }
                watchDeviceInfo = (deviceName, deviceVersion)
                mainDebugger.append("cmd start received from watch, booting", .greenFlag)
                
            case let .stop(source, _, _):
                // if parental control is on, it can't be stopped from the watch, so temporarely until I don't have params on the watch too I just restar the session on the watch
                if settings.parentalControl {
                    sendCommand(.start(source: .iPhone, destination: .appleWatch, deviceName: deviceInfo.deviceName, deviceVersion: deviceInfo.deviceVersion, timestamp: Date().timeIntervalSince1970))
                } else {
                    DispatchQueue.main.async { [self] in
                        mirrorHR.status = .stopped(source: source)
                    }
                    mainDebugger.append("Cmd stop received from watch at \(Date().returnDDmmYY()) \(Date().returnHHmm())", .greenFlag)
                }
                
            case let .battery(batteryLevel, _):
                mainDebugger.append("Battery on the watch: \(batteryLevel)")
                let batteryLevel = Int(batteryLevel)
                DispatchQueue.main.async { [self] in
                    watchBatteryLevel = batteryLevel
                }
                if batteryLevel <= keyFlowThresholds.minBatteryLevelForNotification, watchBatteryLevel >= 0 {
                    dispatchMainEvent(.lowBatteryWatch(metaData: .init(name: "BatteryLevel", valueInt: watchBatteryLevel)), "CommunicationManagerIoS")
                }
                
            case .delayedStop:
                // Do nothing here as wath can not send delayedStop command, only iphone can
                break
                
            case .confirmFlowParametersUpdate:
                // Do nothing here
                mainDebugger.append("parameters have been updated on the watch")
                
            case let .handShake(deviceName, deviceVersion):
                DispatchQueue.main.async { [self] in
                    watchAppInstalledAndPaired = true
                    watchDeviceInfo = (deviceName, deviceVersion)
                }
                
            case .error(source: _, destination: _, errorMessage: let errorMessage):
                dispatchEventCommunicationError(.errorFromTheWatch(errorMessage: errorMessage), "CommunicationManagerIoS")
                
            case let .parentalControl(parentalControlValue):
                DispatchQueue.main.async { [self] in
                    settings.parentalControl = parentalControlValue
                }
            }
            
            replyHandler(["CMDEXECUTED": true])
            mainDebugger.append("message elaborated: \(message), sending ReplyHandler")
        }
        
        // MARK: HERE IS WHERE REALTIME BPMs FROM WATCH ARE HANDLED
        // Handling BPMs
        if let bpmFromWatch = sessionMessage.bpmFromWatch {
            replyHandler(["ok": true])
            FreshBPM.shared.landFreshBPM(bpmFromWatch)
        }
        // swiftlint:enable cyclomatic_complexity
    }
    
    // Live messaging! App has to be reachable
    public var validReachableSession: WCSession? {
        if !dataSourceManager.dataSource.shouldHandleWatchSession {
            return nil
        }
        return sessionQueue.sync {
            if let session = validSession, session.isReachable {
                return session
            }
            if let session = validSession, !session.isReachable {
                let now = Date()
                if lastWatchNotReachableDispatchTime == nil || now.timeIntervalSince(lastWatchNotReachableDispatchTime!) > 60 {
                    lastWatchNotReachableDispatchTime = now
                    if isAppleWatchPaired() {
                        dispatchMainEvent(.watchNotReachable, "CommunicationManagerIoS - Apple Watch Paired")
                    } else {
                        dispatchMainEvent(.watchNotReachable, "CommunicationManagerIoS - Apple Watch NOT Paired")
                    }
                }
            }
            return nil
        }
    }
    
    func startSession() {
        wcSession?.delegate = self
        wcSession?.activate()
        deviceInfo = getDeviceInfo()
    }
    
    func isAppleWatchPaired() -> Bool {
        guard let session = wcSession, session.activationState == .activated else {
            return false
        }
        return session.isPaired
    }
}

extension CommunicationManagerIoS {
    @MainActor public func handleStreamingMessage(_ message: StreamingMessage) {
        switch message.messageType {
        case .bpm:
            if let bpmFromStreaming = message.bpmFromStreaming {
                FreshBPM.shared.landFreshBPM(bpmFromStreaming)
            }
        case .start2Listen:
            mirrorHR.status = .booting(source: .localStreaming)
        case .stop2Listen:
            mirrorHR.status = .stopped(source: .localStreaming)
        case .justAMessage:
            break
        case .event:
            guard let jsonString = message.eventJson, let streamedEvent = Events.loadFromJson(jsonString: jsonString) else {
                mainDebugger.append("Received a streaming message as event but can't decode it", .fatalError, sourceModule: "CommunicationManagerIoS - handleStreamingMessage")
                return
            }
            dispatchMainEvent(streamedEvent, "CommunicationManagerIoS")
        case .keyFlowThresholds:
            guard let jsonString = message.body else {
                mainDebugger.append("received an empty body when expected KeyFlowThresholds in jsonString", .error, sourceModule: "CommunicationManagerIoS handleStreamingMessage")
                return
            }
            
            // replace current KeyFlowThresholds with parameters coming from the server, so it's all mirrored
            self.keyFlowThresholds.loadFromJson(jsonString: jsonString)
        }
    }
}

extension CommunicationManagerIoS {
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
