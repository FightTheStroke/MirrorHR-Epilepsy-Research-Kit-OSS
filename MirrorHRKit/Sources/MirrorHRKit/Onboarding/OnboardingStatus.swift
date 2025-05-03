//
//  OnboardingStatus.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 08/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import SharedPkg
import RoberdanToolBox
import MirrorHRTelemetryPackage

public enum OnboardingStatus: Comparable {
    case showFullOnboarding
    case showWhatsNew
    case justRun
    case booting
    
    public var onboardingData: [OnboardingCard] {
        switch self {
        case .showWhatsNew:
            return OnboardingWrapperViewModel.whatsNewOnboardingData
        case .showFullOnboarding:
            return OnboardingWrapperViewModel.onboardingAllCard
        case .justRun, .booting:
            return []
        }
    }
}

public class OnboardingStateMachine: ObservableObject {
    static public let shared = OnboardingStateMachine()
    private let dataSourceManager: DataSourceManager = .shared
    
    @Published public var mainAppStatus: OnboardingStatus = .booting
    
    @AppStorage("userType") private var userType: UserType = .brandNewUser
    @AppStorage("userTypeDetail") private var userTypeDetail: String = ""
    @AppStorage("lastOnboardedVersion") private var lastOnboardedVersion: String = ""
    @AppStorage("isOnboarding") private var isOnboarding: Bool = true { didSet { refresh() }}
    @AppStorage("isShowWhatsNew") private var isShowWhatsNew: Bool = false { didSet { refresh() }}
    @AppStorage("onBoardingCnt") private var onBoardingCnt: Int = 0
    
    private init() {
        refresh()
    }
    
    public var isShowingOnboarding: Bool {
        return isOnboarding
    }
    
    private func refresh() {
        DispatchQueue.main.async {
            self.updateAppStatus()
            self.updateUserType()
            self.logEventIfNeeded()
        }
    }

    private func updateAppStatus() {
        if isOnboarding {
            mainAppStatus = .showFullOnboarding
        } else if lastOnboardedVersion != appVersion {
            mainAppStatus = .showWhatsNew
            performMigration()
        } else {
            mainAppStatus = .justRun
        }
    }

    private func updateUserType() {
        if isOnboarding {
            if onBoardingCnt == 0 {
                userType = .brandNewUser
            } else {
                onBoardingCnt += 1
            }
        } else if lastOnboardedVersion != appVersion {
            userType = .updatingUser
            userTypeDetail = "Onboarding New Version: from \(lastOnboardedVersion) to \(appVersion)"
        } else {
            userType = .returningUser
            userTypeDetail = dataSourceManager.dataSource.rawValue         }
        TelemetryHeader.shared.updateUserType(with: userType)
    }

    private func logEventIfNeeded() {
        if isOnboarding && onBoardingCnt == 0 || lastOnboardedVersion != appVersion || mainAppStatus == .justRun {
            dispatchTelemetryEvent(event: .booting(userType: userType, value: userTypeDetail))
        }
    }

    private func performMigration() {
        Migrator(from: lastOnboardedVersion).migrate { migrationStatus in
            mainDebugger.append("\(migrationStatus)", .justALog)
        }
    }

    
    public func setOnboarding(to newValue: Bool) {
        DispatchQueue.main.async { [self] in
            if newValue == false {
                lastOnboardedVersion = appVersion
                isShowWhatsNew = false
            }
            isOnboarding = newValue
            refresh()
        }
    }
    
    public func setShowWhatsNew(to: Bool) {
        if !to {
            lastOnboardedVersion = appVersion
        }
        isShowWhatsNew = to
        refresh()
    }
    
    public var whatsLastOnboardedVersion: String {
        lastOnboardedVersion
    }
}
