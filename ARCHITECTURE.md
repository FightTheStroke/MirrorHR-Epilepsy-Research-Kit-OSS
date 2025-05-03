# MirrorHR Architecture Documentation

This document provides a detailed technical overview of MirrorHR's architecture, designed to help developers understand the system structure, data flow, and key components.

## Table of Contents

1. [High-Level Architecture](#high-level-architecture)
2. [Core Components](#core-components)
3. [Data Flow](#data-flow)
4. [State Management](#state-management)
5. [Threading Model](#threading-model)
6. [Storage Architecture](#storage-architecture)
7. [Watch Connectivity](#watch-connectivity)
8. [Real-time Monitoring Engine](#real-time-monitoring-engine)
9. [Key Algorithms](#key-algorithms)
10. [External Integrations](#external-integrations)
11. [Performance Considerations](#performance-considerations)
12. [Security Architecture](#security-architecture)

## High-Level Architecture

MirrorHR follows a modular architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                        │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────────────────┐  │
│  │ iOS UI      │ │ Watch UI     │ │ Widget Extensions    │  │
│  │ (SwiftUI)   │ │ (SwiftUI)    │ │ (SwiftUI)           │  │
│  └─────────────┘ └──────────────┘ └──────────────────────┘  │
└────────────┬─────────────────┬──────────────────┬───────────┘
             │                 │                  │
┌────────────▼─────────────────▼──────────────────▼───────────┐
│                     Domain Layer                            │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────────────────┐  │
│  │ MainClasses │ │ Profile Mgmt │ │ Session Coordinator  │  │
│  └─────────────┘ └──────────────┘ └──────────────────────┘  │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────────────────┐  │
│  │ Symptoms    │ │ Therapy      │ │ Analytics Engine     │  │
│  │ Manager     │ │ Manager      │ │                      │  │
│  └─────────────┘ └──────────────┘ └──────────────────────┘  │
└────────────┬─────────────────┬──────────────────┬───────────┘
             │                 │                  │
┌────────────▼─────────────────▼──────────────────▼───────────┐
│                     Data Layer                              │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────────────────┐  │
│  │ Core Data   │ │ HealthKit    │ │ Cloud Sync           │  │
│  │ Storage     │ │ Integration  │ │                      │  │
│  └─────────────┘ └──────────────┘ └──────────────────────┘  │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────────────────┐  │
│  │ Local Files │ │ Backup Mgr   │ │ Telemetry            │  │
│  └─────────────┘ └──────────────┘ └──────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

The architecture follows a modified MVVM pattern with Combine for reactive data flows.

## Core Components

### MirrorHRKit

The core framework that contains most of the domain logic and coordination.

#### Main Components:

1. **MirrorHRMainClass**: Central coordinator for the application.
   - Manages sessions, state transitions, and component communication
   - Initializes and configures subsystems
   - Coordinates background/foreground transitions

2. **KISSFlowManager**: Real-time heart rate analysis engine.
   - Processes incoming BPM data
   - Applies pattern recognition algorithms
   - Identifies potential seizure patterns
   - Issues alerts based on configurable thresholds

3. **SymptomsManager**: Tracks and analyzes symptom records.
   - Stores symptom history
   - Integrates with video diary features
   - Provides correlation with other health data
   - Generates symptom reports and insights

4. **TherapyManager**: Medication and treatment tracking.
   - Manages medication schedules
   - Issues reminders
   - Tracks adherence
   - Correlates with symptoms

### Supporting Packages

1. **SharedPkg**: Common models, enums, and protocols.
2. **RoberdanToolbox**: Utilities and debugging tools.
3. **PermissionsManager**: Handles iOS permissions requests.
4. **Streaming**: Real-time data streaming between devices.
5. **MirrorHRTelemetryPackage**: Anonymized usage analytics.

## Data Flow

MirrorHR uses a publisher/subscriber pattern for most data flows, implemented with Combine:

1. **Heart Rate Monitoring Flow**:
   ```
   Apple Watch → WatchKit Extension → Watch Connectivity → 
   iPhone App → KISSFlowManager → Analysis → Event Publishers →
   UI Updates + Alert System + Data Storage
   ```

2. **Symptom Recording Flow**:
   ```
   User Input → SymptomsManager → Data Validation → 
   Storage → Analytics → UI Updates
   ```

3. **Video Diary Flow**:
   ```
   Video Recording → Speech Recognition → NLP Processing → 
   Symptom Extraction → User Validation → Symptom Storage
   ```

## State Management

The application uses a state machine approach for core components:

1. **Session States**:
   - `idle`: No active monitoring
   - `starting`: Initializing sensors and connections
   - `monitoring`: Active heart rate monitoring
   - `paused`: Temporarily paused monitoring
   - `ending`: Gracefully shutting down monitoring
   - `error`: Error state with recovery options

2. **Data Source States**:
   - `appleWatch`: Using Apple Watch as primary BPM source
   - `healthKit`: Using HealthKit historical data
   - `simulatedData`: Using test data (development only)
   - `remoteStreaming`: Receiving data from another device

## Threading Model

MirrorHR employs a disciplined threading model:

1. **Main Thread**: UI updates and user interaction
2. **Background Queues**:
   - `analysisQueue`: Heart rate pattern analysis (high priority)
   - `storageQueue`: Data persistence operations (utility priority)
   - `processingQueue`: Video and audio processing (background priority)

Critical sections use appropriate synchronization mechanisms:
- `os_unfair_lock` for lightweight locking
- Dispatch semaphores for resource serialization
- Serial queues for ordered operations

## Storage Architecture

### Core Data Stack

The application uses a multi-context Core Data architecture:

1. **Main Context**: UI-bound, read-only operations
2. **Background Context**: Write operations
3. **Private Contexts**: Temporary operations (import/export)

The schema includes these main entities:
- `SymptomLog`: Records of symptoms and events
- `HeartRateSession`: Monitoring session metadata
- `HeartRateSample`: Individual heart rate measurements
- `Medication`: Medication records
- `MedicationDose`: Individual medication doses

### File Storage

Certain data types use file-based storage:
- Video diary recordings
- Audio logs
- Export files
- Backup archives

## Watch Connectivity

Communication between the iPhone and Apple Watch uses a multi-channel approach:

1. **Application Context**: Current session state
2. **User Info**: Configuration updates
3. **File Transfers**: Larger datasets (infrequent)
4. **Interactive Messages**: Real-time data (heart rate updates)
5. **Complications**: Watch face updates

The system handles connectivity transitions and reconnection automatically.

## Real-time Monitoring Engine

The heart rate monitoring system uses a multi-stage pipeline:

1. **Data Acquisition**:
   - Watch workout session for real-time heart rate
   - HealthKit historical data
   - Background delivery capabilities

2. **Preprocessing**:
   - Noise filtering
   - Outlier detection
   - Signal quality assessment

3. **Pattern Analysis**:
   - Moving averages (short and long-term)
   - Rate of change detection
   - Pattern matching against known seizure signatures
   - Adaptive thresholds based on user baseline

4. **Alert Generation**:
   - Multi-level alerts (info, warning, critical)
   - Caregiver notifications
   - Local device alerts

## Key Algorithms

### Heart Rate Analysis

The heart rate analysis uses several algorithms:

1. **Baseline Establishment**:
   ```swift
   func calculateBaseline(samples: [HeartRateSample], period: TimeInterval) -> Double {
       // Filter samples within baseline period
       let baselineSamples = samples.filter { 
           $0.timestamp > Date().addingTimeInterval(-period) 
       }
       
       // Calculate the baseline
       let values = baselineSamples.map { $0.value }
       return values.reduce(0, +) / Double(values.count)
   }
   ```

2. **Seizure Pattern Detection**:
   ```swift
   func detectPotentialSeizure(samples: [HeartRateSample], 
                              baseline: Double, 
                              thresholds: ThresholdConfiguration) -> SeizureDetectionResult {
       // Calculate rate of change over time
       let rateOfChangeValues = calculateRateOfChange(samples)
       
       // Check for rapid increase
       let hasRapidIncrease = rateOfChangeValues.contains { 
           $0 > thresholds.rapidIncreaseThreshold 
       }
       
       // Check for elevated heart rate
       let hasElevatedHeartRate = samples.suffix(3).allSatisfy { 
           $0.value > baseline * thresholds.elevationMultiplier 
       }
       
       // Check for sustained elevation
       let hasSustainedElevation = calculateSustainedElevation(
           samples: samples, 
           baseline: baseline,
           threshold: thresholds.sustainedElevationThreshold,
           duration: thresholds.sustainedElevationDuration
       )
       
       // Combine signals into a result
       return SeizureDetectionResult(
           hasRapidIncrease: hasRapidIncrease,
           hasElevatedHeartRate: hasElevatedHeartRate,
           hasSustainedElevation: hasSustainedElevation,
           confidenceScore: calculateConfidenceScore(...)
       )
   }
   ```

### Natural Language Processing

The video diary analysis uses NLP techniques:

1. **Symptom Extraction**:
   ```swift
   func extractSymptoms(from transcript: String) -> [Symptom] {
       // Tokenize and normalize text
       let tokens = tokenize(transcript)
       
       // Match against symptom dictionary with context
       let matches = findSymptomMatches(in: tokens)
       
       // Resolve ambiguities and conflicts
       return resolveSymptoms(matches)
   }
   ```

## External Integrations

### HealthKit

MirrorHR integrates with HealthKit for:
- Reading heart rate data
- Accessing sleep analysis
- Exercise and activity information
- Height/weight for medication calculations

### Azure Notification Hub

Used for secure remote notifications:
- Caregiver alerts
- Remote monitoring status updates
- Data synchronization triggers

### OpenAI

Used for enhanced natural language processing:
- Symptom extraction from video diaries
- Context-aware analysis of user descriptions
- Sentiment analysis

## Performance Considerations

1. **Battery Optimization**:
   - Adaptive sampling rates based on context
   - Background processing limitations
   - Watch power management during monitoring

2. **Memory Management**:
   - Streaming data processing to avoid memory pressure
   - Cache management for historical data
   - Video processing optimizations

3. **Responsiveness**:
   - Critical paths optimized for minimal latency
   - Alert generation prioritized over other operations
   - Background tasks throttled during user interaction

## Security Architecture

1. **Data Protection**:
   - Health data stored with `NSFileProtectionComplete`
   - Sensitive fields use secure coding
   - HTTPS for all network communications

2. **Authentication**:
   - Biometric authentication for sensitive operations
   - Secure caregiver pairing mechanism
   - Revocation capabilities for shared access

3. **Privacy Controls**:
   - Granular permission management
   - Data minimization principles
   - Anonymized analytics

4. **Configuration Security**:
   - Environment variables for secrets
   - Runtime credential verification
   - Secure storage for API keys and tokens

---

For detailed implementation specifics, refer to the source code documentation and inline comments. This architecture may evolve over time as new features and optimizations are implemented.