//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 25/12/21.
//

import Foundation
import SwiftUI

struct MoreHealthDataByDateHeaderView: View {
    @ObservedObject var hrv: ReadHealthData = ReadHealthData(.hrv)
    @ObservedObject var oxygen: ReadHealthData = ReadHealthData(.oxygen)
    @ObservedObject var respiratoryRate: ReadHealthData = ReadHealthData(.respiratoryRate)
    var allHealthData: [ReadHealthData] = []
    
    init(dateHeader: String) {
        let date: Date = Date.fromTimeLineDateHeader2Date(dateHeader: dateHeader)
        hrv.readMinMax(for: date)
        oxygen.readMinMax(for: date)
        respiratoryRate.readMinMax(for: date)
        allHealthData = [hrv, oxygen, respiratoryRate]
    }
    
    var body: some View {
        ForEach(allHealthData) { data in
            if data.minMaxReadyString != nil {
                HStack {
                    Text(data.healthQuantity.label + ":")
                        .font(.body.bold()).foregroundColor(.accentColor)
                    Text(data.minMaxReadyString!)
                }
            }
        }
    }
}
