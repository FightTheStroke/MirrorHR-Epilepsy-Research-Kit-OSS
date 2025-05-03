//
//  MirrorHRApp.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 24/09/2020.
//

import SciChart
import SwiftUI
import WatchConnectivity
import SharedPkg
import RoberdanToolBox
import MirrorHRKit
import MirrorHRTelemetryPackage
import RoberdanSecretsPackage
import PermissionsManager
import WindowsAzureMessaging
import TherapyPackage
import MyStripeApplePayPackage

// TODO: backup of therapies
let isTestMode: Bool = false // this is for testing new features

@main
struct MirrorHRApp: App {
    @StateObject private var telemetry: MirrorHRTelemetry = .shared
    @StateObject private var communicationManager = CommunicationManagerIoS.shared
    @StateObject private var notificationManager: NotificationManager = .shared
    @StateObject private var onboardingStateMachine = OnboardingStateMachine.shared
    @StateObject private var deviceOrientation = DeviceOrientation.shared
    @StateObject private var tabViewController = TabViewController.shared
    @StateObject private var mirrorHR = MirrorHRMainClass.shared
    @StateObject private var showSheet = SheetViewController.shared
    @StateObject private var eventsManager = RealTimeEventsManager.shared
    @StateObject private var settings = ProfileGenericSettings.shared
    @StateObject private var permissionsManager: PermissionsManager = PermissionsManager.shared
    @StateObject private var dataSourceManager: DataSourceManager = .shared
//    @StateObject private var notificationViewModel: MsNotificationHubViewModel = MsNotificationHubViewModel.shared
    
    @UIApplicationDelegateAdaptor(MirrorHRKit.AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        SCIChartSurface.setRuntimeLicenseKey(RoberdanSecretsPackage.sCICHARTLicenseKey)
        PermissionsManager.shared.personalize(appName: appName,
                                              supportEmail: supportEmail,
                                              permissionsToHandle: [
                                                .notifications(isMandatory: false),
                                                .health(isMandatory: false),
                                                .criticalNotification(isMandatory: false),
                                                .speech(isMandatory: false),
                                                .microphone(isMandatory: false),
                                                .camera(isMandatory: false),
                                                .location(isMandatory: false)
                                              ])
    }
    
    var body: some Scene {
        WindowGroup {
            if isTestMode {
                // MARK: for testing purpose only
                MedicationInputView()
            } else {
                switch onboardingStateMachine.mainAppStatus {
                case .showFullOnboarding:
                    OnboardingWrapperView()
                    .sheet(isPresented: $showSheet.sheetVisible,
                           onDismiss: showSheet.dismissAction,
                           content: {
                        SheetViewContainer {
                            showSheet.sheetContentView
                        }
                    })
                case .showWhatsNew:
                    //                WhatsNewView()
                    OnboardingWrapperView()
                    .sheet(isPresented: $showSheet.sheetVisible,
                           onDismiss: showSheet.dismissAction,
                           content: {
                        SheetViewContainer {
                            showSheet.sheetContentView
                        }
                    })
                case .justRun, .booting :
                    if permissionsManager.canGoAhead {
                        ContentView()
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .environmentObject(tabViewController)
                            .environmentObject(mirrorHR)
                            .environmentObject(showSheet)
                            .environmentObject(deviceOrientation)
                            .environmentObject(communicationManager)
                            .environmentObject(eventsManager)
                            .environmentObject(settings)
                            .environmentObject(MsNotificationHubViewModel.shared)
                            .environmentObject(dataSourceManager)
                            .onOpenURL { url in
                                handleURL(url)
                            }
                    } else {
                        PermissionsManagerView(skippable: true)
                    }
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            handleScenePhases(phase)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var mirrorHR: MirrorHRMainClass
    @EnvironmentObject private var showSheet: SheetViewController
    @EnvironmentObject private var eventsManager: RealTimeEventsManager
    @EnvironmentObject private var settings: ProfileGenericSettings
    @EnvironmentObject private var tabViewController: TabViewController
    @EnvironmentObject private var orientation: DeviceOrientation
    @EnvironmentObject private var dataSourceManager: DataSourceManager
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var confirmationDialog: ConfirmationsDialogManager = .shared
    @ObservedObject var toastManager: ToastManager = .shared
    @State var tabbar: UITabBar?
    
    var body: some View {
        TabView(selection: $tabViewController.tabView) {
            // MARK: Home Tab
            Tab.home.landingView
                .tabItem {
                    Label(Tab.home.title, systemImage: Tab.home.image)
                        .accessibility(label: Text(Tab.home.title))
                }
                .tag(Tab.home.rawValue)
            
            // MARK: realtimemonitor tab
            Tab.realtimeMonitor.landingView
                .tabItem {
                    Label(Tab.realtimeMonitor.title, systemImage: mirrorHR.isRunning ? Tab.realtimeMonitor.image : Tab.realtimeNoWatch.image)
                        .accessibility(label: Text(Tab.realtimeMonitor.title))
                }
                .supportedOrientation(.allButUpsideDown)
                .onChange(of: orientation.orientation) { newOrientation in
                    self.tabbar?.isHidden = newOrientation == .landscape
                }
                .tag(Tab.realtimeMonitor.rawValue)
                .modifier(HandleBlockingActionsModifier(hasToBeDisabled: true))
            
            // MARK: logs tab
            Tab.diary.landingView
                .tabItem {
                    Label(Tab.diary.title, systemImage: Tab.diary.image)
                        .accessibility(label: Text(Tab.diary.title))
                }
                .tag(Tab.diary.rawValue)
                .modifier(HandleBlockingActionsModifier(hasToBeDisabled: true))
            
            // MARK: insights tab
            Tab.insights.landingView
                .tabItem {
                    Label(Tab.insights.title, systemImage: Tab.insights.image)
                        .accessibility(label: Text(Tab.insights.title))
                }.tag(Tab.insights.rawValue)
                .modifier(HandleBlockingActionsModifier(hasToBeDisabled: true))
            
            // MARK: profile tab
            Tab.settings.landingView
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.image)
                        .accessibility(label: Text(Tab.settings.title))
                }.tag(Tab.settings.rawValue)
                .modifier(HandleBlockingActionsModifier(hasToBeDisabled: true))
        }
        .accentColor(.blue)
        .sheet(isPresented: $showSheet.sheetVisible,
               onDismiss: showSheet.dismissAction,
               content: {
            SheetViewContainer {
                showSheet.sheetContentView
            }
            .presentationDetents(showSheet.presentationDetents)
        })
        .alert(isPresented: $eventsManager.showingAlert) {
            eventsManager.alert
        }
        .confirmationDialog(confirmationDialog.title, isPresented: $confirmationDialog.isPresented, actions: {
            confirmationDialog.actions
        }, message: {
            Text(confirmationDialog.message).font(.headline)
        })
        .showToast(isPresented: $toastManager.isPresented) {
            AnyView(toastManager.label)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
            // Devices
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 16 Pro"))
                .previewDisplayName("iPhone 16 Pro")
                .preferredColorScheme(.dark)
    }
}

