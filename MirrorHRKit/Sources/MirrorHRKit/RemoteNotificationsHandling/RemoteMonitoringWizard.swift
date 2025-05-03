//
//  RemoteMonitoringWizard.swift
//  MirrorHRKit
//
//  Created by Roberto D'Angelo on 11/7/24.
//

import SwiftUI
import StateMachineKit
import RoberdanToolBox
import SharedPkg

/// Manages the remote monitoring setup wizard
/// - Handles wizard step navigation
/// - Manages user preferences
/// - Provides setup validation
/// - Implements ObservableObject for UI state management
class WizardViewModel: ObservableObject {
    /// The state machine managing the wizard's states and transitions.
    @Published var stateMachine: StateMachine<WizardState, WizardEvent>
    
    /// Initializes the ViewModel and sets up the state machine.
    init() {
        stateMachine = StateMachine(initialState: .start)
        setupTransitions()
    }
    
    /// Sets up the transitions and callbacks for the state machine.
    private func setupTransitions() {
        // Define transitions
        stateMachine.addTransition(from: .start, event: .selectCaregiver, to: .configureCaregiver)
        stateMachine.addTransition(from: .start, event: .selectPatient, to: .configurePatient)
        stateMachine.addTransition(from: .configureCaregiver, event: .shareID, to: .done)
        stateMachine.addTransition(from: .configurePatient, event: .shareID, to: .done)
        stateMachine.addTransition(from: .done, event: .finish, to: .start)
        stateMachine.addTransition(from: .configureCaregiver, event: .back, to: .start)
        stateMachine.addTransition(from: .configurePatient, event: .back, to: .start)
        stateMachine.addTransition(from: .done, event: .cancel, to: .start)
        
        // Define callbacks
        stateMachine.addCallback(for: .done) { state in
            print("Entered state: \(state)")
            // Additional actions can be performed here
        }
    }
    
    /// Handles an event by passing it to the state machine.
    ///
    /// - Parameter event: The event to handle.
    func handle(event: WizardEvent) {
        stateMachine.handle(event: event)
    }
}

/// Represents the different states of the RemoteNotificationsWizard.
enum WizardState: Hashable {
    case start
    case configureCaregiver
    case configurePatient
    case done
}

/// Represents the events that can trigger state transitions in the RemoteNotificationsWizard.
enum WizardEvent: Hashable {
    case selectCaregiver
    case selectPatient
    case shareID
    case finish
    case cancel
    case back
}

/// The main view for configuring remote notifications via a wizard interface.
struct RemoteNotificationsWizard: View {
    /// The ViewModel managing the wizard's state.
    @StateObject private var viewModel = WizardViewModel()
    
    var body: some View {
        VStack {
            ZStack {
                switch viewModel.stateMachine.currentState {
                case .start:
                    StartView(viewModel: viewModel)
                        .transition(.move(edge: .trailing))
                case .configureCaregiver:
                    ConfigureCaregiverView(
                        viewModel: viewModel
                    )
                    .transition(.slide)
                case .configurePatient:
                    ConfigurePatientView(
                        viewModel: viewModel
                    )
                    .transition(.slide)
                case .done:
                    DoneView(viewModel: viewModel)
                        .transition(.move(edge: .leading))
                }
            }
            .animation(.easeInOut, value: viewModel.stateMachine.currentState)
        }
        .padding()
    }
}

/// The initial view of the wizard where users select their role.
struct StartView: View {
    /// The ViewModel managing the wizard's state.
    @ObservedObject var viewModel: WizardViewModel
    
    var body: some View {
        VStack {
            Text("Configure remote monitoring on both phones")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("I am the Caregiver") {
                viewModel.handle(event: .selectCaregiver)
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button("I am the Patient") {
                viewModel.handle(event: .selectPatient)
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
            
            Button("Cancel") {
                viewModel.handle(event: .cancel)
            }
            .padding()
        }
    }
}

/// The view for configuring caregiver settings.
struct ConfigureCaregiverView: View {
    /// The ViewModel managing the wizard's state.
    @ObservedObject var viewModel: WizardViewModel
    
    var body: some View {
        VStack {
            Text("Configure caregiver settings")
                .font(.headline)
                .padding()
            
            ActionButton(title: "shareYourIDBtnMsg".local(), action: shareCareGiverUrlID)
                .padding(.bottom)
            
            Spacer()
            
            Button("Back") {
                viewModel.handle(event: .back)
            }
            .padding()
        }
    }
}

/// The view for configuring patient settings.
struct ConfigurePatientView: View {
    /// The ViewModel managing the wizard's state.
    @ObservedObject var viewModel: WizardViewModel
    
    var body: some View {
        VStack {
            Text("Configure patient settings")
                .font(.headline)
                .padding()
            
            ActionButton(title: "shareYourIDCaregiverMsg".local(), action: shareKidUrlID)
            
            Spacer()
            
            Button("Back") {
                viewModel.handle(event: .back)
            }
            .padding()
        }
    }
}

/// The final view indicating the wizard completion.
struct DoneView: View {
    /// The ViewModel managing the wizard's state.
    @ObservedObject var viewModel: WizardViewModel
    
    var body: some View {
        VStack {
            Text("Done! Ensure you've completed the same process on the other device.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            ActionButton(title: "tryPushNotificationBtnLabel".local()) {
                SymptomsManager.shared.fireTelemetryControlSymptoms(SymptomLog(.none, notes: "testRemoteNotifications".local()))
            }
            
            Button("Finished") {
                viewModel.handle(event: .finish)
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
    }
}
