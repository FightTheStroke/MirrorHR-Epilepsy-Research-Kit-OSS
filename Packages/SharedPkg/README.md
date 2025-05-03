# SharedPkg

A core package containing shared models, utilities, and constants used throughout the MirrorHR application.

## Overview

SharedPkg provides foundational types, utilities, and constants that are shared between multiple components of the MirrorHR application. It serves as a central repository for common functionality to ensure consistency across the codebase.

## Features

- **Constants**: Application-wide constants and configuration values
- **Event System**: Centralized event system for inter-module communication
- **Health Data Models**: Shared models for representing health data
- **Utility Extensions**: Extensions to standard types for common operations
- **Localization**: Localization utilities and string extensions
- **UI Components**: Reusable UI components and styles

## Key Components

### Global Constants

Constants that define application behavior, such as:
- Version information
- Default alarm settings
- Communication identifiers
- Threshold values for monitoring
- Default user settings

```swift
// Example of global constants
public let iPhoneSocketUsername = "MirrorHR iPhone"
public let watchSocketUsername = "MirrorHR Watch"
public let defaultAlarmMin: Int = 50
public let defaultAlarmMax: Int = 135
```

### KISSFlowManager

Manages the heart rate analysis workflow for detecting potential seizures:

```swift
public class KISSFlowManager: ObservableObject, ErasableClass, Codable {
    // Implementation details
}
```

### HandledSymptomsEvents

Enum defining all tracked symptoms and events:

```swift
public enum HandledSymptomsEvents: String, CaseIterable, Identifiable, Codable {
    case seizure
    case aura
    case medication
    // More cases
}
```

### Event System

Centralized event dispatch system for application-wide communication:

```swift
public func dispatchMainEvent(_ event: MainEvents, _ source: String)
```

## Usage

To use SharedPkg in your Swift package:

```swift
// In Package.swift
dependencies: [
    .package(name: "SharedPkg", path: "../Packages/SharedPkg")
]

// In target dependencies
.product(name: "SharedPkg", package: "SharedPkg")
```

To import in your Swift file:

```swift
import SharedPkg
```

## Examples

### Using Constants

```swift
import SharedPkg

// Access global constants
let maxAlarmValue = defaultAlarmMax
let warningDelta = defaultWarningDelta
```

### Using the Event System

```swift
import SharedPkg

// Dispatch an event
dispatchMainEvent(.alarmStarted, "HeartRateMonitor")

// Subscribe to events
let subscription = mainEventsPublisher.sink { event in
    // Handle the event
}
```

### Using Shared Models

```swift
import SharedPkg

// Create a symptom log
let symptomLog = SymptomLog(
    .seizure,
    startDate: Date(),
    endDate: Date().addingTimeInterval(60),
    notes: "Brief mild seizure"
)
```

## Performance Considerations

- The event system uses Combine for efficient publish-subscribe operations
- Models are optimized for serialization/deserialization
- Extensions are designed for minimal memory and CPU impact

## Thread Safety

Components in SharedPkg are designed to be thread-safe where appropriate:

- Constants are immutable and safe to access from any thread
- Event dispatch is thread-safe
- Model operations should be performed on appropriate dispatch queues

## Maintenance Guidelines

When modifying this package:

1. Ensure backward compatibility whenever possible
2. Add comprehensive documentation to all public APIs
3. Maintain thread safety for shared components
4. Add unit tests for new functionality
5. Follow Swift API Design Guidelines

## Contribution

When contributing to SharedPkg:

1. Ensure your code is well-documented
2. Write unit tests for new functionality
3. Update this README if you add major new components
