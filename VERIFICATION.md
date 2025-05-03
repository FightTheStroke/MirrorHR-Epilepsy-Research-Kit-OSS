# MirrorHR Open Source Release Verification Checklist

This document provides a comprehensive verification checklist to ensure that MirrorHR is properly prepared for open source release, with all sensitive information removed and proper documentation in place.

## Security Verification

### API Keys and Credentials

- [ ] OpenAI API keys replaced with placeholders
- [ ] Azure Notification Hub connection strings replaced with placeholders
- [ ] Stripe API keys replaced with placeholders
- [ ] SciChart license keys replaced with placeholders
- [ ] All other service-specific API keys or tokens removed

### Developer-Specific Identifiers

- [ ] Development Team ID (`93T3LG4NPG`) replaced with placeholder
- [ ] Bundle IDs properly generalized
- [ ] App group identifiers generalized
- [ ] Merchant IDs generalized
- [ ] Bonjour service names generalized
- [ ] Background task identifiers generalized

### Certificates and Provisioning

- [ ] All provisioning profile specifiers removed from project file
- [ ] No certificates included in the repository
- [ ] No private keys included in the repository
- [ ] No .p12 files included in the repository

### Environment Configuration

- [ ] `.env.example` files properly document all required variables
- [ ] No actual `.env` files included in the repository
- [ ] Environment loading utility functions properly implemented
- [ ] Clear documentation on how to set up environment variables

## Documentation Verification

- [ ] README.md includes clear project description and setup instructions
- [ ] SETUP.md provides detailed setup guide
- [ ] IDENTIFIERS.md lists all identifiers that need to be replaced
- [ ] SECURITY.md includes security policy and vulnerability reporting process
- [ ] CODE_OF_CONDUCT.md establishes community guidelines
- [ ] CONTRIBUTING.md explains how to contribute to the project
- [ ] LICENSE.md includes proper licensing with medical disclaimer
- [ ] ARCHITECTURE.md documents technical architecture
- [ ] LOCALIZATION.md explains the localization system

## Code Structure Verification

- [ ] No unused or experimental code remains
- [ ] No commented-out code containing sensitive information
- [ ] No hardcoded URLs to internal or private services
- [ ] No hardcoded IP addresses or internal network identifiers
- [ ] No test accounts or credentials in test code

## Repository Configuration

- [ ] `.gitignore` properly configured to avoid committing sensitive files
- [ ] Issue templates set up for GitHub
- [ ] GitHub Actions workflows set up for CI/CD (if applicable)
- [ ] Pull request templates configured (if applicable)

## Sample Data

- [ ] Sample data provided for testing
- [ ] All sample data is synthetic (no real user data)
- [ ] Sample data properly documented

## Final Pre-Release Steps

- [ ] Run the `setup.sh` script to verify all replacements work
- [ ] Build the project with placeholder values to verify compilation
- [ ] Run all unit tests to verify functionality
- [ ] Verify all documentation for accuracy and completeness
- [ ] Create a fresh clone of the repository to verify no history with sensitive data is included

## Post-Release Verification

- [ ] Verify public repository does not contain any sensitive information
- [ ] Test setup process from scratch with a new developer account
- [ ] Monitor for any security issues reported by the community
- [ ] Update documentation based on community feedback

## Repository Creation Strategy

For the final public repository, use one of these approaches:

### Option 1: Clean Repository
1. Create a new empty repository
2. Add all sanitized files
3. Make an initial commit
4. Push to GitHub

### Option 2: Filter Repository History
1. Use `git filter-repo` to remove sensitive files from history
2. Review the filtered repository for any remaining sensitive data
3. Push the filtered repository to GitHub

## Final Checklist Before Public Release

- [ ] All verification items above completed
- [ ] Final review by a team member who was not involved in the sanitization process
- [ ] Explicit approval from project stakeholders
- [ ] Clear communication plan for the open source release

---

**Note:** Check items off this list as you complete them to track progress. This document should be completed and reviewed before the final public release of the MirrorHR project.

# Pre-Release Verification Checklist

Before releasing the MirrorHR project as open source, ensure all identifiers have been properly replaced with placeholders. This document serves as a checklist to verify all personal or organization-specific identifiers have been removed.

## Identifiers to Replace

The following identifiers should be replaced throughout the codebase:

- [ ] Development Team ID (`93T3LG4NPG`) replaced with `YOURTEAMID`
- [ ] App Bundle Identifier (`com.mirror-labs.Epilepsy-Research-Kit`) replaced with `com.example.MirrorHR-App`
- [ ] WatchKit App Bundle Identifier (`com.mirror-labs.Epilepsy-Research-Kit.watchkitapp`) replaced with `com.example.MirrorHR-App.watchkitapp`
- [ ] Widget Extension Bundle Identifier (`com.mirror-labs.Epilepsy-Research-Kit.widget`) replaced with `com.example.MirrorHR-App.widget`
- [ ] App Group Identifier (`group.mirror-labs.Epilepsy-Research-Kit`) replaced with `group.example.MirrorHR-App`
- [ ] Merchant Identifier (`merchant.com.mirror-labs.Epilepsy-Research-Kit`) replaced with `merchant.example.MirrorHR-App`
- [ ] Bonjour Service Names (`_mirrorHR._tcp` and `_mirrorHR._udp`) replaced with `_MirrorHR-App._tcp` and `_MirrorHR-App._udp`

## Provisioning Profile Names

The following provisioning profile names should be replaced with generic placeholders:

- [ ] `2021 DEV IOS` replaced with `iOS Development`
- [ ] `2021 Research Kit DISTRIBUTION` replaced with `iOS Distribution`
- [ ] `2021 DEV WATCH` replaced with `watchOS Development`
- [ ] `2021 RESEARCH KIT DISTRI WATCH` replaced with `watchOS Distribution`
- [ ] `MirrorHR Widget DEV 2023` replaced with `Widget Development`
- [ ] `MirrorHR Widget Distribution 2023` replaced with `Widget Distribution`

## Key Files to Check

The following files need to be checked for personal identifiers:

1. **Project File**
   - [ ] `Epilepsy Research Kit.xcodeproj/project.pbxproj`

2. **Info.plist Files**
   - [ ] `Epilepsy Research Kit/Info.plist`
   - [ ] `Epilepsy Research Kit WatchKit App/Info.plist`
   - [ ] `Epilepsy Research Kit WatchKit Extension/Info.plist`
   - [ ] `MirrorHRWidget/Info.plist`

3. **Entitlements Files**
   - [ ] `Epilepsy Research Kit/Epilepsy Research Kit.entitlements`
   - [ ] `Epilepsy Research Kit WatchKit Extension/Epilepsy Research Kit WatchKit Extension.entitlements`
   - [ ] `MirrorHRWidget/MirrorHRWidgetExtension.entitlements`

4. **Swift Files with Bundle IDs**
   - [ ] `Packages/PermissionsManager/Sources/PermissionsManager/Types/Health.swift`
   - [ ] `MirrorHRKit/Sources/MirrorHRKit/Helpers/AppDelegate.swift`
   - [ ] `MirrorHRKit/Sources/MirrorHRKit/MainClasses/CommunicationManager.swift`

## Open Source Release Process

To prepare the codebase for open source release:

1. Run the setup.sh script with placeholder values:
   ```
   ./setup.sh
   ```
   When prompted, enter:
   - Team ID: `YOURTEAMID`
   - Bundle ID prefix: `com.example`
   - App name: `MirrorHR-App`

2. Manually verify all the items in this checklist.

3. Ensure the IDENTIFIERS.md file contains placeholder values rather than real identifiers.

4. Make a final pass through the codebase to ensure no personal or sensitive information remains.

After completing these steps, the repository should be ready for open source release.