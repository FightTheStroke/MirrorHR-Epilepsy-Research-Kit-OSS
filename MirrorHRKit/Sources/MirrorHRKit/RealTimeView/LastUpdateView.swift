//
//  LastUpdateView.swift
//  
//
//  Created by Roberto D’Angelo on 31/07/22.
//

import Foundation
import RoberdanToolBox
import SwiftUI
import SharedPkg

struct LastUpdateWas: View {
    @ObservedObject var lastBPM = FreshBPM.shared
    @ObservedObject var currentTime = MainTimer.shared
    @ObservedObject var kissFlowManager = KISSFlowManager.shared
    @ObservedObject private var keyFlowThresholds = KeyFlowThresholds.shared
    @ObservedObject private var dataSourceManager: DataSourceManager = .shared
    
    var body: some View {
        let delta = Int(currentTime.now - kissFlowManager.lastBPMAnalyzedAt)
        HStack {
            if delta < keyFlowThresholds.maxIntervalWithoutData {
                Text("\((currentTime.now - kissFlowManager.lastBPMAnalyzedAt).toSmartHHMMssString())")
                    .foregroundColor(delta < lastUpdateWarningDeltaSecs ? .primary : FlowStages.warning.chartColor.color)
            } else {
                Text("\((currentTime.now - kissFlowManager.lastBPMAnalyzedAt).toSmartHHMMssString())")
                    .foregroundColor(.white)
                    .onAppear {
                        // it's internet streaming scenario
                        if dataSourceManager.dataSource.isReceivingBPMsViaInternetStreaming, kissFlowManager.currentStage != .noInternetStreamData {
                            kissFlowManager.currentStage = .noInternetStreamData
                            dispatchMainEvent(.noStreamingData(metaData: .init(name: "NODATAFOR", valueInt: delta)), "LastUpdateWas View")
                            return
                        }
                        // it's local watch paired, not streaming
                        if kissFlowManager.currentStage != .noLocalData {
                            kissFlowManager.currentStage = .noLocalData
                            dispatchMainEvent(.noLocalData(metaData: .init(name: "NODATAFOR", valueInt: delta)), "LastUpdateWas View")
                            return
                        }
                    }
            }
        }
        .background(kissFlowManager.currentStage == .noLocalData || kissFlowManager.currentStage == .noInternetStreamData ? Color.red : Color.clear)
        .font(.body.bold())
    }
}
