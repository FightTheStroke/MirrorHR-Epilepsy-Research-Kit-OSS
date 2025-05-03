import Foundation
import SwiftUI
import TelemetryClient
import Combine
import Network
import OSLog
import RoberdanSecretsPackage

@available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
public class MirrorHRTelemetry: TelemetrySubscriber, ObservableObject {
    static public let shared: MirrorHRTelemetry = MirrorHRTelemetry()
    
    private var telemetryEngines: [TelemetryEngines] = [.telemetryDeck, .researchCloudApi]
    public var cloudApiManager: CloudAPIManager = CloudAPIManager()
    internal var telemetryEventSubscriber: AnyCancellable = AnyCancellable {}
    private var telemetryConsensus: TelemetryConsensus = .shared
    
    let logger = Logger(subsystem: "MirrorHRTelemetry", category: "FYI")
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    // What to do when there is no internet? I think it's not worth handling a cache...
    internal var isConnected2Internet: Bool = true
    
    private init() {
        monitor.pathUpdateHandler = { pathUpdateHandler in
            DispatchQueue.main.async {
                if pathUpdateHandler.status == .satisfied {
                    self.isConnected2Internet = true
                } else {
                    self.isConnected2Internet = false
                }
            }
        }
        
        monitor.start(queue: queue)
        
        telemetryEngines.forEach { telemetryEngine in
            switch telemetryEngine {
            case .telemetryDeck:
                TelemetryDeck.initialize(config: TelemetryManagerConfiguration(appID: RoberdanSecretsPackage.telemetryDeckID))
            case .researchCloudApi:
                break
            }
        }
        
        telemetryEventSubscriber = telemetryEventsPublisher
            .sink(receiveValue: { telemetry in
                debugLog("TelemetryEvent received: \(telemetry)")
                self.handleTelemetryEvents(telemetry)
            })
    }
    
    // MARK: Handling Telemetry Events
    internal func handleTelemetryEvents(_ telemetry: Telemetries) {
        guard telemetry.isOn, isConnected2Internet else {
            // Can't send telemetry because \(event.eventType) is OFF OR there is no internet connection
            // TODO: handle lack of internet connectivity
            return
        }
        
        switch telemetry {
        case .booting(let userType, let watchStreamingStatus):
            TelemetryHeader.userType = userType
            TelemetryHeader.watchStreamingStatus = watchStreamingStatus
            sendTelemetry(telemetry)
            
        case .realTimeTelemetrySession(let jsonString):
            // MARK: Sending the BPM File here handling .realTimeTelemetrySession
            Task {
                await cloudApiManager.sendTelemetrySession(jsonString)
            }
            
            // MARK: handling all other events
        case .medicationReminders,
                .checkList,
                .dateOfBirth,
                .epilepsyType,
                .consensus,
                .valueChanged,
                .customAnalytics,
                .newCareGiver,
                .notificationHub,
                .mirrorHRError,
                .streaming:
            sendTelemetry(telemetry, engines: [.researchCloudApi])
        case .remoteBPM, .symptomsLogged, .remoteCommand:
            sendTelemetry(telemetry, toBeNotifiedToCareGivers: true, engines: [.researchCloudApi])
        }
    }
    
    private func sendTelemetry(_ telemetry: Telemetries, toBeNotifiedToCareGivers: Bool = false, engines: [TelemetryEngines] = TelemetryEngines.allCases, sendAsFile: Bool = false) {
        
        logger.log(level: .info, "Sending telemetry: \(telemetry.debugDescription) - ToBeNotifiedToCaregivers: \(toBeNotifiedToCareGivers)")
        
        let telemetryMessage: TelemetryMessage = TelemetryMessage(
            eventType: telemetry.eventType,
            event: telemetry.event,
            value: telemetry.value,
            toBeNotified: toBeNotifiedToCareGivers,
            notificationSupportStruct: telemetry.notificationSupportStruct
        )
        
        sendMessage(telemetryMessage, engines: engines, sendAsFile: sendAsFile)
        debugLog(telemetryMessage.jsonString())
    }
    
    private func sendMessage(_ message: TelemetryMessage, engines: [TelemetryEngines] = TelemetryEngines.allCases, sendAsFile: Bool = false) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self else { return }
            engines.forEach { telemetryEngine in
                var mixEvent = message.eventType
                if let event = message.event {
                    mixEvent = event
                }
                switch telemetryEngine {
                case .telemetryDeck:
                    var payload: [String: String] = [:]
                    if let value = message.value {
                        payload = [mixEvent: "\(value)"]
                    }
                    TelemetryDeck.signal(mixEvent, parameters: payload)
                case .researchCloudApi:
                    debugLog("Telemetry cloudAPiManager sending \(message.eventType), \(String(describing: message.event)), \(String(describing: message.value))")
                    if sendAsFile {
                        debugLog("MirrorHRTelemetry sendMessage - sending as FILE this \(message)")
                        self.cloudApiManager.sendMessageAsFile(message) { result in
                            debugLog(String(describing: result))
                            switch result {
                            case .success(let cloudAPIResponse):
                                debugLog("Telemetry cloudAPiManager sendMessageAsFile succesfully with \(String(describing: cloudAPIResponse))")
                            case .failure(let error):
                                debugLog(error.localizedDescription, isImportant: false, module: "MirrorHRTelemetry - send - researchCloudAPI case - sendMessageAsFile")
                            }
                        }
                    } else {
//#if DEBUG
//                        print("sending message as json: \(message.jsonString())")
//#endif
                        self.cloudApiManager.sendMessageAsJson(message) { result in
                            debugLog(String(describing: result))
                            switch result {
                            case .success(let cloudAPIResponse):
                                debugLog("Telemetry cloudAPiManager sendMessageAsJson succesfully with \(String(describing: cloudAPIResponse))")
                            case .failure(let error):
                                debugLog(error.localizedDescription, isImportant: false, module: "MirrorHRTelemetry - send - researchCloudAPI case - sendMessageAsJson")
                            }
                        }
                    }
                }
            }
        }
    }
}
