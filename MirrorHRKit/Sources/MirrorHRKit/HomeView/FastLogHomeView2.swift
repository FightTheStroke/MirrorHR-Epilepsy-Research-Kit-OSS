//
//  FastLogHomeView.swift
//
//
//  Created by Roberto D’Angelo on 24/09/23.
//

import Foundation
import SharedPkg
import SwiftUI

let emptySymptom: HandledSymptomsEvents = .none

public struct FastLogHomeView: View {
    @State var showHelp: Bool = false

    public init() {}
    public var body: some View {
        VStack(alignment: .leading) {
            FastLogHeaderView(showHelp: $showHelp)
            FastLogBodyView(showHelp: showHelp)
            FastLogMostCommonSymptoms(showHelp: showHelp)
                .padding(.top, 5)
            MoodTrackerView(showHeaderInView: true)
                .padding(.top)
        }
    }
}

// TODO: secure it's aligned with the way medication reminders is handled and not just saving it

public struct FastLogHeaderView: View {
    @Binding var showHelp: Bool

    public var body: some View {
        // MARK: FastLog Header
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text("FastLogMsg".local())
                        .font(.title2).fontWeight( /*@START_MENU_TOKEN@*/
                            .bold /*@END_MENU_TOKEN@*/)

                    Button {
                        showHelp.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .font(.callout)
                }
            }

            Spacer()

            FastLogLinkedViews(showHelp: showHelp)
        }
    }
}

public struct FastLogLinkedViews: View {
    var showHelp: Bool

    public var body: some View {
        VStack(alignment: .trailing) {
            Button {
                TabViewController.shared.tabView = Tab.diary.rawValue
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.accentColor)
            }
        }
    }
}

public struct FastLogBodyView: View {
    var showHelp: Bool

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(
                Array(HandledSymptomsEvents.quickCommands.enumerated()),
                id: \.offset
            ) { index, symptom in
                FastLogButtonView(symptom: symptom, showHelp: showHelp)
                // Add a spacer for every item except the last one
                if index < HandledSymptomsEvents.quickCommands.count - 1 {
                    Spacer()
                }
            }
        }
    }
}

public struct FastLogInDiary: View {
    @State private var buttonPressed: [Bool] = Array(
        repeating: false, count: HandledSymptomsEvents.quickCommands.count)
    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(
                Array(HandledSymptomsEvents.quickCommands.enumerated()),
                id: \.offset
            ) { index, symptom in
                VStack {
                    Image(systemName: symptom.quickCommandsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            if !buttonPressed[index] {
                                symptom.quickCommandAction()
                                withAnimation {
                                    buttonPressed[index] = true
                                }
                                // Re-enable after 2.5 seconds
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 2
                                ) {
                                    withAnimation {
                                        buttonPressed[index] = false
                                    }
                                }
                            }
                        }
                        .foregroundColor(
                            buttonPressed[index] ? .green : .primary)
                    Text(symptom.localizedString())
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                if index < HandledSymptomsEvents.quickCommands.count - 1 {
                    Spacer()
                }
            }
        }
    }
}

public struct FastLogMostCommonSymptoms: View {
    @ObservedObject private var symptomsManager: SymptomsManager = .shared
    var showHelp: Bool

    // Property calculator to prepare symptoms.
    private var preparedTopLoggedSympt: [HandledSymptomsEvents] {
        var symptoms = SymptomsManager.shared.topLoggedSympts
        let initialCount = symptoms.count
        let missingCount = SymptomsManager.maxTopLoggedSymptoms - initialCount

        if initialCount < SymptomsManager.maxTopLoggedSymptoms {
            // Add empty symptoms for each missing space
            for _ in 0..<missingCount {
                symptoms.append(emptySymptom)  // Make sure there's a way to create an 'empty symptom'
            }
        }
        return symptoms
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(preparedTopLoggedSympt.enumerated()), id: \.offset) {
                index, symptom in
                FastLogButtonView(symptom: symptom, showHelp: showHelp)
                // Aggiungi uno Spacer tra gli elementi, tranne che dopo l'ultimo elemento
                if index < preparedTopLoggedSympt.count - 1 {
                    Spacer()
                }
            }
        }
    }
}

public struct FastLogButtonView: View {
    var symptom: HandledSymptomsEvents
    @State private var btnPressed: Bool = false
    var showHelp: Bool

    public var body: some View {
        let isItEmpty: Bool = symptom.rawValue == emptySymptom.rawValue

        VStack(spacing: 8) {
            Button(action: {
                if !isItEmpty {
                    withAnimation {
                        btnPressed = true
                        // Use DispatchQueue to delay the reset of btnPressed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                btnPressed = false
                                symptom.quickCommandAction()
                            }
                        }
                    }
                } else {
                    print("empty button")  // do nothing
                }
            }) {
                ZStack {
                    Circle()
                        .foregroundColor(
                            btnPressed
                                ? .accentColor.opacity(0.8)
                                : Color(UIColor.systemBackground)
                        )
                        .shadow(
                            color: btnPressed
                                ? .clear
                                : Color(UIColor.systemGray4).opacity(0.3),
                            radius: 10, x: 0, y: 5)
                    if !isItEmpty {
                        Image(systemName: symptom.quickCommandsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(btnPressed ? .primary : .primary)
                            .overlay(conditionalOverlayView())
                    }
                }
            }
            .frame(width: 45, height: 45)
            .background(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor.systemBackground),
                        Color(UIColor.systemGray5).opacity(0.1),
                    ]), center: .center, startRadius: 2, endRadius: 30)
            )
            .clipShape(Circle())
            .disabled(symptom.rawValue == emptySymptom.rawValue)

            if showHelp, symptom.rawValue != emptySymptom.rawValue {
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
            .stroke(
                style: StrokeStyle(
                    lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
            .foregroundColor(Color(UIColor.label))
            .frame(width: 40, height: 30)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animateCheckmark = true
                }
            }
        }
    }
}

public struct MoodTrackerView: View {
    @State private var buttonPressed: [Bool] = Array(
        repeating: false, count: HandledSymptomsEvents.dailyMoods.count)
    var showHeaderInView: Bool

    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if showHeaderInView {
                Text("MoodMsg".local())
                    .font(.headline)
                Spacer()
            }
            ForEach(
                Array(HandledSymptomsEvents.dailyMoods.enumerated()),
                id: \.offset
            ) { index, mood in
                Text(mood.image)
                    .font(.headline)
                    .opacity(buttonPressed[index] ? 0.2 : 1.0)  // Dim the view when pressed
                    .onTapGesture {
                        SymptomsManager.shared.appendSymptomLog(.init(mood))
                        withAnimation {
                            buttonPressed[index] = true
                        }
                        // Re-enable after 2.5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                buttonPressed[index] = false
                            }
                        }
                    }
                    .disabled(buttonPressed[index])

                // Add a spacer for every item except the last one
                if index < HandledSymptomsEvents.dailyMoods.count - 1 {
                    Spacer()
                }
            }
        }
    }
}
