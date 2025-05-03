//
//  FlashingMessagesView.swift
//  
//
//  Created by Roberto D’Angelo on 31/07/22.
//

import Foundation
import SwiftUI
import RoberdanToolBox
import SharedPkg

struct FlashingMessageView: View {
    var message: String
    var captionMsg: String
    private var timer: Timer?
    private var goToWebURL: String?
    
    init(message: String, captionMsg: String, goToWebURL: String?) {
        self.message = message
        self.captionMsg = captionMsg
        shouldMessageBlink = false
        self.goToWebURL = goToWebURL
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            DispatchQueue.main.async {
                shouldMessageBlink.toggle()
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(message)
                .font(.largeTitle).fontWeight(.black)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            HStack {
                Text(captionMsg)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                if goToWebURL != nil {
                    Button(action: {
                        goToWeb(goToWebURL!)
                    }, label: {
                        Image(systemName: "questionmark.circle")
                    })
                }
            }
        }
        .padding()
        .background(shouldMessageBlink ? FlowStages.warning.chartColor.color : .clear)
        .foregroundColor(shouldMessageBlink ? .primary : FlowStages.warning.chartColor.color)
        .cornerRadius(defaultViewCornerRadius)
        .onDisappear(perform: {
            timer?.invalidate()
            shouldMessageBlink = false
        })
    }
}
