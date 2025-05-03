//
//  FastLogHomeWidgetView.swift
//  MirrorHRWidgetExtension
//
//  Created by Roberto D’Angelo on 29/10/23.
//  Copyright © 2023 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import MirrorHRKit

public struct FastLogHomeWidgetView: View {
    @State var showHelp: Bool = false
    
    public init() { }
    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image("MirrorShield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                Text(shortAppName + " FastLog")
                    .font(.headline)
            }
            FastLogBodyView(showHelp: showHelp)
            FastLogMostCommonSymptoms(showHelp: showHelp)
                .padding(.top, 5)
        }
    }
}

public struct FastLogBodyView: View {
    var showHelp: Bool
    
    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(HandledSymptomsEvents.quickCommands.enumerated()), id: \.offset) { index, symptom in
                FastLogButtonView(symptom: symptom, showHelp: showHelp)
                // Add a spacer for every item except the last one
                if index < HandledSymptomsEvents.quickCommands.count - 1 {
                    Spacer()
                }
            }
        }
    }
}

public struct FastLogMostCommonSymptoms: View {
    @ObservedObject private var widgetSupport: WidgetSupportClass = .shared
    var showHelp: Bool

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(widgetSupport.topLoggedSymptoms.enumerated()), id: \.offset) {  index, symptom in
                FastLogButtonView(symptom: symptom, showHelp: showHelp)
                // Add a spacer for every item except the last one
                if index < widgetSupport.topLoggedSymptoms.count - 1 {
                    Spacer()
                }
            }
        }
    }
}

struct FastLogButtonView: View {
    var symptom: HandledSymptomsEvents
    @State private var btnPressed: Bool = false
    var showHelp: Bool
    @State private var resetTimer: Timer?
    
    var body: some View {
            VStack(spacing: 8) {
                Link(destination: URL(string: "MirrorHR://fastLog?\(symptom.rawValue)")!) {
                    ZStack {
                        Circle()
                            .foregroundColor(btnPressed ? .accentColor.opacity(0.8) : Color(UIColor.systemBackground))
                            .shadow(color: btnPressed ? .clear : Color(UIColor.systemGray4).opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: symptom.quickCommandsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(btnPressed ? .primary : .primary)
                            .overlay(conditionalOverlayView())
                    }
                    .onTapGesture {
                        withAnimation {
                            btnPressed = true
                            if btnPressed {
                                startTimer()
                            }
                        }
                    }
                }
                .foregroundColor(nil) // Reset the default link color
                .buttonStyle(PlainButtonStyle()) // Ensure no default button styling is applied
                .frame(width: 45, height: 45)
                .background(
                    RadialGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.systemGray5).opacity(0.1)]), center: .center, startRadius: 2, endRadius: 30)
                )
                .clipShape(Circle())
                
                if showHelp {
                    Text(symptom.localizedString())
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
        }
    
    func conditionalOverlayView() -> some View {
        if btnPressed {
            return AnyView(FastLogCheckMarkOverlayView())
        } else {
            return AnyView(EmptyView())
        }
    }
    
    func startTimer() {
        stopTimer() // Ensure any existing timer is stopped
        resetTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { _ in
            btnPressed = false
            stopTimer()
        }
    }

    func stopTimer() {
        resetTimer?.invalidate()
        resetTimer = nil
    }
}


public struct FastLogCheckMarkOverlayView: View {
    @State private var animateCheckmark: Bool = false
    
    public var body: some View {
        if animateCheckmark {
            Path { path in
                path.move(to: CGPoint(x: 5, y: 15))
                path.addLine(to: CGPoint(x: 15, y: 25))
                path.addLine(to: CGPoint(x: 35, y: 5))
            }
            .trim(from: 0, to: animateCheckmark ? 1 : 0)
            .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .foregroundColor(Color(UIColor.label))
            .frame(width: 40, height: 30)
            .onAppear() {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animateCheckmark = true
                }
            }
        }
    }
}
