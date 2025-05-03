//
//  Onboarding.swift
//  core stuff for an onboarding experience
//
//  Created by Roberto D’Angelo on 22/12/20.
//

import Foundation
import SwiftUI
import SharedPkg
import StoreKit

public struct OnboardingConditionalCardView: View {
    @ObservedObject private var settings: ProfileGenericSettings = .shared
    @ObservedObject private var dataSourceManager: DataSourceManager = .shared
    
    public var card: OnboardingCard
    public var startMsg: String
    public var cardBackGroundUIColor: UIColor
    public var cardsToBeExcludedIfConditionIsFalse: [Int]
    @State private var isAnimating: Bool = false
    @State private var isDisabled: Bool = false
    
    public init(card: OnboardingCard, startMsg: String, cardBackGroundUIColor: UIColor, cardsToBeExcludedIfConditionIsFalse: [Int]) {
        self.card = card
        self.startMsg = startMsg
        self.cardBackGroundUIColor = cardBackGroundUIColor
        self.cardsToBeExcludedIfConditionIsFalse = cardsToBeExcludedIfConditionIsFalse
        checkIfDisabled()
    }
    
    func checkIfDisabled() {
        isDisabled = !settings.appleWatchEnabled && cardsToBeExcludedIfConditionIsFalse.contains(card.tagNumber)
    }
    
    // MARK: - BODY
    
    public var body: some View {
        let enabledCardGradientColor = LinearGradient(gradient: Gradient(colors: card.gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
        let disabledCardGradientColor = disabledBtnDefaultBackgroundGradient
        ZStack {
            ScrollView {
                // CARD: IMAGE
                if card.image != "" {
                    if card.imageScaled2Fill {
                        Image(card.image)
                            .resizable()
                            .scaledToFill()
                            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 8, x: 6, y: 8)
                            .scaleEffect(isAnimating ? 1.0 : 0.6)
                    } else {
                        Image(card.image)
                            .resizable()
                            .scaledToFit()
                            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 8, x: 6, y: 8)
                            .scaleEffect(isAnimating ? 1.0 : 0.6)
                    }
                }
                
                // CARD: TITLE
                Text(card.title.uppercased())
                    .foregroundColor(Color.white)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.30), radius: 3, x: 3, y: 3)
                
                // CARD: HEADLINE
                if card.headline != "" {
                    Text(card.headline)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineLimit(nil)
                }
                
                if card.description != "" {
                    Text(card.description)
                        .lineLimit(nil)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                }
                
                if card.form != nil {
                    card.form
                        .background(Color(cardBackGroundUIColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous)))
                        .padding([.horizontal, .bottom])
                        .disabled(isDisabled)
                }
                // BUTTON: START
                if card.isLast {
                    StartButtonView(startMsg: startMsg)
                }
                if card.alignTop {
                    Spacer()
                }
            }
            if isDisabled {
                AppleWatchRequiredView()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
            checkIfDisabled()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .background(isDisabled ? disabledCardGradientColor : enabledCardGradientColor)
        .cornerRadius(defaultViewCornerRadius)
        .padding(.horizontal)
        .onChange(of: settings.appleWatchEnabled) { _ in
            checkIfDisabled()
        }
    }
}

public struct StartButtonView: View {
    @ObservedObject var mainAppStatus = OnboardingStateMachine.shared
    public var startMsg: String
    
    public var body: some View {
        let btnAction = {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }

            switch mainAppStatus.mainAppStatus {
            case .showFullOnboarding:
                mainAppStatus.setOnboarding(to: false)
            case .showWhatsNew:
                mainAppStatus.setShowWhatsNew(to: false)
            case .justRun:
                break
            case .booting:
                break
            }
        }
        Button(action: btnAction) {
            HStack(spacing: 8) {
                Text(startMsg)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Image(systemName: "arrow.right.circle")
                    .imageScale(.large)
            }
            .foregroundColor(Color.white)
            .font(.largeTitle)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule().strokeBorder(Color.white, lineWidth: 1.25)
            )
        }
        .accentColor(Color.white)
        .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.30), radius: 3, x: 3, y: 3)

    }
}

public struct AppleWatchRequiredView: View {
    public var body: some View {
        VStack(alignment: .center) {
            Image("watchappstart")
                .resizable()
                .frame(width: 200, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(appleWatchRequiredMsg.uppercased())
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .edgesIgnoringSafeArea(.horizontal)
        .padding()
        .background(Color.yellow)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .opacity(0.9)
    }
}

public struct OnboardingCard: Identifiable {
    public var id = UUID()
    public var title: String
    public var headline: String
    public var image: String
    public var gradientColors: [Color]
    public var description: String
    public var form: AnyView?
    public var isLast: Bool
    public var alignTop: Bool
    public var tagNumber: Int
    public var imageScaled2Fill: Bool
    
    public init(title: String, headline: String, image: String, imageScaled2Fill: Bool = true, gradientColors: [Color], description: String, form: AnyView?, isLast: Bool, alignTop: Bool, tagNumber: Int) {
        self.title = title
        self.alignTop = alignTop
        self.description = description
        self.headline = headline
        self.image = image
        self.gradientColors = gradientColors
        self.form = form
        self.isLast = isLast
        self.tagNumber = tagNumber
        self.imageScaled2Fill = imageScaled2Fill
    }
}
