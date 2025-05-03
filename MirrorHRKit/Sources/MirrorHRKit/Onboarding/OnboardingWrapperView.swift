//
//  OnboardingWrapperView.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 11/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Combine
import RoberdanToolBox
import SwiftUI
import SharedPkg

public class OnboardingWrapperViewModel: ObservableObject {
    public static let shared: OnboardingWrapperViewModel = OnboardingWrapperViewModel()
    let onboardingData: [OnboardingCard] = OnboardingWrapperViewModel.onboardingAllCard
    let cardsToBeExcludedIfConditionIsFalse: [Int] = OnboardingWrapperViewModel.onboardingTagsRequiringWatch
    @State var conditionOfInclusion: Bool = ProfileGenericSettings.shared.appleWatchEnabled
    let startMsg: String = NSLocalizedString("startMsg", comment: "")
    let tertiaryBackgroundColor: UIColor = .tertiarySystemBackground
    @Published var settings: ProfileGenericSettings = .shared
    @Published var currentIndex: Int = 0
}

public struct OnboardingWrapperView: View {
    @ObservedObject var viewModel: OnboardingWrapperViewModel = .shared
    @ObservedObject private var dataSourceManager: DataSourceManager = .shared

    public init() {
        
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                if viewModel.currentIndex < viewModel.onboardingData.count {
                    OnboardingConditionalCardView(card: viewModel.onboardingData[viewModel.currentIndex],
                                                  startMsg: viewModel.startMsg,
                                                  cardBackGroundUIColor: viewModel.tertiaryBackgroundColor,
                                                  cardsToBeExcludedIfConditionIsFalse: viewModel.cardsToBeExcludedIfConditionIsFalse
                    )
                }

                Spacer()

                HStack {
                    Button(action: {
                        if viewModel.currentIndex > 0 {
                            viewModel.currentIndex -= 1
                        }
                    }) {
                        Image(systemName: "arrow.backward.circle")
                    }
                    .disabled(viewModel.currentIndex == 0)

                    Spacer()

                    Text("\("tabOnboarding".local()): \(viewModel.currentIndex + 1) / \(viewModel.onboardingData.count)")
                        .font(.headline)

                    Spacer()

                    Button(action: {
                        if viewModel.currentIndex < viewModel.onboardingData.count - 1 {
                            viewModel.currentIndex += 1
                        }
                    }) {
                        Image(systemName: "arrow.forward.circle")
                    }
                    .disabled(viewModel.currentIndex == viewModel.onboardingData.count - 1)
                }
                .fontWeight(.heavy)
                .padding()
            }
        }
        .supportedOrientation(.portrait)
        .accentColor(.blue)
    }
}


struct OnboardingWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingWrapperView()
    }
}
