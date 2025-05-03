//
//  CareGiversManagerExtensions.swift
//
//
//  Created by Roberto D’Angelo on 03/06/24.
//

import Foundation
import SharedPkg
import MirrorHRTelemetryPackage
import Combine

extension CareGiversManager {
/// Activates a patient.
///
/// If there's no currently active patient, the provided patient is activated.
/// If there's already an active patient, it deactivates the previous patient and activates the new one.
/// Sends a remote command to the patient to start or stop streaming to the caregiver based on the current status.
///
/// - Parameters:
///   - name: The name of the patient.
///   - uuid: The UUID of the patient.
///   - currentStatus: The current status of the patient (true for active, false for inactive).
    public func activatePatient(name: String, uuid: UUID, currentStatus: Bool) {
        dispatchMainEvent(.activePatientChanged, "Activate patient")
        sendRemoteCommandToPatient(patientID: uuid, command: .stopStreamingToCareGiver)
        // Find the currently active patient, if any
        guard let previouslySelectedPatient = getActivePatient() else {
            // No active patient found, so activate the provided patient
            updatePerson(name: name, uuid: uuid, isActive: true, type: .patient)
            sendRemoteCommandToPatient(patientID: uuid, command: .stopStreamingToCareGiver)
            return
        }
        
        // Deactivate the previously selected patient
        previouslySelectedPatient.isActive = false
        sendRemoteCommandToPatient(patientID: previouslySelectedPatient.id, command: .stopStreamingToCareGiver)
        
        // Activate the new patient
        let isActive = currentStatus ? false : true
        updatePerson(name: name, uuid: uuid, isActive: isActive, type: .patient)
        sendRemoteCommandToPatient(patientID: uuid, command: .stopStreamingToCareGiver)
        sendRemoteCommandToActivePatient(command: .careGiverCheckingRealTimeStatus)
        // Update caregivers and patients lists
    }
    
    public func forcePatientActivation(id: UUID) {
        deactivateAllPatients()
        activatePatient(uuid: id)
    }
    
    public func deactivateAllPatients() {
        for patient in patients where patient.isActive {
            sendRemoteCommandToPatient(patientID: patient.id, command: .stopStreamingToCareGiver)
            updatePerson(name: patient.name, uuid: patient.id, isActive: false, type: .patient)
        }
        dispatchMainEvent(.activePatientChanged, "deactivated all patients")
    }
    
    /// Sends a remote command to the a specifi patient.
    ///
    /// This function constructs a `RemoteCommandFromCareGiverToKid` object using the provided command,
    /// the current caregiver's name, ID, and the active patient's ID. It then sends this command to specific patient
    /// patient via telemetry. If no active patient is found, it logs an appropriate message.
    ///
    /// - Parameter command: The command to be sent to the active patient.
    public func sendRemoteCommandToPatient(patientID: UUID, command: RemoteCommands) {
        let careGiverName = TelemetryHeader.getUserName()
        let careGiverID = TelemetryHeader.getUserID()
        let patientID = patientID.uuidString
        let patientName = "not relevant for this case"
            
        let remoteCommand: RemoteCommand = RemoteCommand(command: command, careGiverName: careGiverName, careGiverID: careGiverID, kidID: patientID, kidName: patientName)

        dispatchTelemetryEvent(event: .remoteCommand(command: remoteCommand))
    }
}

extension CareGiversManager: @retroactive ErasableClass {
    
    
}
