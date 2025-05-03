//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 24/09/23.
//

import Foundation
import SwiftUI
import SharedPkg

struct TherapyHomeView: View {
    @ObservedObject var therapyManager: TherapyManager = .shared
    
    var body: some View {
        let currentTherapy: Therapy? = TherapyManager.shared.currentTherapy
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("currentTherapyTitleText".local())
                        .font(.title2).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    Text(currentTherapy?.validityDateInterval ?? "")
                }
                Spacer()
                NavigationLink {
                    TherapyHomeDrillDownView()
                        .modifier(MyRadialViewModifier(isList: true))

                } label: {
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(Color.accentColor)
            }
            
            if let currentTherapy = currentTherapy {
                ForEach(Array(currentTherapy.cocktailList.enumerated()), id: \.element) { index, cocktail in
                    HStack(alignment: .top) {
                        Image(systemName: String(index + 1) + ".circle")
                        RowCocktailView(cocktail: cocktail)
                    }
                }
            } else {
                Text("TherapiesNotSet".local())
            }
        }
    }
}

struct TherapyHomeDrillDownView: View {
    @ObservedObject var therapyManager: TherapyManager = .shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            ForEach(therapyManager.therapies, id: \.id) { therapy in
                RowTherapyView(therapy: therapy)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    therapyManager.deleteTherapy(therapyManager.therapies[index])
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                EditButton()

            }
            ToolbarItem(placement: .automatic) {
                NavigationLink(destination: InsertUpdateTherapyView(navigationTitle: newTherapyString, backBtnTitle: navigationBackDefaultText), label: {
                    Image(systemName: "plus.circle").foregroundColor(.accentColor)
                        .modifier(MyRadialViewModifier(isList: true))

                })
                .isDetailLink(false)
            }
        }
        .navigationTitle(therapiesNavTitle)
        .alert(isPresented: $therapyManager.showYesNoAlert) {
            Alert(
                title: Text(confirmString),
                message: Text(therapyManager.alertYesNoMsg),
                primaryButton: .default(Text(yesString), action: therapyManager.alertYesAction),
                secondaryButton: .destructive(Text(noString), action: therapyManager.alertNoAction)
            )
        }
    }
}
