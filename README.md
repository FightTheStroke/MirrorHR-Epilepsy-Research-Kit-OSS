# MirrorHR - Epilepsy Research Kit

![MirrorHR Logo](https://www.mirrorhr.org/img/logo.png)

## About MirrorHR

[MirrorHR](https://www.mirrorhr.org) is an open-source, community-driven health monitoring application co-designed and co-developed with patients, for patients. Created and maintained by the [FightTheStroke Foundation](https://www.fightthestroke.org), MirrorHR empowers families and caregivers managing epilepsy with real-time monitoring, symptom tracking, and actionable insights. Our mission is to improve the quality of life for people living with epilepsy and their families, leveraging technology, research, and the lived experience of our community.

> **Why MirrorHR?**
>
> Over 50 million people worldwide live with epilepsy. Families face daily challenges, from managing seizures and medication to coping with anxiety and uncertainty. MirrorHR was born from the real needs of these families, aiming to provide peace of mind, better data, and a supportive community. The project is a Microsoft Hackathon Grand Prize Winner and is available in 21 languages, free for all.

For official information, visit: [www.mirrorhr.org](https://www.mirrorhr.org)

For more about the foundation and our broader mission, visit: [www.fightthestroke.org](https://www.fightthestroke.org)

### ⚠️ Important Medical Disclaimer ⚠️

**This software is NOT a medical device and is NOT intended to diagnose, treat, cure, or prevent any disease or health condition.**

MirrorHR is designed as a supportive tool for epilepsy management and should not replace professional medical care. Always consult with healthcare providers regarding treatment decisions. The application does not provide medical advice and should not be used to make medical decisions. Use of this software is at your own risk.

For full disclaimer, see [LICENSE.md](./LICENSE.md).

### Key Features

- **Real-time Heart Rate Monitoring**: Track heart rate patterns with customizable alerts for rapid changes that may indicate seizure activity
- **Symptom Journal**: Document seizures and other symptoms with video diary support and natural language processing
- **Medication Management**: Track medication adherence and set reminders
- **Health Data Analysis**: Analyze trends across heart rate, sleep, and other health metrics
- **Caregiver Notifications**: Alert caregivers during detected events
- **Video Diary**: Record and analyze videos with speech recognition and sentiment analysis

## Our Story & Community

MirrorHR is the result of a global collaboration between families, patients, clinicians, researchers, and developers. We believe that the best solutions are co-designed with those who use them. Join our community to contribute, share feedback, or help shape the future of epilepsy care.

- Learn more and join the community: [www.mirrorhr.org](https://www.mirrorhr.org)
- About the foundation: [www.fightthestroke.org](https://www.fightthestroke.org)

## Technical Architecture

MirrorHR is built with a modular architecture leveraging Swift Packages to organize functionality:

```ascii
┌─────────────────────────────────────────────────────────────────┐
│                        MirrorHR App                             │
├─────────────┬─────────────┬─────────────────┬─────────────────┐
│ iOS App     │ Watch App   │ iOS Extension   │ Watch Extension │
└─────────────┴─────────────┴─────────────────┴─────────────────┘
               ▲                ▲                    ▲
               │                │                    │
               │                │                    │
┌──────────────┴────────────────┴────────────────────┴───────────┐
│                         MirrorHRKit                            │
├───────────────┬──────────────┬─────────────────┬──────────────┤
│ MainClasses   │ DataSources  │ SymptomsManager │ VideoLog     │
├───────────────┼──────────────┼─────────────────┼──────────────┤
│ TherapyManager│ Notifications│ BackupManager   │ Statistics   │
└───────────────┴──────────────┴─────────────────┴──────────────┘
               ▲                ▲                    ▲
               │                │                    │
               │                │                    │
┌──────────────┴────────────────┴────────────────────┴───────────┐
│                        Supporting Packages                      │
├───────────────┬──────────────┬─────────────────┬──────────────┤
│ SharedPkg     │ RoberdanTB   │ Permissions     │ Telemetry    │
├───────────────┼──────────────┼─────────────────┼──────────────┤
│ Streaming     │ TherapyPkg   │ Localization    │ StripePayment│
└───────────────┴──────────────┴─────────────────┴──────────────┘
```

### Core Components

1. **MirrorHRKit**: Main framework containing core functionality
   - **SymptomsManager**: Handles symptom tracking, logging, and analysis
   - **VideoLog**: Processes video diaries with NLP and sentiment analysis
   - **DataSourceManager**: Manages health data from multiple sources
   - **NotificationManager**: Handles alerts and notifications
   - **TherapyManager**: Tracks medications and therapy schedules
   - **BackupManager**: Manages data backup and recovery

2. **Supporting Packages**:
   - **SharedPkg**: Common models, utilities, and constants
   - **RoberdanToolBox**: Debugging, logging, and utility functions
   - **PermissionsManager**: Handles permission requests and tracking
   - **MirrorHRTelemetryPackage**: Analytics and error tracking
   - **Streaming**: Real-time data streaming functionality
   - **TherapyPackage**: Medication and therapy tracking

## Technology Stack

- **Languages**: Swift
- **Platforms**: iOS, watchOS
- **Frameworks**:
  - SwiftUI
  - Combine
  - CoreData
  - HealthKit
  - WatchConnectivity
  - SpeechRecognition
  - AVFoundation
  - SciChart (for data visualization - requires license)
- **External Services**:
  - Microsoft Azure Notification Hub (for remote notifications)
  - OpenAI API (for NLP features - requires API key)
  - TelemetryDeck (for analytics - requires app ID)
  - Stripe (for payment processing - requires account)

## Project Setup

### Requirements

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+
- watchOS 10.0+
- Apple Developer account

### Getting Started

1. Clone the repository

   ```bash
   git clone https://github.com/fightthestroke/MirrorHR.git
   cd MirrorHR
   ```

2. Run the setup script to replace development-specific identifiers with your own

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   This script will prompt you for your Apple Developer Team ID and preferred bundle identifiers.

3. Copy and configure environment variables

   ```bash
   cp Packages/OpenAIPackage/.env.example Packages/OpenAIPackage/.env
   cp Packages/RoberdanSecretsPackage/.env.example Packages/RoberdanSecretsPackage/.env
   ```

   Edit the `.env` files to add your API keys and service credentials

4. Open the project in Xcode

   ```bash
   open Epilepsy\ Research\ Kit.xcodeproj
   ```

5. Configure your signing certificates and provisioning profiles in Xcode

6. Install dependencies (handled automatically by Swift Package Manager)

7. Build and run the application

### Developer Identifiers Setup

Before building the application, you'll need to configure these identifiers:

1. **App Identifiers** - Create in Apple Developer Portal:
   - Main app: `[your-bundle-prefix].[app-name]`
   - WatchKit app: `[your-bundle-prefix].[app-name].watchkitapp`
   - Widget extension: `[your-bundle-prefix].[app-name].widget`

2. **App Group** - Create and assign to all three App IDs:
   - Format: `group.[your-bundle-prefix].[app-name]`

3. **HealthKit Capability** - Enable for both main app and WatchKit app

4. **Merchant ID** (Optional) - For Apple Pay integration:
   - Format: `merchant.[your-bundle-prefix].[app-name]`

### Configuration

MirrorHR uses environment variables for configuration of external services. Create a `.env` file in the project root with the following variables:

```env
# OpenAI API Configuration
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_API_URL=https://api.openai.com/v1/engines/gpt-3.5-turbo-instruct/completions

# Azure Cloud Settings
AZURE_CLOUD_URL=https://your-azure-instance.azurewebsites.net/
AZURE_HEADER_KEY=your-header-key-name
AZURE_HEADER_VALUE=your-header-key-value

# Stripe Settings (if using payments)
STRIPE_SECRET_KEY=sk_test_your_test_secret_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_test_publishable_key

# SciChart License
SCICHART_LICENSE_KEY=your_scichart_license_key_here

# TelemetryDeck Analytics
TELEMETRYDECK_APP_ID=your_telemetrydeck_app_id_here
```

For test/development purposes, the app will use placeholder values if these are not configured, but full functionality requires proper configuration.

### Mock Services for Development

For development without external service dependencies, use the mock implementations:

1. Azure Notification Hub: Use local notifications instead of remote
2. OpenAI: Enable "offline mode" for local text processing
3. Stripe: Use test mode with provided test keys

## Project Structure

```bash
MirrorHR/
├── Epilepsy Research Kit/           # Main iOS app
├── Epilepsy Research Kit WatchKit/  # WatchOS app and extension
├── MirrorHRKit/                     # Core functionality framework
│   ├── Sources/
│   │   ├── MainClasses/            # Core coordination classes
│   │   ├── DataSourcesManager/     # Health data sources
│   │   ├── HealthKitTools/         # HealthKit integration
│   │   ├── NotificationManager/    # Alerts and notifications
│   │   ├── RealTimeView/           # Real-time monitoring UI
│   │   ├── SymptomsManager/        # Symptom tracking
│   │   ├── TherapyManager/         # Medication management
│   │   └── VideoLog/               # Video diary processing
├── Packages/                        # Swift packages
│   ├── CheckListEngine/            # Checklist functionality
│   ├── MirrorHRTelemetryPackage/   # Analytics and telemetry
│   ├── OpenAIPackage/              # OpenAI API integration
│   ├── PermissionsManager/         # Permission handling
│   ├── RoberdanToolbox/            # Utility functions
│   ├── SharedPkg/                  # Shared models and protocols
│   ├── Streaming/                  # Real-time data streaming
│   └── TherapyPackage/             # Therapy and medication tracking
└── MirrorHRWidget/                 # Home screen widgets
```

## Performance Guidelines

When contributing to this project, keep in mind these performance considerations:

1. **Thread Safety**: Real-time monitoring requires careful thread management
   - UI updates must happen on the main thread
   - Heavy processing should be performed on background threads
   - Use thread-safe data structures for shared state

2. **Battery Efficiency**:
   - Implement efficient state transitions in watch app
   - Use appropriate update intervals for real-time monitoring
   - Optimize background refresh intervals

3. **Memory Management**:
   - Properly handle large media files (videos, audio)
   - Implement caching where appropriate
   - Be mindful of retain cycles in closure-heavy code

## Contributing & Open Issues

We welcome contributions from the community! Before starting new work, please check the [TODO.md](./TODO.md) and [ROADMAP.md](./ROADMAP.md) files for open issues, planned features, and areas where help is needed.

If you find a TODO in the code, see the [CONTRIBUTING.md](./CONTRIBUTING.md) guide for how to handle it.

## Support and Contact

For support, please contact:

- Official website: [www.mirrorhr.org](https://www.mirrorhr.org)
- Email: [helpme@mirrorhr.org](mailto:helpme@mirrorhr.org)
- Organization: [FightTheStroke Foundation](https://www.fightthestroke.org)

## License

This project is licensed under the MIT License with additional medical disclaimer - see the [LICENSE.md](./LICENSE.md) file for details.

Copyright (c) 2019-2025 FightTheStroke Foundation (<www.fightthestroke.org>)

## About Epilepsy

Epilepsy is a neurological disorder characterized by recurrent seizures. It affects about 50 million people worldwide.

Key facts:

- Seizures are brief episodes of abnormal electrical activity in the brain
- About 70% of people with epilepsy can control seizures with medication
- Early recognition and proper management improve quality of life

For families dealing with a recent epilepsy diagnosis:

1. Create a checklist for seizure response
2. Document seizures with video when possible
3. Keep a detailed symptom diary
4. Work closely with healthcare providers
5. Connect with support communities

For more information about MirrorHR, visit [www.mirrorhr.org](https://www.mirrorhr.org)

## Scientific Research & Data Collaboration

MirrorHR is committed to supporting scientific research aimed at reducing the number and severity of epileptic seizures. The project includes anonymized real-world data samples that demonstrate how MirrorHR tracks and analyzes seizure events, which can be invaluable for research initiatives.

### Research Data

The `RealData` directory contains:
- Anonymized samples of seizure tracking data
- Heart rate and symptom correlations
- Event logs showing patterns of seizure activity

This data is provided to support scientific research efforts and can help researchers develop better methods for seizure prediction, management, and treatment. Our goal is to collaborate with the scientific community to improve outcomes for people with epilepsy.

### Research Collaboration

We welcome collaboration with researchers, clinicians, and institutions working to reduce epileptic seizures. If you're interested in accessing additional data or collaborating on research projects, please contact us at [helpme@mirrorhr.org](mailto:helpme@mirrorhr.org).

### Research Usage Requirements

When using MirrorHR data for research:
1. All research or studies built using this data must be communicated to [info@fightthestroke.org](mailto:info@fightthestroke.org) prior to publication
2. Proper attribution must be given in all publications, including the citation format provided in the RealData documentation
3. Include the attribution: "Data provided by MirrorHR, developed by FightTheStroke Foundation (www.fightthestroke.org)"

Together, we can work toward more effective methods to "Reduce the Number and Severity of Epileptic Seizures" and improve quality of life for those affected by epilepsy.

## Security Considerations

MirrorHR handles sensitive health data and requires careful attention to security practices:

### Sensitive Information

- This open-source version has removed all API keys, credentials, and sensitive identifiers
- You will need to replace these with your own secure values using the provided setup script
- Never commit sensitive information to the repository
- Use the provided `.env.example` files and environment variable patterns

### Risk Mitigation

We've included several tools to ensure proper security:

1. **Setup Script**: `setup.sh` helps you replace all developer-specific identifiers
2. **Verification Checklist**: See [VERIFICATION.md](./VERIFICATION.md) for a comprehensive security verification process
3. **Security Policy**: Our [SECURITY.md](./SECURITY.md) outlines our security practices and vulnerability reporting process
4. **Enhanced Gitignore**: Prevents accidental commits of sensitive files

### Data Privacy

MirrorHR prioritizes user privacy:

- Health data stays on the user's device by default
- Data sharing is opt-in only
- Custom remote monitoring uses end-to-end encryption
- All network requests use HTTPS

For more details about security, refer to our [SECURITY.md](./SECURITY.md) document.

## Code Quality & SwiftLint

We use [SwiftLint](https://github.com/realm/SwiftLint) to help enforce code style and quality. Due to the current project structure and the inclusion of dependencies and build artifacts within the repository, SwiftLint may report violations outside of our own code. For this reason, SwiftLint failures are currently allowed in our CI workflow and do not block merges.

**Contributors should focus on fixing style issues only in first-party code.**

We plan to improve the project structure and linting configuration over time so that only our own code is checked and required to pass. If you have suggestions or want to help, please see the [CONTRIBUTING.md](./CONTRIBUTING.md) file.

## Research Publication Tracking

MirrorHR includes a system for tracking research publications that use our data. This helps us:

1. Build a community of epilepsy researchers
2. Showcase the impact of MirrorHR in scientific research
3. Connect researchers working on similar topics
4. Demonstrate the value of our open data approach

Researchers who use MirrorHR data in their studies are required to:
1. Submit their publication details via email to [info@fightthestroke.org](mailto:info@fightthestroke.org)
2. Follow our [citation guidelines](./RealData/README.md#citation-format)

For more information, see the documentation in the [ResearchTracking](./ResearchTracking/) directory.

## Contributing and Repository Requirements

### Signed Commits

This repository requires signed commits to ensure security and code integrity. To set up commit signing:

1. Configure Git to use SSH for commit signing:
   ```
   git config --global gpg.format ssh
   ```

2. Set your SSH key for signing:
   ```
   git config --global user.signingkey ~/.ssh/id_ed25519.pub
   ```

3. Configure Git to always sign commits:
   ```
   git config --global commit.gpgsign true
   ```

For more information on setting up commit signing, see [GitHub's documentation on commit signing](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification).
