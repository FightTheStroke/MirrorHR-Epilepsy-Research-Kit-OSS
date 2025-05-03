# Contributing to MirrorHR

Thank you for your interest in contributing to MirrorHR! This document provides guidelines and instructions for contributing to our project.

## Table of Contents

- [Contributing to MirrorHR](#contributing-to-mirrorhr)
  - [Table of Contents](#table-of-contents)
  - [Code of Conduct](#code-of-conduct)
  - [Getting Started](#getting-started)
  - [Development Process](#development-process)
  - [Pull Request Process](#pull-request-process)
  - [Code Style](#code-style)
  - [Testing](#testing)
  - [Documentation](#documentation)
  - [Questions and Support](#questions-and-support)
  - [License](#license)
  - [Handling TODOs](#handling-todos)
  - [SwiftLint \& Code Style](#swiftlint--code-style)
  - [Signed Commits Requirement](#signed-commits-requirement)
    - [Setting Up Commit Signing](#setting-up-commit-signing)
    - [Verifying Your Setup](#verifying-your-setup)

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

## Getting Started

1. Fork the repository
2. Clone your fork:

   ```bash
   git clone https://github.com/your-username/MirrorHR.git
   cd MirrorHR
   ```

3. Set up the development environment:
   - Install Xcode 15.0+
   - Install Swift 5.9+
   - Install dependencies:

     ```bash
     swift package resolve
     ```

## Development Process

1. Create a new branch for your feature/fix:

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes
3. Test your changes
4. Commit your changes:

   ```bash
   git commit -m "Description of your changes"
   ```

5. Push to your fork:

   ```bash
   git push origin feature/your-feature-name
   ```

6. Create a Pull Request

## Pull Request Process

1. Ensure your PR description clearly describes the problem and solution
2. Update the documentation if necessary
3. The PR must pass all CI checks
4. At least one review is required before merging
5. Once approved, the PR will be merged by a maintainer

## Code Style

Please follow our [Code Style Guide](docs/CODE_STYLE_GUIDE.md) when making changes. Key points:

- Use SwiftLint for code style enforcement
- Follow Swift API Design Guidelines
- Write clear, descriptive commit messages
- Include comments for complex logic

## Testing

1. Write unit tests for new features
2. Ensure all tests pass:

   ```bash
   swift test
   ```

3. Run UI tests if applicable
4. Test on both iOS and watchOS

## Documentation

1. Update relevant documentation
2. Add comments for public APIs
3. Update README if necessary
4. Follow our [Documentation Guidelines](docs/DEVELOPMENT_GUIDE.md#documentation)

## Questions and Support

For questions and support:

- Email: <helpme@mirrorhr.org>
- GitHub Issues: [Create an issue](https://github.com/FightTheStroke/MirrorHR-Epilepsy-Research-Kit-OSS/issues)
- Documentation: [docs/](./docs/)

## License

By contributing, you agree that your contributions will be licensed under the project's [MIT License](LICENSE.md).

## Handling TODOs

- All TODOs in the codebase should be in English, actionable, and reference the `ROADMAP.md` or `TODO.md` for more details.
- If you find a TODO that is critical or user-facing, consider moving it to an open issue or documenting it in `TODO.md` or `ROADMAP.md`.
- Avoid leaving vague or outdated TODOs in the code. If a TODO is no longer relevant, remove it.
- For more information on open issues and future plans, see the [ROADMAP.md](./ROADMAP.md) and [TODO.md](./TODO.md) files.

## SwiftLint & Code Style

We use [SwiftLint](https://github.com/realm/SwiftLint) to help enforce code style and quality. Due to the current project structure and the inclusion of dependencies and build artifacts within the repository, SwiftLint may report violations outside of our own code. For this reason, SwiftLint failures are currently allowed in our CI workflow and do not block merges.

**Please focus on fixing style issues only in first-party code.**

We plan to improve the project structure and linting configuration over time so that only our own code is checked and required to pass. If you have suggestions or want to help, please open an issue or a pull request.

## Signed Commits Requirement

This repository requires all commits to be signed. This helps maintain security and integrity of the codebase.

### Setting Up Commit Signing

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

Alternatively, if you prefer GPG signing, please follow [GitHub's documentation on GPG commit signing](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key).

### Verifying Your Setup

To verify that your commits will be properly signed, make a test commit and check that it shows as "Verified" on GitHub.

If you're having issues with commit signing, please check GitHub's troubleshooting guides or reach out to us at [info@fightthestroke.org](mailto:info@fightthestroke.org).
