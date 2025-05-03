# RoberdanToolbox

A comprehensive utility toolkit providing debugging tools, extensions, and helper functions for the MirrorHR ecosystem.

## Overview

RoberdanToolbox offers a collection of utilities to simplify common operations in iOS development, with a focus on debugging, string manipulation, date handling, and UI extensions. This package serves as the foundation for many utility functions across the MirrorHR application.

## Key Components

### Debugger

Advanced debugging system with categorized logging, persistence, and filtering:

```swift
// Log an event with category
mainDebugger.append("Heart rate monitoring started", .event)

// Log an error with source
mainDebugger.append("Failed to connect to watch", .error, sourceModule: "WatchConnectivity")

// Get debug logs as string
let logs = mainDebugger.getDebugLog(maxRecords: 100)
```

### String Helpers

String manipulation utilities for common operations:

```swift
// Localization shorthand
let localizedText = "welcome_message".local()

// String cleaning and formatting
let cleaned = "some/path".prepare4CSV()

// String validation
let isValid = "test@example.com".isValidEmail()
```

### Date Extensions

Enhanced date handling with readable formatting and calculations:

```swift
// Format a date as a standard string
let dateString = Date().toStdString()

// Get date components easily
let dayOfWeek = Date().dayOfWeek()

// Date arithmetic
let yesterday = Date().daysAgo(number: 1)
let nextWeek = Date().addDay(number: 7)
```

### UI Extensions

SwiftUI and UIKit extensions for common UI tasks:

```swift
// Add shadow to a view
Text("Hello").applyShadow(radius: 5)

// Create a gradient background
Rectangle().fill(LinearGradient.rainbowGradient)

// Hide keyboard
UIApplication.shared.endEditing()
```

### File System Tools

Simplified file system operations with error handling:

```swift
// Get document directory URL
let docsURL = getDocumentsURL()

// Check if file exists
let exists = fileExists(at: fileURL)

// Get list of files matching pattern
let audioFiles = getFilesFromDocuments(withExtension: "mp3")
```

## Performance Considerations

The utilities in this package are designed with performance in mind:

- **Memory Efficiency**: Methods avoid excessive object creation
- **Lazy Evaluation**: Using lazy properties where appropriate
- **Optimized Algorithms**: String and collection operations use efficient algorithms
- **Resource Management**: File operations clean up resources properly

## Thread Safety

When using the utilities in this package:

- The `Debugger` is thread-safe and can be called from any thread
- File operations should be performed on background threads
- UI extensions should be used on the main thread
- Date and string utilities are generally thread-safe

## Requirements

- iOS 15.0+
- Swift 5.5+

## Installation

Add RoberdanToolbox to your project via Swift Package Manager:

```swift
dependencies: [
    .package(url: "path/to/RoberdanToolbox", .branch("main"))
]
```

## Usage Example

```swift
import RoberdanToolBox

// Configure debugger
MainDebugger.shared.configure(maxRecords: 1000, persist: true)

// Log events
mainDebugger.append("Application started", .greenFlag)

// Format dates
let formattedDate = Date().toStdString()

// Perform file operations
if let documentsURL = getDocumentsURL() {
    let files = getFilesFromDocuments(withExtension: "json")
    for file in files {
        mainDebugger.append("Found file: \(file.lastPathComponent)")
    }
}

// Use UI extensions
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .applyShadow(radius: 5)
            .padding()
    }
}
```
