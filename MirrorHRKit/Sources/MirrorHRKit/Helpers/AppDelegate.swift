//
//  AppDelegate.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 04/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import UIKit
import SharedPkg
import BackgroundTasks
import MetricKit
import os

public class AppDelegate: NSObject, UIApplicationDelegate, MXMetricManagerSubscriber {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    let logger = Logger(subsystem: "AppDelegate", category: "FYI")
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        UIDevice.current.isBatteryMonitoringEnabled = true
        UIApplication.shared.isIdleTimerDisabled = true
        UIApplication.shared.registerForRemoteNotifications()
        let _: CheckiPhoneBatteryTimer = .shared
        
        // MetricKit
        let metricManager = MXMetricManager.shared
        metricManager.add(self)
        
        // Registering background tasks
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.mirror-labs.Epilepsy-Research-Kit.cleanUpBackGroundTask", using: nil) { task in
            self.handleAppCleanUp(task: task as! BGAppRefreshTask)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillTerminate(notification:)),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(brightnessDidChange),
                                               name: UIScreen.brightnessDidChangeNotification,
                                               object: nil)
        return true
    }
    
    @objc func brightnessDidChange() {
        ProfileGenericSettings.shared.brightness = UIScreen.main.brightness
    }
    
    public func application(_ application: UIApplication,
                            supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        mainDebugger.append("Failed to register for remote notifications: \(error.localizedDescription)", .error)
    }
    
    public func applicationWillResignActive(_ application: UIApplication) {
        logger.log(level: .info, "applicationWillResignActive")
    }
    
    @objc private func applicationWillTerminate(notification: Notification) {
        if MirrorHRMainClass.shared.isRunning {
            NotificationManager.shared.fireNotification(event: .termination, overrideLastFiredDelay: true)
        }
        scheduleAppRefresh()
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.mirror-labs.Epilepsy-Research-Kit.cleanUpBackGroundTask")
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.error("Could not run clean up: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Handling Cleanup
    func handleAppCleanUp(task: BGAppRefreshTask) {
        if MirrorHRMainClass.shared.isRunning {
            NotificationManager.shared.removePendingNoDataCheckNotifications()
            DispatchQueue.main.async {
                MirrorHRMainClass.shared.status = .stopped(source: .iPhone)
            }
            mainDebugger.append("MirrorHR has been terminated by the user", .error, sourceModule: "handleAppCleanUp")
        }
        task.setTaskCompleted(success: true)
    }
    
    // MARK: - Handling Notifications
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        logger.log(level: .info, "Received remote notification")
        
        // Handle the remote notification
        MsNotificationHubViewModel.shared.handleRemoteNotification(userInfo: userInfo)
        
        // Ensure you perform any necessary background fetch/update
        completionHandler(.newData)
        
        // Schedule a background task if needed
        scheduleAppRefresh()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIScreen.brightnessDidChangeNotification, object: nil)
    }
}
