//
//  AIFLowStatuses.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 09/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation

enum AIFlowStatuses: Equatable {
    case error(_ msg: String)
    case test
    case transcriptReady
    case ready
    case notActive
    case emptyTranscript
    case start
    case sentimentDetected
    case nLPCompleted
    case basicSymptSearchCompleted
    case validateSymptomsByUser
    case noSymptomsDetected
    case userValidated
    case completed
}
