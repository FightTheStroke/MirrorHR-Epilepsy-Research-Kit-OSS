//
//  MedicationManagerDays.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 16/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI

public struct MedicationReminderPicker: View {
    @Binding var wakeUp: Date
    @Binding var recurrence: MedicationManager.Recurrence

    public var body: some View {
        VStack {
            Picker("weekDay", selection: $recurrence) {
                ForEach(MedicationManager.Recurrence.oldReminderPicker, id: \.self) {
                    Text($0.title)
                }
            }
                .pickerStyle(SegmentedPickerStyle())
                .labelsHidden()
                .clipped()
            DatePicker("Please enter a date", selection: $wakeUp, displayedComponents: [.hourAndMinute])
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
                .clipped()
        }
    }
}
