# MirrorHRTelemetryPackage

Comprehensive telemetry and analytics system for the MirrorHR medical monitoring application.

## Overview

MirrorHRTelemetryPackage provides a robust framework for collecting, processing, and transmitting telemetry data from the MirrorHR application. It handles anonymous usage statistics, error reporting, and caregiver notification services while maintaining strict privacy controls and user consent management.

## Key Features

- **Privacy-First Design**: All telemetry requires explicit user consent
- **Flexible Consent Management**: Granular consent options for different data types
- **Anonymous Data Collection**: Personally identifiable information (PII) is never collected
- **Error Reporting**: Structured error reporting with categorization
- **Usage Analytics**: Anonymous usage pattern tracking
- **Caregiver Notifications**: Secure communication with authorized caregivers
- **Health Event Logging**: Anonymized tracking of health-related events
- **Cloud API Integration**: Secure transmission to backend services
- **Battery Optimization**: Efficient data batching to minimize power consumption

## Architecture

```
MirrorHRTelemetryPackage/
├── TelemetryMain.swift              # Main entry point and configuration
├── TelemetriesConsent/              # User consent management
│   ├── ConsentManager.swift         # Handles user consent preferences 
│   └── EnumEngines.swift            # Defines telemetry categories
├── Protocols/                       # Core interfaces
│   └── TelemetryProtocols.swift     # Protocol definitions
├── Headers/                         # Message headers
│   └── TelemetryHeader.swift        # Common header structure
├── CloudAPI/                        # API communication
│   ├── CloudAPIManager.swift        # Manages API requests
│   ├── TelemetryMessage.swift       # Message structure
│   └── Responses.swift              # API response handling
├── CareGiversManager/               # Caregiver communication
│   └── CareGiversManager.swift      # Manages caregiver notifications
└── Helpers/                         # Utility components
    ├── Debugger.swift               # Logging utilities
    └── UserDefaults.swift           # Persistence helpers
```

## Usage

### Basic Setup

```swift
import MirrorHRTelemetryPackage
import RoberdanSecretsPackage
import SwiftUI

// Initialize in your app
@main
struct MyApp: App {
    init() {
        // Load environment variables for API keys
        RoberdanSecretsPackage.loadEnvironment()
        
        // Configure telemetry with app details
        TelemetryMain.shared.configure(
            appName: "MirrorHR",
            appVersion: "2.0.1",
            environment: .production
        )
        
        // TelemetryDeck App ID is automatically loaded from RoberdanSecretsPackage
        // The ID is retrieved from TELEMETRYDECK_APP_ID environment variable
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Handling User Consent

```swift
// Present consent view to user
struct TelemetryConsentView: View {
    @ObservedObject var consentManager = TelemetryConsentManager.shared
    
    var body: some View {
        VStack {
            Text("Help us improve MirrorHR")
                .font(.headline)
            
            Toggle("Allow anonymous usage statistics", 
                   isOn: $consentManager.usageStatisticsEnabled)
            
            Toggle("Allow error reporting", 
                   isOn: $consentManager.errorReportingEnabled)
            
            Button("Save Preferences") {
                consentManager.savePreferences()
            }
        }
        .padding()
    }
}
```

### Reporting Events

```swift
// Log a telemetry event
dispatchTelemetryEvent(event: .appLaunched)

// Log an error event
dispatchTelemetryEvent(event: .errorOccurred(
    errorCode: "ERR_1001",
    errorMessage: "Failed to connect to watch",
    severity: .warning
))

// Log a health-related event
dispatchTelemetryEvent(event: .symptomLogged(
    notificationSupportStruct: notificationStruct
))
```

### Managing Caregiver Communications

```swift
// Send notification to caregivers
CareGiversManager.shared.sendRemotCommandToMyCareGivers(
    command: .patientStartedRealTimeSession
)

// Check if caregiver notifications are enabled
if DataSourceManager.shared.dataSource.shouldSendKeyEventsToCareGivers {
    // Perform caregiver notification actions
}
```

## Performance Considerations

This package is designed to minimize impact on application performance:

- **Batched Uploads**: Data is batched to reduce API calls
- **Background Processing**: All telemetry operations run on background threads
- **Network Awareness**: Respects network conditions and device capabilities
- **Memory Efficiency**: Optimized data structures to minimize memory footprint
- **Throttling**: Rate limiting for high-frequency events
- **Error Resilience**: Graceful handling of connectivity issues

## Privacy and Security

The telemetry system adheres to strict privacy guidelines:

- **No Personal Data**: PII is never collected
- **Data Minimization**: Only necessary information is transmitted
- **Explicit Consent**: All telemetry requires opt-in consent
- **Secure Transmission**: Data encrypted in transit using TLS
- **Retention Policies**: Clear data retention and pruning policies
- **Anonymization**: All health data is anonymized
- **Secure API Keys**: TelemetryDeck App ID is securely managed via environment variables

## Thread Safety

The package implements several thread safety measures:

- **Dedicated Dispatch Queues**: Isolation of API operations
- **Thread Confinement**: UI updates on main thread only
- **Atomic Operations**: Thread-safe state changes
- **Synchronization**: Resource locking where needed

## Requirements

- iOS 15.0+
- Swift 5.5+
- Network connectivity for telemetry transmission

## Integration

Add MirrorHRTelemetryPackage to your Swift package:

```swift
dependencies: [
    .package(url: "path/to/MirrorHRTelemetryPackage", .branch("main"))
]

targets: [
    .target(
        name: "YourTarget",
        dependencies: ["MirrorHRTelemetryPackage"]
    )
]
```
