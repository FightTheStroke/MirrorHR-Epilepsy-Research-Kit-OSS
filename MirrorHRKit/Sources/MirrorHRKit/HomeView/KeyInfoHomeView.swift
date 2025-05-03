//
//  KeyInfoHomeView.swift
//
//
//  Created by Roberto D’Angelo on 24/09/23.
//

import Foundation
import SwiftUI
import SharedPkg

struct KeyInfoHomeView: View {
    @ObservedObject var profile: ProfileGenericSettings = .shared
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack  {
                HStack {
                    Text("kidAgeString".local())
                    Text(profile.kidAge)
                        .fontWeight(.bold)
                    Text("  ")
                    Text("kidWeightString".local())
                    Text(String(format: "%.2f", profile.kidWeight) + profile.measurementsUnit.weightUnit)
                        .fontWeight(.bold)
                }
                Spacer()
                NavigationLink {
                    AllUpPersonalInfoView(isOnboarding: false)
                        .modifier(MyRadialViewModifier(isList: false))
                        .navigationTitle("InformazioniPersonaliHeader".local())
                } label: {
                    Image(systemName: "figure.child.circle")
                }
            }
        }
    }
}
