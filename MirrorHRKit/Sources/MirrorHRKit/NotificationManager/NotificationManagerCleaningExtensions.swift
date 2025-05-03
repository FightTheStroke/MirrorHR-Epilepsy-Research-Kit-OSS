//
//  NotificationManagerCleaningExtensions.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 17/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import UserNotifications
import SharedPkg

extension NotificationManager {
    func eraseAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications() // For removing all delivered notification
        notificationCenter.removeAllPendingNotificationRequests()
        // For removing all pending notifications which are not delivered yet but scheduled.
    }

    func removePendingRequestWithIdentifier(_ identifier: String, completion: @escaping (_ done: Bool) -> Void) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        completion(true)
    }
}
