# MirrorHRKit

The core framework of the MirrorHR application providing health monitoring, symptom tracking, and data analysis capabilities.

## Overview

MirrorHRKit is the main framework that powers the MirrorHR application. It provides comprehensive functionality for heart rate monitoring, symptom tracking, medication management, and health data analysis for epilepsy monitoring and management.

## Architecture

MirrorHRKit follows a modular architecture with clear separation of concerns:

```
┌──────────────────────────────────────────────────────────────┐
│                        MirrorHRKit                           │
├───────────────┬──────────────┬─────────────────┬────────────┤
│ MainClasses   │ DataSources  │ SymptomsManager │ VideoLog   │
├───────────────┼──────────────┼─────────────────┼────────────┤
│ TherapyManager│ Notifications│ BackupManager   │ Statistics │
└───────────────┴──────────────┴─────────────────┴────────────┘
```

## Key Components

### MainClasses

Core classes that manage the application's main functionality:

- `MirrorHRMainClass`: Central coordinator
- `MirrorHRWorkOut`: Manages workout sessions for heart rate monitoring
- `KISSFlowManager`: Heart rate analysis and seizure detection
- `RealTimeEventsManager`: Real-time event handling
- `ProfileGenericSettings`: User settings and preferences

### DataSourceManager

Manages data sources for health monitoring:

- Source selection (Apple Watch, external devices)
- Data validation and preprocessing
- Connection management
- Fallback and recovery mechanisms

### SymptomsManager

Comprehensive symptom tracking system:

- CoreData persistence
- Symptom logging and categorization
- Filtering and searching
- Analytics and pattern detection
- Timeline visualization support

### VideoLog

Video diary processing system:

- Video recording
- Speech-to-text transcription
- NLP for symptom detection
- Sentiment analysis
- User validation workflow

### TherapyManager

Medication and therapy management:

- Medication scheduling
- Reminders and adherence tracking
- Medication efficacy monitoring
- Drug and dosage management

### NotificationManager

Handles all application notifications:

- Seizure alerts
- Medication reminders
- Critical notifications
- Background processing
- Caregiver notifications

### BackupManager

Manages data backup and restore:

- JSON serialization
- Data integrity validation
- File management
- Progress reporting
- Error recovery

### Statistics

Statistical analysis tools:

- Trend analysis
- Correlation detection
- Report generation
- Data visualization

## Performance Guidelines

MirrorHRKit is designed for real-time heart rate monitoring and requires careful consideration of performance:

1. **Real-time Processing**
   - Prioritize real-time data handling over memory optimization
   - Maintain consistent update frequency without dropping samples
   - Minimize blocking operations in the real-time monitoring pipeline
   - Ensure predictable latency for critical alerting functions

2. **Memory Management**
   - Use `autoreleasepool` for memory-intensive operations in non-critical paths
   - Implement proper resource cleanup with cancellable tasks
   - Apply pagination for presenting historical data only, never real-time data
   - Monitor memory footprint in extended monitoring sessions

3. **Thread Safety**
   - Isolate UI updates on the main thread
   - Process intensive operations on background threads without blocking monitoring
   - Use serial queues for sequential operations requiring ordering
   - Apply atomic operations for shared resources to prevent race conditions

4. **Error Handling**
   - Implement comprehensive error recovery mechanisms
   - Design for graceful degradation of non-critical components
   - Maintain core monitoring functionality even when peripheral features fail
   - Provide structured logging and diagnostics for troubleshooting

5. **Battery Optimization**
   - Balance monitoring frequency and battery consumption
   - Implement efficient communication between Watch and iPhone
   - Use conditional processing based on monitoring criticality
   - Monitor and report battery status to prevent unexpected shutdowns

## Usage

### Initialization

```swift
import MirrorHRKit

// Access the shared instance
let mirrorHR = MirrorHRMainClass.shared
let symptomsManager = SymptomsManager.shared
```

### Heart Rate Monitoring

```swift
// Start real-time monitoring
mirrorHR.startMonitoring(from: .appleWatch)

// Handle events
RealTimeEventsManager.shared.handleAlarmStarted = { bpm in
    // React to alarm
}
```

### Symptom Tracking

```swift
// Log a symptom
let symptomLog = SymptomLog(.seizure, 
                           startDate: Date(),
                           endDate: Date().addingTimeInterval(60),
                           notes: "Brief seizure after dinner")
SymptomsManager.shared.appendSymptomLog(symptomLog)

// Fetch symptoms with pagination
SymptomsManager.shared.fetchPaginated(page: 0, pageSize: 20) { result in
    switch result {
    case .success(let symptoms):
        // Process symptoms
    case .failure(let error):
        // Handle error
    }
}
```

### Video Diary

```swift
// Process a video diary
let flowManager = AugumentVideoLogFlowManager(videoURL: videoURL,
                                            output: .everything) { status, transcript, sentiment, symptoms in
    // Handle results
}
flowManager.aIFlowStatus = .start
```

### Backup and Restore

```swift
// Create a backup
BackupManager.createJSONBackup { result in
    switch result {
    case .success(let jsonString):
        // Save or send the backup
    case .failure(let error):
        // Handle error
    }
} progressUpdate: { progress in
    // Update UI with progress
}
```

## Error Handling

MirrorHRKit provides structured error handling:

```swift
do {
    try operation()
} catch let error as CoreDataError {
    // Handle Core Data specific errors
} catch let error as NetworkError {
    // Handle network specific errors
} catch {
    // Handle other errors
}
```

## Thread Safety

Components in MirrorHRKit are designed with thread safety in mind:

- Context operations in CoreData use proper threading
- UI updates are dispatched to the main thread
- Heavy operations use background queues
- Shared resources use synchronization mechanisms

## Customization

MirrorHRKit can be customized through various settings:

```swift
// Customize alarm thresholds
KeyFlowThresholds.shared.alarmMax = 150
KeyFlowThresholds.shared.alarmMin = 45

// Customize notification preferences
NotificationManager.shared.enableCriticalNotifications = true
```

## Requirements

- iOS 15.0+
- watchOS 8.0+
- Swift 5.5+
- Xcode 13.0+

## Dependencies

- SwiftUI
- Combine
- CoreData
- HealthKit
- AVFoundation
- Speech
- SharedPkg
- RoberdanToolBox
