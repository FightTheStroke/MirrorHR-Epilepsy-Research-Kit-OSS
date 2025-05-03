//
//  SymptomsNLP.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 27/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//
import Foundation
// import NLP

/// Natural Language Processing class for symptom analysis
/// - Processes text input for symptom detection
/// - Provides sentiment analysis
/// - Manages symptom categorization
/// - Integrates with video diary system
class SymptomsNLP {
//    let nlp: NLPAlgorithm
//
//    init(nlp: NLPAlgorithm? = nil) throws {
//        self.nlp = try nlp ?? NLP()
//    }
    
    func check(symptoms: [HandledSymptomsEvents], in transcript: String) throws -> [HandledSymptomsEvents] {
        return []
    }
    
//    func check(symptoms: [HandledSymptomsEvents], in transcript: String) throws -> [HandledSymptomsEvents] {
//        let questionFormat = "Did they have %@?"
//        
//        var answers: [HandledSymptomsEvents] = []
//        var lock = os_unfair_lock()
//        
//        DispatchQueue.concurrentPerform(iterations: symptoms.count) { index in
//            let symptom = symptoms[index]
//            let localizedSymptom = symptom.localizedString()
//            let question = String(format: questionFormat, localizedSymptom)
//            do {
//                let answer = try self.nlp.yesNoAnswer(for: question, in: transcript)
//                if answer.answerFound {
//                    os_unfair_lock_lock(&lock)
//                    answers.append(symptom)
//                    printToConsole("question: \(question) answer: \(answer) for symptom: \(symptom)")
//                    os_unfair_lock_unlock(&lock)
//                }
//            } catch {
//                printToConsole("The classifier raised an error: \(error)")
//            }
//        }
//        return answers
//    }
}
