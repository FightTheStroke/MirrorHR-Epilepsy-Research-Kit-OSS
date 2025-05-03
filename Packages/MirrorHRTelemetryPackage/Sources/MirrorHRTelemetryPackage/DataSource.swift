//
//  File.swift
//
//
//  Created by Roberto D’Angelo on 12/05/24.
//

import Foundation

public enum DataSource: String, Codable, CaseIterable {
    case appleWatchPairedOnly
    case appleWatchAndInternetKeyEventsStreamingAsServer
    case appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer
    case diaryOnly
    case internetStreamingAsClientForKeyEventsOnly
    case internetStreamingAsClientForKeyEventsAndBPMs
    
    private var debugTitle: String {
        switch self {
        case .diaryOnly:
            return "RemoteDiaryOnlyDataSourceTitle"
        case .appleWatchPairedOnly:
            return "PairedWithAppleWatchView"
        case .appleWatchAndInternetKeyEventsStreamingAsServer:
            return "RemoteAppleWatchAndInternetKeyEventsStreamingAsServerMsg"
        case .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return "RemoteAppleWatchAndInternetKeyEventsAndBPMsStreamingAsServer"
        case .internetStreamingAsClientForKeyEventsOnly:
            return "RemoteInternetStreamingAsClientForKeyEventsOnly"
        case .internetStreamingAsClientForKeyEventsAndBPMs:
            return "RemoteInternetStreamingAsClientForKeyEventsAndBPMs"
        }
    }

    private var debugDescription: String {
        switch self {
        case .diaryOnly:
            return "RemoteDiaryOnlyDataSourceDebugMsg"
        case .appleWatchPairedOnly:
            return "RemoteAppleWatchPairedOnlyDebugMsg"
        case .appleWatchAndInternetKeyEventsStreamingAsServer:
            return "RemoteappleWatchAndInternetKeyEventsStreamingAsServer"
        case .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return "RemoteAppleWatchAndInternetKeyEventsAndBPMsStreamingAsServer"
        case .internetStreamingAsClientForKeyEventsOnly:
            return "RemoteInternetStreamingAsClientForKeyEventsOnly"
        case .internetStreamingAsClientForKeyEventsAndBPMs:
            return "RemoteInternetStreamingAsClientForKeyEventsAndBPMs"
        }
    }
    
    public var title: String {
        return self.debugTitle.local()
    }
    
    public var helpMessage: String {
        let potentialOnboardingRestartMsg: String = "RemotePotentialOnboardingRestartMsg".local()

        switch self {
        case .appleWatchPairedOnly, .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer, .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
            return self.debugDescription.local() + " " + potentialOnboardingRestartMsg
        case .diaryOnly:
            return self.debugDescription.local()
        }
    }
    
    public var appleWatchIsRequired: Bool {
        switch self {
        case .diaryOnly:
            return false
        case .appleWatchPairedOnly,  .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return true
        case .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
            return false
        }
    }
}

extension DataSource {
    public var isReceivingBPMsViaLocalStreaming: Bool {
        switch self {
        case .diaryOnly, .appleWatchPairedOnly, .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer,
                .internetStreamingAsClientForKeyEventsAndBPMs,.internetStreamingAsClientForKeyEventsOnly:
            return false
        }
    }
    
    public var isReceivingBPMsViaInternetStreaming: Bool {
        switch self {
        case .diaryOnly, .appleWatchPairedOnly,  .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer,
                .internetStreamingAsClientForKeyEventsOnly:
            return false
        case .internetStreamingAsClientForKeyEventsAndBPMs:
            return true
        }
    }
    public var canSetKeySettings: Bool {
        switch self {
        case .diaryOnly, .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
            return false
        case .appleWatchPairedOnly, .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return true
        }
    }
    
    public var shouldFireNoData: Bool {
        switch self {
        case .diaryOnly:
            return false
        case .appleWatchPairedOnly:
            return true
        case .appleWatchAndInternetKeyEventsStreamingAsServer:
            return true
        case .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return true
        case .internetStreamingAsClientForKeyEventsOnly:
            return false
        case .internetStreamingAsClientForKeyEventsAndBPMs:
            return false
        }
    }
    
    public var isNotificationSettingsEnabled: Bool {
        switch self {
        case .diaryOnly, .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
            return false
        case .appleWatchPairedOnly, .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return true
        }
    }
    
    public var shouldSaveRealtimeSession: Bool {
        switch self {
        case .diaryOnly,
                .internetStreamingAsClientForKeyEventsOnly,
                .internetStreamingAsClientForKeyEventsAndBPMs:
            return false
        case .appleWatchPairedOnly,
                .appleWatchAndInternetKeyEventsStreamingAsServer,
                .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer :
            return true
        }
    }
    
    public var shouldSendKeyEventsToCareGivers: Bool {
        switch self {
        case .diaryOnly:
            return false
        case .appleWatchPairedOnly:
            return false
        case .appleWatchAndInternetKeyEventsStreamingAsServer:
            return true
        case .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return true
        case .internetStreamingAsClientForKeyEventsOnly:
            return false
        case .internetStreamingAsClientForKeyEventsAndBPMs:
            return false
        }
        
    }
    
    public var requiresOnboarding: Bool {
        switch self {
        case .diaryOnly:
            return false
        case .appleWatchPairedOnly:
            return true
        case .appleWatchAndInternetKeyEventsStreamingAsServer:
            return true
        case .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return true
        case .internetStreamingAsClientForKeyEventsOnly:
            return false
        case .internetStreamingAsClientForKeyEventsAndBPMs:
            return false
        }
    }
    
    public var shouldHandleWatchSession: Bool {
        switch self {
        case .diaryOnly:
            return false
        case .appleWatchPairedOnly:
            return true
        case .appleWatchAndInternetKeyEventsStreamingAsServer:
            return true
        case .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return true
        case .internetStreamingAsClientForKeyEventsOnly:
            return false
        case .internetStreamingAsClientForKeyEventsAndBPMs:
            return false
        }
    }
    
    public var isClientOnly: Bool {
        switch self {
        case .diaryOnly, .appleWatchPairedOnly,  .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return false
        case .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
            return true
        }
    }
    
    public var shouldStreamLocallyOrViaInternet: Bool {
        switch self {
        case .diaryOnly,
                .appleWatchPairedOnly,
                .internetStreamingAsClientForKeyEventsOnly,
                .internetStreamingAsClientForKeyEventsAndBPMs:
            return false
        case .appleWatchAndInternetKeyEventsStreamingAsServer,
                .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return true
        }
    }
    
    public var isOkToHandleWatchCommunicationErrors: Bool {
        switch self {
        case .diaryOnly,
                .internetStreamingAsClientForKeyEventsOnly,
                .internetStreamingAsClientForKeyEventsAndBPMs:
            return false
        case .appleWatchPairedOnly,
                .appleWatchAndInternetKeyEventsStreamingAsServer,
                .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return true
        }
    }
    
    public var shouldReceiveRemoteNotifications: Bool {
        switch self {
        case .diaryOnly, .appleWatchPairedOnly:
            return false
        case .appleWatchAndInternetKeyEventsStreamingAsServer,
                .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return false
        case .internetStreamingAsClientForKeyEventsOnly,
                .internetStreamingAsClientForKeyEventsAndBPMs:
            return true
        }
    }
    
    public var shouldReceiveBPMsViaSilentNotifications: Bool {
        switch self {
        case .diaryOnly,
                .appleWatchPairedOnly,
                .appleWatchAndInternetKeyEventsStreamingAsServer,
                .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer,
                .internetStreamingAsClientForKeyEventsOnly:
            return false
        case .internetStreamingAsClientForKeyEventsAndBPMs:
            return true
        }
    }
    
    public var shouldReceiveKeyEventsViaRemoteNotifications: Bool {
        switch self {
        case .diaryOnly,
                .appleWatchPairedOnly,
                .appleWatchAndInternetKeyEventsStreamingAsServer,
                .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return false
        case .internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs:
            return true
        }
    }
    
    public var couldReceiveRemoteCommandsFromCaregiver: Bool {
        switch self {
        case .appleWatchPairedOnly:
            return false
        case .appleWatchAndInternetKeyEventsStreamingAsServer:
            return true
        case .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer:
            return true
        case .diaryOnly:
            return false
        case .internetStreamingAsClientForKeyEventsOnly:
            return false
        case .internetStreamingAsClientForKeyEventsAndBPMs:
            return false
        }
    }
    
    public var shouldReceiveFreshBPMs: Bool {
        switch self {
        case .diaryOnly, .internetStreamingAsClientForKeyEventsOnly:
            return false
        case .appleWatchPairedOnly, .appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer,  .internetStreamingAsClientForKeyEventsAndBPMs:
            return true
        }
    }
}
