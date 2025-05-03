# MirrorHR Setup Guide

This guide walks you through setting up the MirrorHR project for development and contribution. Follow these steps carefully to ensure a proper environment configuration.

## Prerequisites

- Xcode 14.0 or higher
- macOS 12.0 or higher
- An Apple Developer account
- CocoaPods (for certain dependencies)
- Git

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/MirrorHR.git
cd MirrorHR
```

### 2. Run the Setup Script

The setup script will replace all developer-specific identifiers with your own:

```bash
chmod +x setup.sh
./setup.sh
```

The script will prompt you for:
- Your Apple Developer Team ID
- Your Bundle ID prefix (typically your domain in reverse, e.g., com.example)
- Your app name

### 3. Install Dependencies

```bash
# Pull all Swift Package Manager dependencies
xed .
# (In Xcode: File > Packages > Resolve Package Versions)
```

### 4. Configure Environment Variables

Copy the example environment files and configure with your own values:

```bash
cp Packages/OpenAIPackage/.env.example Packages/OpenAIPackage/.env
cp Packages/RoberdanSecretsPackage/.env.example Packages/RoberdanSecretsPackage/.env
```

Edit these files to add your own API keys and configuration values.

## Required Configuration

### Apple Developer Account Setup

1. **Developer Team ID**
   - Log in to your [Apple Developer Account](https://developer.apple.com/account)
   - Your Team ID is displayed at the top right of the Membership page

2. **App Identifiers**
   - Create three App IDs in the Apple Developer Portal:
     - Main app: `[your-bundle-prefix].[app-name]`
     - WatchKit app: `[your-bundle-prefix].[app-name].watchkitapp`
     - Widget extension: `[your-bundle-prefix].[app-name].widget`

3. **App Group**
   - Create an App Group with the identifier: `group.[your-bundle-prefix].[app-name]`
   - Assign this App Group to all three App IDs

4. **HealthKit Capabilities**
   - Enable HealthKit for both the main app and WatchKit app IDs

5. **Apple Pay Merchant ID (Optional)**
   - If you intend to use Apple Pay, create a Merchant ID: `merchant.[your-bundle-prefix].[app-name]`

### Provisioning Profiles

You'll need to create several provisioning profiles:

1. **Development Profiles**
   - Main iOS app development profile
   - WatchKit app development profile
   - Widget extension development profile

2. **Distribution Profiles** (for TestFlight/App Store)
   - Main iOS app distribution profile
   - WatchKit app distribution profile
   - Widget extension distribution profile

Xcode can automatically manage provisioning profiles, but for manual management, download these from the Apple Developer Portal and install them.

## External Service Configuration

### OpenAI API (for NLP features)

1. Create an account at [OpenAI Platform](https://platform.openai.com/)
2. Generate an API key
3. Add the key to your `.env` file:
   ```
   OPENAI_API_KEY=your_key_here
   ```

### TelemetryDeck (for analytics)

1. Create an account at [TelemetryDeck](https://telemetrydeck.com/)
2. Create a new app in the TelemetryDeck dashboard
3. Copy the App ID and add it to your `.env` file:
   ```
   TELEMETRYDECK_APP_ID=your_telemetrydeck_app_id_here
   ```

### Azure Notification Hub (for remote monitoring)

1. Create an Azure account if you don't have one
2. Set up an Azure Notification Hub
3. Add the connection string to your `.env` file:
   ```
   AZURE_NOTIFICATION_HUB_CONNECTION_STRING=your_connection_string_here
   AZURE_NOTIFICATION_HUB_NAME=your_hub_name_here
   ```

## Verification

After completing setup, verify your configuration by:

1. Opening the project in Xcode
2. Checking the signing configuration for each target
3. Building the project to verify there are no configuration errors
4. Running unit tests to ensure functionality works as expected

## Troubleshooting

### Common Issues

1. **Code Signing Errors**
   - Verify your Team ID is correctly set in the project
   - Check that all provisioning profiles are correctly installed
   - Try using Xcode's automatic signing option temporarily

2. **Missing API Keys**
   - Verify all environment variables are set correctly
   - Check that `.env` files are in the correct locations
   - Ensure API keys have the correct permissions

3. **Package Resolution Failures**
   - Delete the derived data folder: `rm -rf ~/Library/Developer/Xcode/DerivedData`
   - Re-resolve packages in Xcode

### Getting Help

If you encounter issues not covered here:
- Check the GitHub issues to see if your problem has been reported
- Join our community discussions
- Create a new issue with detailed information about your problem

## Next Steps

Now that you have set up the MirrorHR project, check out the [CONTRIBUTING.md](CONTRIBUTING.md) guide to learn how to contribute to the project effectively.