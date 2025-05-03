//
//  SentimentView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 06/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI

struct SentimentSymptomView: View {
    @ObservedObject var sentiment: Sentiment
    init(inputText: String) {
        sentiment = Sentiment(from: inputText)
    }
    
    var body: some View {
        Text("Sentiment_String".local() + ": \(Sentiments.sentimentFromScore(sentiment.score).emoji)")
    }
}
