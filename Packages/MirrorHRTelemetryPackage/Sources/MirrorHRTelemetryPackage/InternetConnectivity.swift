//
//  InternetConnectivity.swift
//
//
//  Created by Roberto D’Angelo on 19/05/24.
//

import Foundation
import Network
import Combine
import SwiftUI

public class NetworkMonitor: ObservableObject {
    static public let shared = NetworkMonitor()
    
    private var monitor: NWPathMonitor
    private var queue: DispatchQueue
    @Published public var isConnected: Bool = false
    @Published public var connectionType: ConnectionType = .unknown
    
    public enum ConnectionType {
        case wifi
        case cellular
        case wiredEthernet
        case other
        case unknown
    }
    
    private init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue.global(qos: .background)
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.getConnectionType(from: path) ?? .unknown
            }
        }
        monitor.start(queue: queue)
    }
    
    private func getConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .wiredEthernet
        } else if path.usesInterfaceType(.other) {
            return .other
        } else {
            return .unknown
        }
    }
    
    deinit {
        monitor.cancel()
    }
}


struct InternetConnectivityTestView: View {
    @ObservedObject var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        VStack {
            if networkMonitor.isConnected {
                Text("Connected to the internet via \(networkMonitor.connectionType.description)")
            } else {
                Text("No internet connection")
            }
        }
        .padding()
        .onAppear {
            // Perform any additional setup if needed
        }
    }
}

extension NetworkMonitor.ConnectionType {
    var description: String {
        switch self {
        case .wifi:
            return "WiFi"
        case .cellular:
            return "Cellular"
        case .wiredEthernet:
            return "Wired Ethernet"
        case .other:
            return "Other"
        case .unknown:
            return "Unknown"
        }
    }
}
