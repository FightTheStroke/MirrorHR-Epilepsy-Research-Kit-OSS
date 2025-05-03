# Development Guide

## Overview

MirrorHR is a health monitoring application developed by FightTheStroke Foundation under MIT License. This guide provides comprehensive information for developers working on the MirrorHR project.

At MirrorHR, we believe it is fundamental to co-design and co-develop solutions with patients, for patients. Our development process centers the voices and needs of those living with epilepsy and their families, ensuring that the tools we build are truly meaningful and effective.

## Quick Start

### Prerequisites

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+
- watchOS 10.0+
- Apple Developer account
- Swift 5.9+

### Development Environment Setup

1. Clone the repository

   ```bash
   git clone https://github.com/FightTheStroke/MirrorHR-Epilepsy-Research-Kit-OSS.git
   cd MirrorHR-Epilepsy-Research-Kit-OSS
   ```

2. Install development tools

   ```bash
   brew install swiftlint
   ```

3. Set up environment variables

   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your development credentials

### Development Workflow

1. **Branch Management**
   - `main` - production-ready code
   - `develop` - integration branch
   - `feature/*` - new features
   - `bugfix/*` - bug fixes
   - `release/*` - release preparation

2. **Commit Guidelines**

   ```git
   type(scope): description

   [optional body]

   [optional footer]
   ```

   Types: feat, fix, docs, style, refactor, test, chore

3. **Code Review Process**
   - All changes require pull requests
   - CI checks must pass
   - At least one reviewer approval required
   - All comments must be resolved

### Testing

1. **Unit Tests**

   ```bash
   swift test --enable-code-coverage
   ```

2. **UI Tests**
   - Run through Xcode's Test Navigator
   - Required for all UI changes

3. **Performance Tests**
   - Battery impact testing
   - Memory usage monitoring
   - Network efficiency testing

### Debugging

1. **Logging**
   - Use `mainDebugger.append()` for consistent logging
   - Log levels: .event, .error, .warning, .info
   - Enable verbose logging in debug builds

2. **Common Issues**
   - HealthKit permissions
   - Watch connectivity
   - Background processing
   - Memory management

### Health Data Handling

1. **HealthKit Integration**
   - Request minimal necessary permissions
   - Handle data privacy carefully
   - Follow Apple's HealthKit guidelines

2. **Data Storage**
   - Use CoreData for persistent storage
   - Implement proper error handling
   - Regular data backup

### Performance Guidelines

1. **Watch App**
   - Minimize background processing
   - Optimize battery usage
   - Handle connectivity changes gracefully

2. **iOS App**
   - Efficient memory management
   - Optimize video processing
   - Handle large datasets efficiently

### Security Considerations

1. **Data Protection**
   - Encrypt sensitive data
   - Secure API communications
   - Follow HIPAA guidelines

2. **Authentication**
   - Implement proper session management
   - Handle timeouts appropriately
   - Secure credential storage

## Troubleshooting

### Common Build Issues

1. Code signing problems
2. Dependencies resolution
3. SwiftLint violations
4. Test failures

### Runtime Issues

1. HealthKit permission errors
2. Watch connectivity problems
3. Background processing limitations
4. Memory warnings

## Support

For development support:

- Email: <helpme@mirrorhr.org>
- Issue Tracker: GitHub Issues
- Documentation: [docs/](./docs/)

## License

Copyright © FightTheStroke Foundation

Released under MIT License
