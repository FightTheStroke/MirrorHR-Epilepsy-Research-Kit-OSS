# MirrorHR Localization Guide

MirrorHR is designed to be fully localizable to serve epilepsy patients and caregivers worldwide. This document provides guidelines for contributing to the localization efforts.

## Supported Languages

Currently, MirrorHR supports the following languages:

- English (en) - Base language
- Italian (it)
- Spanish (es)
- French (fr)
- German (de)
- Portuguese (pt-BR, pt-PT)
- Russian (ru)
- Japanese (ja)
- Chinese (Simplified) (zh-Hans)
- Arabic (ar, ar-EG)
- Dutch (nl)
- Finnish (fi)
- Greek (el)
- Hebrew (he)
- Hindi (hi)
- Indonesian (id)
- Korean (ko)
- Malay (ms)
- Thai (th)
- Turkish (tr)
- Ukrainian (uk)
- Vietnamese (vi)

## Localization Structure

Localizable content is organized in several locations:

1. **Base Strings**: `/Localizable/en.lproj/Localizable.strings`
2. **Interface Elements**: `/Epilepsy Research Kit/Base.lproj/LaunchScreen.storyboard` (for each language)
3. **Watch Interface**: `/Epilepsy Research Kit WatchKit App/Base.lproj/Interface.storyboard` (for each language)

## Contributing Translations

### Prerequisites

- Familiarity with the target language, preferably native fluency
- Understanding of epilepsy and medical terminology in the target language
- Basic knowledge of iOS app localization

### Process for Adding or Updating Translations

1. **Fork the Repository**: Create your own fork of MirrorHR

2. **Locate the Files to Translate**:
   - For new languages, copy the structure from `en.lproj`
   - For existing languages, find the appropriate `.lproj` directory

3. **Translate the Strings**:
   - Maintain the same keys as the English version
   - Ensure proper encoding (UTF-8)
   - Respect placeholders (e.g., `%@`, `%d`, `%1$@`) and maintain their order

4. **Test Your Translations**:
   - Run the app with your target language
   - Check all screens and dialogs
   - Verify that placeholders are correctly substituted

5. **Submit a Pull Request**:
   - Include only the changed localization files
   - Provide a description of the changes
   - Mention which language was updated

### Translation Tips

1. **Medical Terminology**: Use accurate medical terms for epilepsy symptoms and treatments

2. **UI Space Constraints**: Be aware that some languages require more space than English. Keep translations concise when possible.

3. **Accessibility**: Consider how your translations will be read by screen readers

4. **Cultural Sensitivity**: Be mindful of cultural differences when translating content about medical conditions

## Using the Localization System in Code

For developers adding new features to MirrorHR, use the following patterns for localizable content:

### Swift Code

```swift
// For simple string localization
let message = "symptom_added_success".local()

// For formatted strings with parameters
let countdown = String(format: "monitoring_countdown".local(), minutes, seconds)

// For quantity-aware strings
let itemCount = String.localizedStringWithFormat("items_count".local(), count)
```

### SwiftUI Views

```swift
Text("welcome_message".local())

Button(action: saveAction) {
    Text("save_button".local())
}

// With string interpolation (not recommended, use String(format:) instead)
Text("Hello, \("user_greeting".local())")
```

## Localization Testing

### Manual Testing

1. Change your device language settings
2. Launch the app
3. Navigate through all screens
4. Test all features that display text

### Automated Testing

1. Use the `LocalizationTests.swift` to verify that all keys have translations
2. Run the tests before submitting changes

## Special Considerations

### Right-to-Left Languages

For Arabic and Hebrew:

- Use the `.environment(\.layoutDirection, .rightToLeft)` modifier when testing
- Ensure UI elements adjust properly for RTL layout
- Pay special attention to number formatting and date representations

### Pluralization

Use proper pluralization rules for the target language:

```swift
// Define in Localizable.stringsdict
let itemText = String.localizedStringWithFormat(
    NSLocalizedString("items_count", comment: "Number of items"),
    itemCount
)
```

### Date and Time Formatting

Use locale-aware date and time formatters:

```swift
let dateFormatter = DateFormatter()
dateFormatter.dateStyle = .medium
dateFormatter.timeStyle = .short
dateFormatter.locale = Locale.current
let localizedDate = dateFormatter.string(from: date)
```

## Adding a New Language

1. Create a new directory in `/Localizable/` named `[language-code].lproj`
2. Copy `Localizable.strings` from `en.lproj` to your new directory
3. Translate all strings in the file
4. Add the language to supported languages in the app's Info.plist
5. Create corresponding directories in other localization locations
6. Test thoroughly before submitting

## Common Issues and Solutions

### Missing Translations

If a translation is missing, the app will fall back to the base language (English).

### Encoding Problems

Ensure all files are saved with UTF-8 encoding to prevent character display issues.

### Placeholder Mismatches

Ensure that the placeholders in translations match those in the base language.

## Resources

- [Apple's Localization Guide](https://developer.apple.com/localization/)
- [Internationalization and Localization Guide](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/Introduction/Introduction.html)
- [Epilepsy Terminology Glossary](https://www.epilepsy.com/what-is-epilepsy/glossary)

## Contact

For questions about localization, contact [info@fightthestroke.org](mailto:info@fightthestroke.org) with the subject "MirrorHR Localization".