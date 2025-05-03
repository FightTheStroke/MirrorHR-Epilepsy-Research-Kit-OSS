//
//  SentimentManager.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D'Angelo on 21/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//
import Foundation
import NaturalLanguage

enum Sentiments: String {
    case negative = "sentiment_negative"
    case medium = "sentiment_medium"
    case positive = "sentiment_positive"
    
    var emoji: String {
        switch self {
        case .medium: return "😐"
        case .negative: return "🥵"
        case .positive: return "😀"
        }
    }
    
    static func sentimentFromScore(_ score: Double) -> Sentiments {
        let negativeValues: Range = -1 ..< -0.3
        // let mediumValues: Range = -0.3 ..< 0.3
        let positiveValues: Range = 0.3 ..< 1
        
        if negativeValues.contains(score) {
            return .negative
        }

        if positiveValues.contains(score) {
            return .positive
        }
        return .medium
    }
}

/// Manages sentiment analysis for video diary entries
/// - Processes emotional content of diary entries
/// - Provides sentiment scoring
/// - Handles sentiment data storage
/// - Implements ObservableObject for real-time updates
class Sentiment: ObservableObject {
    @Published var score: Double = 0.0
    
    init(from: String) {
        scoreSentiment(input: from)
    }
    
    public func scoreSentiment(input: String) {
        // feed it into the NaturalLanguage framework
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = input

        // ask for the results
        let (sentiment, _) = tagger.tag(at: input.startIndex, unit: .paragraph, scheme: .sentimentScore)

        // read the sentiment back and print it
        self.score = Double(sentiment?.rawValue ?? "0") ?? 0
    }
}
