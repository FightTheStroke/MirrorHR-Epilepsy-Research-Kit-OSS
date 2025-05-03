# StateMachineKit

A lightweight, type-safe state machine implementation for Swift applications.

## Overview

StateMachineKit provides a robust framework for implementing finite state machines (FSM) in Swift. It enables clear modeling of complex application states and transitions, making it easier to manage workflow logic, especially for medical applications requiring precise state tracking.

## Key Features

- **Type-Safe State Transitions**: Compile-time verification of valid state transitions
- **Event-Driven Architecture**: React to events with predefined state transitions
- **Guards and Conditions**: Control transitions with conditional logic
- **Side Effects**: Execute actions when entering, exiting, or transitioning between states
- **Debugging Support**: Built-in logging and visualization of state machine flow
- **Thread Safety**: Proper synchronization for state changes
- **SwiftUI Integration**: Reactive properties for UI updates

## Architecture

The package is organized around core components:

```
StateMachineKit/
├── StateMachine.swift         # Main state machine implementation
├── StateDefinition.swift      # State type definitions
├── Transition.swift           # Transition rules and logic
├── Event.swift                # Event handling system
├── Guard.swift                # Conditional logic for transitions
└── Visualization/             # State machine visualization utilities
```

## Usage

### Basic Example

```swift
import StateMachineKit

// Define states for a medication reminder system
enum MedicationState: StateType {
    case idle
    case scheduled
    case reminded
    case taken
    case missed
    case completed
}

// Define events that can trigger state transitions
enum MedicationEvent: EventType {
    case schedule
    case remind
    case take
    case skip
    case reset
}

// Create a state machine
let medicationStateMachine = StateMachine<MedicationState, MedicationEvent>(initialState: .idle)

// Configure transitions
medicationStateMachine.addTransition(from: .idle, to: .scheduled, on: .schedule)
medicationStateMachine.addTransition(from: .scheduled, to: .reminded, on: .remind)
medicationStateMachine.addTransition(from: .reminded, to: .taken, on: .take)
medicationStateMachine.addTransition(from: .reminded, to: .missed, on: .skip)
medicationStateMachine.addTransition(from: [.taken, .missed], to: .completed, on: .reset)
medicationStateMachine.addTransition(from: .completed, to: .idle, on: .reset)

// Add side effects
medicationStateMachine.onEnter(.scheduled) {
    scheduleLocalNotification()
}

medicationStateMachine.onExit(.reminded) { previousState, event in
    cancelReminderNotification()
}

// Add guards
medicationStateMachine.addTransition(
    from: .reminded, 
    to: .taken, 
    on: .take,
    guard: { currentState, event in
        return Date() < reminderExpiration
    }
)

// Use the state machine
medicationStateMachine.send(.schedule)  // -> .scheduled
medicationStateMachine.send(.remind)    // -> .reminded
medicationStateMachine.send(.take)      // -> .taken
medicationStateMachine.send(.reset)     // -> .completed
```

### SwiftUI Integration

```swift
struct MedicationView: View {
    @ObservedObject var stateMachine = MedicationStateMachine.shared
    
    var body: some View {
        VStack {
            Text("Current state: \(stateMachine.state.description)")
            
            switch stateMachine.state {
            case .idle:
                Button("Schedule Medication") {
                    stateMachine.send(.schedule)
                }
            case .reminded:
                HStack {
                    Button("Take Medication") {
                        stateMachine.send(.take)
                    }
                    Button("Skip Dose") {
                        stateMachine.send(.skip)
                    }
                }
            case .taken, .missed:
                Text("Medication \(stateMachine.state == .taken ? "taken" : "missed")")
                Button("Complete") {
                    stateMachine.send(.reset)
                }
            default:
                EmptyView()
            }
        }
    }
}
```

## Advanced Features

### Hierarchical State Machines

```swift
// Creating nested state machines
let mainStateMachine = StateMachine<AppState, AppEvent>()
let medicationSubMachine = StateMachine<MedicationState, MedicationEvent>()

mainStateMachine.addSubMachine(
    medicationSubMachine,
    mappedToState: .medicationTracking,
    entryEvent: .initializeMedication,
    exitEvent: .completeMedication
)
```

### Visualization

```swift
// Generate a visual representation of the state machine
let dotGraph = medicationStateMachine.generateDotGraph()
print(dotGraph)  // Can be rendered as a graph using GraphViz
```

## Performance Considerations

StateMachineKit is designed for efficiency:

- **Minimal Overhead**: State transitions have negligible performance impact
- **Memory Efficiency**: State machine instances have small memory footprint
- **Optimized Event Dispatching**: O(1) event handling lookups
- **Thread Safety**: Lock-free implementation where possible

## Thread Safety

The state machine ensures thread safety through:

- **Atomic State Updates**: Thread-safe state transitions
- **Serial Event Processing**: Events processed in the order they are received
- **Deadlock Avoidance**: Careful lock management

## Requirements

- iOS 15.0+
- Swift 5.5+

## Integration

Add StateMachineKit to your Swift package:

```swift
dependencies: [
    .package(url: "path/to/StateMachineKit", .branch("main"))
]

targets: [
    .target(
        name: "YourTarget",
        dependencies: ["StateMachineKit"]
    )
]
```