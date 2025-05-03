# PermissionsManager Package for SwiftUI

A streamlined, SwiftUI-native permission management system for iOS applications.

## Overview

PermissionsManager provides a complete solution for requesting, tracking, and managing app permissions with a user-friendly interface. It handles the complexities of permission states and offers a customizable permission request flow that integrates seamlessly with SwiftUI applications.

## Features

- **SwiftUI Native**: Built specifically for SwiftUI using the latest patterns
- **Asynchronous APIs**: Fully async/await compatible
- **Event-Driven**: Uses Combine for reactive updates
- **Multiple Permission Types**: Support for all common iOS permissions:
  - Notifications
  - Critical Alerts
  - Health
  - Camera
  - Microphone
  - Speech Recognition
  - Location
  - Motion
  - Photos
  - Contacts
  - Calendar
  - Reminders
- **Mandatory vs Optional**: Distinguish between required and optional permissions
- **Customizable UI**: Fully customizable permission request screens
- **Localization**: Supports 17 languages out of the box
- **Extensible**: Easily add support for new permission types

## Installation

### Swift Package Manager

Add PermissionsManager to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "path/to/PermissionsManager", branch: "main")
]
```

## Usage

### Basic Setup

```swift
import PermissionsManager
import SwiftUI

@main
struct MyApp: App {
    @StateObject private var permissionsManager = PermissionsManager.shared
    
    init() {
        PermissionsManager.shared.personalize(
            appName: "MyApp",
            supportEmail: "support@myapp.com",
            permissionsToHandle: [
                .notifications(isMandatory: true),
                .health(isMandatory: true),
                .criticalNotification(isMandatory: false),
                .camera(isMandatory: false)
            ]
        )
    }
    
    var body: some Scene {
        WindowGroup {
            if permissionsManager.canGoAhead {
                MainContentView()
            } else {
                PermissionsManagerView(skippable: true)
            }
        }
    }
}
```

### Custom Permission Flow

For more control over the permission flow:

```swift
struct CustomPermissionFlow: View {
    @ObservedObject private var permissionsManager = PermissionsManager.shared
    
    var body: some View {
        VStack {
            Text("We need a few permissions to provide you with the best experience.")
                .font(.headline)
                .padding()
            
            ForEach(permissionsManager.pendingPermissions) { permission in
                PermissionRequestCard(permission: permission)
                    .padding(.horizontal)
            }
            
            Button("Continue") {
                permissionsManager.requestNextPermission()
            }
            .disabled(!permissionsManager.canRequestNext)
        }
    }
}
```

### Checking Individual Permissions

```swift
if await PermissionsManager.shared.checkPermissionStatus(for: .camera) == .authorized {
    // Camera permission is granted
}

// Request a specific permission
do {
    let status = try await PermissionsManager.shared.requestPermission(for: .microphone)
    if status == .authorized {
        // Microphone permission granted
    }
} catch {
    // Handle error
}
```

## Permission Types

PermissionsManager supports the following permission types:

```swift
public enum PermissionType {
    case notifications(isMandatory: Bool)
    case criticalNotification(isMandatory: Bool)
    case health(isMandatory: Bool)
    case location(isMandatory: Bool)
    case camera(isMandatory: Bool)
    case microphone(isMandatory: Bool)
    case speech(isMandatory: Bool)
    case photos(isMandatory: Bool)
    case contacts(isMandatory: Bool)
    case calendar(isMandatory: Bool)
    case reminders(isMandatory: Bool)
    case motion(isMandatory: Bool)
    // Add custom permissions as needed
}
```

## Extending for New Permission Types

Create a new permission manager by implementing the `PermissionManagerProtocol`:

```swift
public class NewTypePermissionManager: PermissionManagerProtocol {
    public var type: PermissionType
    public var status: PermissionStatus = .notDetermined
    
    public init(type: PermissionType) {
        self.type = type
    }
    
    public func checkStatus() async -> PermissionStatus {
        // Implement status check
        return .notDetermined
    }
    
    public func requestPermission() async throws -> PermissionStatus {
        // Implement permission request
        return .notDetermined
    }
}

// Then register it with the PermissionsManager
PermissionsManager.shared.registerCustomPermissionManager(NewTypePermissionManager.self, for: .newType)
```

## Localization

The package includes localization for 17 languages:
- English
- Spanish
- French
- German
- Italian
- Chinese (Simplified & Traditional)
- Japanese
- Korean
- Russian
- Portuguese
- Dutch
- Swedish
- Turkish
- Arabic
- Hindi
- Polish

## Requirements

- iOS 15.0+
- Swift 5.5+
- SwiftUI 3.0+

## License

BSD-3 License

Copyright (c) 2019-2025 Roberdan@FightTheStroke.org for FightTheStroke Foundation (www.fightthestroke.org)
