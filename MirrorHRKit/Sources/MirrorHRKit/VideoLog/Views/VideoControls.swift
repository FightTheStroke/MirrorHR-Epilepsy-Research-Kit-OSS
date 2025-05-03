//
//  VideoControls.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 12/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import RoberdanToolBox

struct VideoControlButtonsView: View {
    let videoPicker: VideoPicker
    @ObservedObject var localTimer: LocalTimer = LocalTimer()
    
    var body: some View {
        VStack {
            // video recording Lenght header
            Text(localTimer.duration.toMMssStringWatch())
                .font(.body.bold())
                .padding(.horizontal)
                .background(Color.red).clipShape(RoundedRectangle(cornerRadius: 5))
                .padding(5)
            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    localTimer.stop()
                    videoPicker.stopCapture()
                }, label: {
                    Image(systemName: "stop.circle.fill").foregroundColor(.red)
                        .font(.system(size: 72.0))
                        .padding(35)
                })
                Spacer()
            }
        }
        .onAppear {
            videoPicker.startCapture { started in
                if started {
                    localTimer.start()
                }
            }
        }
    }
}

class LocalTimer: ObservableObject {
    @Published var duration: TimeInterval = 0
    private var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            DispatchQueue.main.async {
                self.duration += 1
            }
        })
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    deinit {
        timer?.invalidate()
    }
}
