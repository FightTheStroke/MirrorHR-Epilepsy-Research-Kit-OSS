//
//  NoWatchHandling.swift
//
//
//  Created by Roberto D’Angelo on 31/07/22.
//

import Foundation
import RoberdanToolBox
import SharedPkg
import SwiftUI
import MirrorHRTelemetryPackage

struct RealTimeNoWatchView: View {
    @State var showStreamingClientConfirmation: Bool = false
    
    var body: some View {
        VStack {
            Text("YouMustHaveWatchOrStreamingMain".local())
                .font(.title)
            
            if isAppleWatchPaired() {
                Button {
                    dispatchDataSourceChange(.appleWatchPairedOnly)
                } label: {
                    HStack {
                        appleWatchWavesImage
                        Text(iHaveAWatchNowString)
                    }
                }
                .buttonStyle(IHaveWatchButtonStyle())
            }
            
            Divider()
                
            Text("\n \("RemoteStreamingOptionsSettingsMsg".local())")
                .font(.title)
        }
        .multilineTextAlignment(.center)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .padding()
    }
}

struct IHaveWatchButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.green)
            .foregroundColor(.primary)
            .clipShape(Capsule())
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .fixedSize(horizontal: false, vertical: true)
    }
}
