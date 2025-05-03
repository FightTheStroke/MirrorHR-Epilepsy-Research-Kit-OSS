//
//  ModernView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 11/06/24.
//  Copyright © 2024 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import RoberdanToolBox
struct ContentView3: View {
    var body: some View {
        ZStack {
            // Background color
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Top profile section
                HStack {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    VStack(alignment: .leading) {
                        Text("Peter McCullough")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Switch profiles")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                }
                .padding()
                .adaptiveOverlay(lightCornerRadius: 10, darkCornerRadius: 10)
                
                Spacer()
                
                // Main content section
                VStack(alignment: .leading) {
                    Text("A BOT-anist Adventure")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("An awe-inspiring tale of a beloved robot, on a journey to save extraordinary vegetation from extinction. Uncover the mysteries of plant life inhabiting an alien planet.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 5)
                    
                    Spacer()
                    
                    // Play button
                    HStack {
                        Spacer()
                        Button(action: {
                            // Action for the play button
                        }) {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding()
                }
                .padding()
                .adaptiveOverlay(lightCornerRadius: 20, darkCornerRadius: 20)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct ContentView3_Previews: PreviewProvider {
    static var previews: some View {
        ContentView3()
    }
}
