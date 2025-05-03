// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/// A generic finite state machine (FSM) that manages state transitions based on events.
///
/// This class allows you to define states and events, set up transitions between states,
/// and handle events to move between states. It also supports callbacks that can be
/// executed when entering a new state.
public class StateMachine<State: Hashable, Event: Hashable>: ObservableObject {
    
    /// A typealias representing a transition from one state to another based on an event.
    public typealias Transition = (from: State, event: Event, to: State)
    
    /// A typealias for a callback function that gets executed when entering a state.
    public typealias Callback = (State) -> Void
    
    /// A dictionary mapping each state to its possible events and resulting states.
    private var transitions: [State: [Event: State]] = [:]
    
    /// A dictionary mapping each state to its associated callback.
    private var callbacks: [State: Callback] = [:]
    
    /// The current state of the state machine.
    @Published public private(set) var currentState: State
    
    /// Initializes the state machine with an initial state.
    ///
    /// - Parameter initialState: The starting state of the state machine.
    public init(initialState: State) {
        self.currentState = initialState
    }
    
    /// Adds a transition from one state to another based on an event.
    ///
    /// - Parameters:
    ///   - from: The current state.
    ///   - event: The event that triggers the transition.
    ///   - to: The state to transition to.
    public func addTransition(from: State, event: Event, to: State) {
        if transitions[from] == nil {
            transitions[from] = [:]
        }
        transitions[from]?[event] = to
    }
    
    /// Adds a callback to be executed when entering a specific state.
    ///
    /// - Parameters:
    ///   - state: The state for which the callback should be executed.
    ///   - callback: The callback function.
    public func addCallback(for state: State, callback: @escaping Callback) {
        callbacks[state] = callback
    }
    
    /// Handles an event, triggering a state transition if applicable.
    ///
    /// - Parameter event: The event to handle.
    public func handle(event: Event) {
        guard let nextState = transitions[currentState]?[event] else {
            print("Invalid transition from state \(currentState) with event \(event)")
            return
        }
        currentState = nextState
        callbacks[currentState]?(currentState)
    }
}
