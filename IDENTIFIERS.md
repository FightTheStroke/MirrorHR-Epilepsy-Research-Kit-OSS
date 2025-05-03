# MirrorHR Identifiers Reference

This document provides a comprehensive list of all identifiers used throughout the MirrorHR project and how they should be replaced for your own implementation.

## Core Identifiers

| Placeholder Identifier | Description | Replacement Pattern |
|---------------------|-------------|---------------------|
| `YOURTEAMID` | Apple Developer Team ID | Your Apple Developer Team ID |
| `com.example.MirrorHR-App` | Main app bundle identifier | `your.bundle.prefix.app-name` |
| `com.example.MirrorHR-App.watchkitapp` | WatchKit app bundle identifier | `your.bundle.prefix.app-name.watchkitapp` |
| `com.example.MirrorHR-App.widget` | Widget extension bundle identifier | `your.bundle.prefix.app-name.widget` |
| `group.example.MirrorHR-App` | App group identifier for shared data | `group.your.bundle.prefix.app-name` |
| `merchant.example.MirrorHR-App` | Apple Pay merchant identifier | `merchant.your.bundle.prefix.app-name` |

## Background Task Identifiers

| Placeholder Identifier | Description | Replacement Pattern |
|---------------------|-------------|---------------------|
| `com.example.MirrorHR-App.keepStreamingActive` | Background task for streaming | `your.bundle.prefix.app-name.keepStreamingActive` |
| `com.example.MirrorHR-App.cleanUpBackGroundTask` | Cleanup background task | `your.bundle.prefix.app-name.cleanUpBackGroundTask` |
| `com.example.MirrorHR-App.NotifyNoDataBackGroundTask` | Notification background task | `your.bundle.prefix.app-name.NotifyNoDataBackGroundTask` |

## Network Service Identifiers

| Placeholder Identifier | Description | Replacement Pattern |
|---------------------|-------------|---------------------|
| `_MirrorHR-App._tcp` | Bonjour TCP service | `_your-app-name._tcp` |
| `_MirrorHR-App._udp` | Bonjour UDP service | `_your-app-name._udp` |

## Provisioning Profiles

| Placeholder Profile | Description | Replacement |
|------------------|-------------|-------------|
| `iOS Development` | Development profile for iOS app | Your iOS development provisioning profile |
| `iOS Distribution` | Distribution profile for iOS app | Your iOS distribution provisioning profile |
| `watchOS Development` | Development profile for Watch app | Your watchOS development provisioning profile |
| `watchOS Distribution` | Distribution profile for Watch app | Your watchOS distribution provisioning profile |
| `Widget Development` | Development profile for widget | Your widget development provisioning profile |
| `Widget Distribution` | Distribution profile for widget | Your widget distribution provisioning profile |

## URL Schemes

| Placeholder Scheme | Description | Replacement Pattern |
|-----------------|-------------|---------------------|
| `MirrorHR` | Custom URL scheme for app deep linking | Your custom URL scheme name |

## Environment Variables

The following environment variables need to be configured in your `.env` files:

| Variable Name | Description | File Location |
|---------------|-------------|--------------|
| `OPENAI_API_KEY` | API key for OpenAI services | `Packages/OpenAIPackage/.env` |
| `AZURE_NOTIFICATION_HUB_CONNECTION_STRING` | Connection string for Azure Notification Hub | `Packages/RoberdanSecretsPackage/.env` |
| `AZURE_NOTIFICATION_HUB_NAME` | Name of your Azure Notification Hub | `Packages/RoberdanSecretsPackage/.env` |

## Files Containing Identifiers

These files contain identifiers that will be replaced by the setup script:

1. **Entitlements Files**
   - `Epilepsy Research Kit/Epilepsy Research Kit.entitlements`
   - `Epilepsy Research Kit WatchKit Extension/Epilepsy Research Kit WatchKit Extension.entitlements`
   - `MirrorHRWidget/MirrorHRWidgetExtension.entitlements`

2. **Info.plist Files**
   - `Epilepsy Research Kit/Info.plist`
   - `Epilepsy Research Kit WatchKit App/Info.plist`
   - `Epilepsy Research Kit WatchKit Extension/Info.plist`
   - `MirrorHRWidget/Info.plist`

3. **Project Files**
   - `Epilepsy Research Kit.xcodeproj/project.pbxproj`

## Manual Verification

After running the setup script, you should manually verify that all identifiers have been properly replaced in:

1. Xcode project settings
2. Build settings for each target
3. Entitlements files
4. Info.plist files
5. Any Swift files that might reference these identifiers

## Important Note

When creating a new build for App Store submission, ensure all identifiers align with your App Store Connect configuration. Mismatches can cause build upload and review issues.