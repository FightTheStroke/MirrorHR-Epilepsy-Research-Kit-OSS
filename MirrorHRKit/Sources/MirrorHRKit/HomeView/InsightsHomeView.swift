//
//  InsightsHomeView.swift
//
//
//  Created by Roberto D’Angelo on 24/09/23.
//

import Foundation
import SwiftUI
import SharedPkg

struct InsightsHomeView: View {
    @ObservedObject var symptomsManager = SymptomsManager.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                SinceLastSeizureView()
                
                Spacer()
                
                NavigationLink {
                    SeizuresHomeView()
                        .navigationTitle(seizuresOnlyFilterMsg)
                        .navigationBarTitleDisplayMode(.large)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(Color.accentColor)
            }
        }
        .font(.body)
    }
}

struct SinceLastSeizureView: View {
    @ObservedObject var symptomsManager = SymptomsManager.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            if symptomsManager.seizuresCount() > 0 {
                Text(symptomsManager.sinceLastSeizureString().lastDateOnly).font(.title2).bold()
                Text(symptomsManager.sinceLastSeizureString().sinceLastSeizure)
            } else {
                EmptyView()
            }
        }
        .multilineTextAlignment(.leading)
    }
}
