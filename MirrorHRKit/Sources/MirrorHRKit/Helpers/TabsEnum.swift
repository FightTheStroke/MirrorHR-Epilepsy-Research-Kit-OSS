//
//  TabsEnum.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 25/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import RoberdanToolBox
import SharedPkg

public enum Tab: Int, CaseIterable {
    case realtimeMonitor = 1
    case diary = 2
    case insights = 3
    case settings = 4
    case debugLogs = 6
    case onboarding = 7
    case realtimeNoWatch = 8
    case home = 0

    public var landingView: AnyView {
        switch self {
        case .home: return AnyView(HomeView())
        case .realtimeMonitor: return AnyView(RealTimeView())
        case .realtimeNoWatch: return AnyView(RealTimeNoWatchView())
        case .diary: return AnyView(SymptomsLogsView())
        case .insights: return AnyView(InsightsCoreDataMainView())
        case .settings: return AnyView(SettingsView())
        case .onboarding: return AnyView(OnboardingWrapperView())
        // NB: DebugLogsView is in RoberdanToolBox package
        case .debugLogs: return AnyView(DebugLogsView())
        }
    }
    
    public var title: String {
        switch self {
        case .home: return "TabHome".local()
        case .realtimeMonitor: return tabRealTimeMonitor
        case .diary: return tabDiary
        case .insights: return tabInsights
        case .settings: return tabSettings
        case .debugLogs: return tabDebugLogs
        case .onboarding: return tabOnboarding
        case .realtimeNoWatch: return tabRealTimeMonitor
        }
    }

    public var image: String {
        switch self {
        case .realtimeMonitor: return "heart.fill"
        case .realtimeNoWatch: return "heart.slash"
        case .diary: return "plus.circle"
        case .insights: return "books.vertical"
        case .settings: return "gear"
        case .debugLogs: return "ladybug.fill"
        case .onboarding: return "play"
        case .home: return "house"
        }
    }
}
