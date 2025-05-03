//
//  StreamingManager.swift
//
//
//  Created by Roberto D’Angelo on 12/08/22.
//

import Foundation
import MultipeerConnectivity
import Combine
import SharedPkg
import SwiftUI
import MirrorHRTelemetryPackage

// TODO: sistemare i messaggi di errore nel caso dello streaming es. non riesco a far partire l'apple watch controlla che sia in foreground
// TODO: Salvare i videolog e seizure nel folder immagini, o come diamine lo mando al medico??

public class LocalStreamingManager: NSObject, ObservableObject,
                                ResettableToDefaultSetting,
                                EventsSubscriber {
    public static let shared = LocalStreamingManager()
    public var eventSubscriber: AnyCancellable = AnyCancellable {}
    public var resetToDefaultValues = AnyCancellable {}
    internal static let service = "mirrorHR" // it should be shorter than 15 characters
    
    @AppStorage(StreamingStorageKeys.isEnabled.value) public var isEnabled: Bool = false {
        didSet {
            if isEnabled != oldValue {
                if isEnabled {
                    dispatchMainEvent(.streamingUnderstandAlert, "LocalStreamingManager")
                } else {
                    leaveStream()
                }
            }
        }
    }
    
    @AppStorage(StreamingStorageKeys.isServer.value) public var isServer: Bool = false
    @AppStorage(StreamingStorageKeys.isClient.value) public var isClient: Bool = false
    
    @Published public var peers: [MCPeerID] = []
    @Published public var connectedToStream = false
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    internal var advertiserAssistant: MCNearbyServiceAdvertiser?
    internal var session: MCSession?
    
    public override init() {
        super.init()
        setStorage(UserDefaults.standard, into: self)
        eventSubscriber = mainEventsPublisher
            .sink(receiveValue: { event in
                DispatchQueue.main.async {
                    self.handleEvents(event: event)
                }
            })
    }
}
