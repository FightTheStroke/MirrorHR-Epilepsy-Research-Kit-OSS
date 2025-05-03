# Streaming Package

High-performance real-time heart rate data streaming framework for MirrorHR monitoring.

## Overview

The Streaming package provides comprehensive functionality for transmitting real-time heart rate monitoring data between devices. It powers the remote monitoring features of MirrorHR, allowing caregivers to observe heart rate patterns and receive alerts when abnormal patterns are detected.

## Key Features

- **Real-time Data Transmission**: Low-latency streaming of heart rate data
- **Peer-to-Peer Communication**: Direct device-to-device communication using MultipeerConnectivity
- **Secure Messaging**: Encrypted message exchange for sensitive health data
- **Connection Management**: Robust connection handling with automatic reconnection
- **User Discovery**: Simple peer discovery and connection establishment
- **Efficient Serialization**: Optimized data encoding/decoding for minimal overhead
- **Status Monitoring**: Connection and streaming status tracking

## Architecture

The package is organized into several key components:

```
Streaming/
├── LocalStreamingManager.swift     # Main manager for streaming functionality
├── Extensions/                     # Extensions to core functionality
│   ├── MultiPeerDelegates.swift    # MultipeerConnectivity delegate implementation
│   ├── Reset.swift                 # State reset functionality
│   └── UIExtensions.swift          # UI-related extensions
├── Views/                          # SwiftUI views for streaming UI
│   ├── StreamingView.swift         # Main streaming interface
│   ├── PeerListView.swift          # Interface for selecting peers
│   └── StreamingStatusView.swift   # Connection status visualization
```

## Usage

### Setting Up Streaming

```swift
import Streaming
import SwiftUI
import SharedPkg

// Initialize the streaming manager
let streamingManager = LocalStreamingManager.shared

// Configure streaming
streamingManager.configure(
    displayName: "John's iPhone",
    serviceType: "mirror-hr-stream",
    isServer: true
)

// Start advertising availability
streamingManager.startAdvertising()
```

### Sending Heart Rate Data

```swift
// Send a heart rate reading
let heartRateMessage = StreamingMessage(
    messageType: .heartRate,
    value: 72,
    timestamp: Date().timeIntervalSince1970
)

streamingManager.sendMessage(heartRateMessage)
```

### Receiving Data

```swift
// Set up a subscriber to receive streaming updates
let cancellable = streamingManager.messagePublisher
    .sink { message in
        switch message.messageType {
        case .heartRate:
            let bpm = message.value
            print("Received heart rate: \(bpm) BPM")
        case .alarm:
            print("Alarm triggered!")
        default:
            break
        }
    }
```

### Streaming Interface

```swift
struct StreamingMonitorView: View {
    @ObservedObject var streamingManager = LocalStreamingManager.shared
    
    var body: some View {
        VStack {
            if streamingManager.isConnected {
                HeartRateDisplay(bpm: streamingManager.lastReceivedBPM)
                
                ConnectionStatusView(status: streamingManager.connectionStatus)
                
                Button("Disconnect") {
                    streamingManager.disconnect()
                }
            } else {
                PeerListView(peers: streamingManager.availablePeers) { peer in
                    streamingManager.connectToPeer(peer)
                }
                
                Button("Search for devices") {
                    streamingManager.startBrowsing()
                }
            }
        }
    }
}
```

## Performance Considerations

The Streaming package is optimized for real-time performance:

- **Message Prioritization**: Critical data (alarms) sent with higher priority
- **Bandwidth Optimization**: Efficient message formatting to minimize data transmission
- **Background Processing**: All network operations occur on background threads
- **Queue Management**: Prevents message flooding with throttling mechanisms
- **Resource Management**: Proper cleanup of network resources
- **Battery Awareness**: Adjusts transmission frequency based on battery levels

## Thread Safety

The Streaming package employs several techniques to ensure thread safety:

- **Serial Dispatch Queues**: Operations serialized through dedicated queues
- **Thread Confinement**: Network operations confined to appropriate threads
- **Atomic Operations**: For critical state changes
- **Main Thread UI Updates**: All UI updates dispatched to the main thread
- **Cancellable Operations**: All operations can be safely cancelled

## Requirements

- iOS 15.0+
- Swift 5.5+
- MultipeerConnectivity framework

## Integration

Add the Streaming package to your Swift Package Manager project:

```swift
dependencies: [
    .package(url: "path/to/Streaming", .branch("main"))
]

targets: [
    .target(
        name: "YourTarget",
        dependencies: ["Streaming"]
    )
]
```
