//
//  MedicationManagerViews.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 02/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import RoberdanToolBox
import SwiftUI
import UserNotifications
import SharedPkg

public struct MedicationManagerView: View {
    @ObservedObject var medicationManager = MedicationManager.shared
    @State private var showConfirmDelete = false
    var showHeader: Bool
    var showTitle: Bool = true
    
    func cancelDeleteAction() {
        showConfirmDelete = false
    }
    
    public init(showHeader: Bool, showTitle: Bool = true) {
        self.showHeader = showHeader
        self.showTitle = showTitle
    }
    
    public var body: some View {
        ScrollView {
            if showHeader {
                MedicationViewHeader()
            } else if showTitle {
                Text(medicationAlarmViewTitle)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.title2)
                    .padding()
            }
            
            MedicationReminderPicker(
                wakeUp: $medicationManager.wakeUp,
                recurrence: $medicationManager.recurrence
            )
            
            RemindersWeekDayListView(showEditBtn: true)
            if !showHeader {
                HStack {
                    Spacer()
                    Button {
                        showConfirmDelete = true
                    } label: {
                        Text(deleteAllRemindersString).font(.body.bold()).foregroundColor(.red).padding()
                    }
                    Spacer()
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .alert(confirmString, isPresented: $showConfirmDelete, actions: {
            Button(role: .destructive) {
                MedicationManager.shared.deleteAll()
            } label: {
                Text(yesString)
            }
        }, message: {
            Text(confirmDeleteMedicationRemindersMsg)
        })
    }
}

public struct MedicationViewHeader: View {
    var medicationManager = MedicationManager.shared
    
    public var body: some View {
        HStack {
            Spacer()
            Button {
                medicationManager.scheduleMedicationReminder()
            } label: {
                HStack {
                    Image(systemName: "plus.circle")
                    Text(addButtonString)
                }
            }
        }
        .font(.body.bold())
        .padding()
    }
}

public struct RemindersWeekDayListView: View {
    @ObservedObject var medicationManager = MedicationManager.shared
    var showEditBtn: Bool
    
    public init(showEditBtn: Bool) {
        self.showEditBtn = showEditBtn
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            ForEach(medicationManager.weekDaysReminderList(.wholeWeek), id: \.id,
                    content: { reminderTime in
                HStack {
                    Text("\(reminderTime.weekDay)")
                    Spacer()
                    Text("\(reminderTime.hour):\(reminderTime.minute)")
                    if showEditBtn {
                        Button(action: {
                            medicationManager.deleteNotificationRequest(reminderTime.notificationRequest)
                        }, label: {
                            Image(systemName: "minus.circle.fill").foregroundColor(.red)
                        })
                    }
                }
                .font(.headline)
            })
        }
    }
}
