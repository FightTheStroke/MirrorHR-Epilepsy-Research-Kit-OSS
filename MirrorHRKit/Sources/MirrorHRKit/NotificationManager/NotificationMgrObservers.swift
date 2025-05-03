//
//  NotificationMgrObservers.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 17/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Combine
import Foundation
import RoberdanToolBox
import SwiftUI
import UserNotifications

extension NotificationManager {
    func addObserver(_ observer: UNUserNotificationCenterDelegate) {
        observers.append(observer)
    }

    func removeObserver(_ observer: UNUserNotificationCenterDelegate) {
        observers.removeAll { $0 === observer }
    }
}
