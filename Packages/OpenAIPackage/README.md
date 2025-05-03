# OpenAIPackage

A lightweight Swift wrapper for interacting with OpenAI's language models API.

## Overview

OpenAIPackage provides a simple interface to interact with OpenAI's GPT models through a straightforward API client. The package handles authentication, request formatting, and response parsing to make AI text generation easy to implement in your Swift projects.

## Features

- Simple API for text completion with GPT-3.5-turbo
- Asynchronous API support using Swift concurrency
- Configurable parameters (temperature, max tokens)
- Comprehensive error handling
- Minimal dependencies

## Installation

### Swift Package Manager

Add OpenAIPackage to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "path/to/OpenAIPackage", branch: "main")
]
```

## Usage

### Basic Prompt Completion

```swift
import OpenAIPackage

// Use the shared instance
let openAI = OpenAIConnector.shared

do {
    // Process a prompt and get the completion
    let completion = try await openAI.processPrompt(prompt: "Write a short poem about Swift programming")
    if let completion = completion {
        print(completion)
    }
} catch {
    print("Error: \(error)")
}
```

## Configuration

The package has default settings that work well for most use cases:

- **Model**: GPT-3.5-turbo-instruct
- **Max Tokens**: 1000
- **Temperature**: 0.2 (lower values make output more deterministic)

## Security

⚠️ **Important**: This package currently contains a hardcoded API key. In production, you should use environment variables or a secure credential storage mechanism.

For secure API key management, consider using the RoberdanSecretsPackage with environment variables.

## Error Handling

The package provides comprehensive error handling. All API calls are wrapped in `try/catch` blocks:

```swift
do {
    let result = try await OpenAIConnector.shared.processPrompt(prompt: "Your prompt here")
    // Handle successful result
} catch let error as OpenAIError {
    switch error {
    case .invalidURL:
        // Handle invalid URL
    case .requestFailed(let error):
        // Handle request failure
    case .invalidResponse:
        // Handle invalid response
    case .decodingFailed(let error):
        // Handle JSON decoding failure
    }
} catch {
    // Handle other errors
}
```

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.5+

## License

This package is part of the MirrorHR project and follows the same license terms.

## Acknowledgements

This package is built for the MirrorHR application to assist with natural language processing tasks. 