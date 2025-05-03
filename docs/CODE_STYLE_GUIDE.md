# Code Style Guide

## Overview

This guide outlines the coding standards and best practices for MirrorHR development. Following these guidelines ensures code consistency, readability, and maintainability.

At MirrorHR, we believe it is fundamental to co-design and co-develop our solutions—including code style and best practices—with patients, for patients. The needs and experiences of those living with epilepsy and their families inform our approach to building accessible, maintainable, and effective technology.

## Swift Style Guide

### Naming Conventions

1. **Types and Protocols**

   ```swift
   // Correct
   class UserManager { }
   protocol DataSource { }
   struct UserProfile { }
   enum UserRole { }

   // Incorrect
   class userManager { }
   protocol data_source { }
   ```

2. **Variables and Properties**

   ```swift
   // Correct
   let userName: String
   var isEnabled: Bool
   private(set) var count: Int

   // Incorrect
   let UserName: String
   var is_enabled: Bool
   ```

3. **Functions and Methods**

   ```swift
   // Correct
   func fetchUserData() { }
   func updateProfile(with data: UserData) { }
   static func createInstance() -> Self { }

   // Incorrect
   func FetchUserData() { }
   func update_profile(with_data: UserData) { }
   ```

### Code Organization

1. **File Structure**

   ```swift
   // 1. Imports
   import Foundation
   import SwiftUI

   // 2. Type Definition
   class UserManager {
       // 3. Properties
       private let dataSource: DataSource
       
       // 4. Initializers
       init(dataSource: DataSource) {
           self.dataSource = dataSource
       }
       
       // 5. Public Methods
       func fetchUser() async throws -> User {
           // Implementation
       }
       
       // 6. Private Methods
       private func processData(_ data: Data) -> User {
           // Implementation
       }
   }
   ```

2. **Extensions**

   ```swift
   // Group related functionality
   extension UserManager {
       // User validation
       func validateUser(_ user: User) -> Bool {
           // Implementation
       }
   }
   ```

### Documentation

1. **Documentation Comments**

   ```swift
   /// Fetches user data from the server.
   ///
   /// - Parameters:
   ///   - userId: The unique identifier of the user
   ///   - completion: Callback with the result
   /// - Throws: NetworkError if the request fails
   func fetchUser(userId: String) async throws -> User {
       // Implementation
   }
   ```

2. **Mark Comments**

   ```swift
   // MARK: - Properties
   private let dataSource: DataSource

   // MARK: - Public Methods
   func fetchUser() { }

   // MARK: - Private Methods
   private func processData() { }
   ```

### Error Handling

1. **Error Types**

   ```swift
   enum NetworkError: Error {
       case invalidURL
       case requestFailed
       case decodingFailed
   }
   ```

2. **Error Handling**

   ```swift
   do {
       let user = try await fetchUser()
   } catch NetworkError.invalidURL {
       // Handle specific error
   } catch {
       // Handle other errors
   }
   ```

### Concurrency

1. **Async/Await**

   ```swift
   func fetchData() async throws -> Data {
       let url = try await getURL()
       let (data, _) = try await URLSession.shared.data(from: url)
       return data
   }
   ```

2. **Actor Usage**

   ```swift
   actor DataManager {
       private var cache: [String: Data] = [:]
       
       func getData(for key: String) -> Data? {
           return cache[key]
       }
   }
   ```

### Testing

1. **Test Naming**

   ```swift
   func testFetchUser_WhenValidID_ReturnsUser() async throws {
       // Test implementation
   }

   func testFetchUser_WhenInvalidID_ThrowsError() async throws {
       // Test implementation
   }
   ```

2. **Test Organization**

   ```swift
   class UserManagerTests: XCTestCase {
       // MARK: - Properties
       private var sut: UserManager!
       
       // MARK: - Setup
       override func setUp() {
           super.setUp()
           sut = UserManager()
       }
       
       // MARK: - Tests
       func testFetchUser() async throws {
           // Test implementation
       }
   }
   ```

## SwiftLint Configuration

### Rules

```yaml
disabled_rules:
  - colon
  - comma
  - control_statement
  - trailing_whitespace
  - identifier_name
  - vertical_parameter_alignment
  - function_body_length

opt_in_rules:
  - empty_count
  - explicit_self
  - force_unwrapping
  - missing_docs
  - redundant_string_enum_value
  - sorted_imports
  - vertical_whitespace

line_length:
  warning: 120
  error: 200

type_body_length:
  warning: 300
  error: 400

file_length:
  warning: 500
  error: 1000

function_body_length:
  warning: 40
  error: 100

cyclomatic_complexity:
  warning: 10
  error: 20
```

## Support

For code style questions:

- Email: <helpme@mirrorhr.org>
- Documentation: [docs/](./docs/)
- Code Review: Follow PR template guidelines

## License

Copyright © FightTheStroke Foundation

Released under MIT License
