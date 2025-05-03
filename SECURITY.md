# Security Policy

## Supported Versions

We currently provide security updates for the following versions of MirrorHR:

| Version | Supported          |
| ------- | ------------------ |
| 2.x.x   | :white_check_mark: |
| 1.x.x   | :x:                |

## Reporting a Vulnerability

The FightTheStroke Foundation takes the security of MirrorHR seriously. We appreciate your efforts to responsibly disclose your findings.

### How to Report a Vulnerability

1. **DO NOT** create public GitHub issues for security vulnerabilities
2. Email your findings to [info@fightthestroke.org](mailto:info@fightthestroke.org)
3. Include as much information as possible:
   - A detailed description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact
   - Any possible mitigations
   - Your contact information (for follow-up questions)

### What to Expect

When you report a vulnerability, you can expect:

1. **Acknowledgment**: We will acknowledge receipt of your report within 48 hours
2. **Communication**: We will communicate with you to better understand the issue
3. **Investigation**: We will investigate the issue and determine its impact
4. **Fix Timeline**: We will share our expected timeline for addressing the issue
5. **Resolution**: Once resolved, we will notify you and acknowledge your contribution (if desired)

### Disclosure Policy

- We follow a coordinated disclosure process
- We request you do not disclose the vulnerability publicly until we have had a chance to address it
- We will work with you to determine an appropriate disclosure timeline

### Recognition

We believe in acknowledging security researchers who help keep MirrorHR safe. With your permission, we will add your name to our security acknowledgments page.

## Security Best Practices for MirrorHR

### For Users

1. **Keep the app updated**: Always use the latest version of MirrorHR
2. **Secure your device**: Use strong passwords and keep your iOS device updated
3. **Protect your data**: Regularly back up your data using the app's built-in backup functionality
4. **Be cautious with sharing**: Only share monitoring access with trusted caregivers

### For Developers

1. **Environment variables**: Never commit API keys or secrets directly in code
2. **Data handling**: Follow GDPR and health data privacy best practices
3. **Dependencies**: Keep all dependencies updated to their latest secure versions
4. **Code review**: All security-related changes require thorough code review

## Security Features

MirrorHR includes several security features to protect your health data:

1. **Local storage**: Health data is primarily stored locally on your device
2. **End-to-end encryption**: When data is transmitted, it's protected with end-to-end encryption
3. **Authentication**: Access to remote monitoring requires authentication
4. **Minimal data collection**: We collect only the data necessary for the app's functionality
5. **Data control**: You have full control over what data is collected and shared

## Security-Related Configuration

The application uses several environment variables for secure configuration. See `.env.example` for details on secure setup.

## Security Compliance

MirrorHR is designed with consideration for:

- GDPR compliance
- HIPAA guidelines (although not officially HIPAA certified)
- Apple's iOS privacy guidelines

## Third-Party Security Dependencies

The security of MirrorHR depends in part on third-party services. We carefully select providers with strong security practices:

- Apple HealthKit for health data storage
- Azure Notification Hub for secure notifications
- OpenAI API with appropriate data handling

---

Your security is important to us. If you have questions or concerns about MirrorHR's security, please contact [info@fightthestroke.org](mailto:info@fightthestroke.org).