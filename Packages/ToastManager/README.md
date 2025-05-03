# ToastManager

A lightweight, customizable toast notification system for iOS, watchOS, and macOS applications.

## Overview

ToastManager provides a simple way to display non-intrusive toast notifications in your app with customizable appearance, duration, and positioning. It's designed to be easy to integrate while offering flexibility for different notification needs.

## Features

- Simple API for showing/hiding toast notifications
- Customizable appearance (background color, text color, font)
- Multiple positioning options (top, center, bottom)
- Configurable display duration
- Animation support
- Queue management for multiple concurrent notifications
- Accessibility support
- Support for iOS, watchOS, and macOS

## Installation

### Swift Package Manager

Add ToastManager to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "path/to/ToastManager", branch: "main")
]
```

## Usage

### Basic Example

```swift
import ToastManager

// Show a simple toast notification
ToastManager.shared.show(message: "File saved successfully")

// Show with custom duration
ToastManager.shared.show(message: "Upload complete!", duration: 5.0)

// Show with custom style
ToastManager.shared.show(
    message: "Error: Could not connect to server", 
    backgroundColor: .systemRed,
    textColor: .white,
    font: .boldSystemFont(ofSize: 16),
    position: .top
)
```

### Advanced Usage

```swift
// Create a custom ToastConfiguration
let configuration = ToastConfiguration(
    message: "Profile updated successfully",
    icon: UIImage(systemName: "checkmark.circle"),
    backgroundColor: UIColor(red: 0.2, green: 0.3, blue: 0.9, alpha: 0.9),
    textColor: .white,
    font: .systemFont(ofSize: 14, weight: .medium),
    cornerRadius: 8,
    position: .bottom,
    duration: 3.0,
    hapticFeedback: true,
    showProgress: false,
    action: ("View", {
        // Handle tap action
        print("Toast tapped")
    })
)

// Show toast with custom configuration
ToastManager.shared.show(configuration: configuration)
```

## Customization

### Toast Appearance

You can customize several aspects of the toast notifications:

- Background color
- Text color
- Font
- Corner radius
- Shadow
- Icon
- Progress indicator

### Toast Behavior

Configure how toasts behave in your app:

- Display duration
- Position on screen
- Animation style
- Haptic feedback
- Tap actions
- Swipe to dismiss

## Requirements

- iOS 16.0+ / watchOS 8.0+ / macOS 10.15+
- Swift 5.7+

## License

This package is part of the MirrorHR project and follows the same license terms.
