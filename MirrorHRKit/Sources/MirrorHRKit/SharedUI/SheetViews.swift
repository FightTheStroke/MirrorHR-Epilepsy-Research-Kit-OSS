//
//  SheetViews.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 25/09/2020.
//

import Foundation
import SharedPkg
import SwiftUI

// MARK: Main Sheet view Container for main content

public struct SheetViewContainer<Content: View>: View {
    @ObservedObject var showSheet = SheetViewController.shared

    let content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        NavigationView {
            content()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(!showSheet.showNavTabBarTitle)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        SheetViewHeader()
                            .foregroundColor(.accentColor)
                    }

                    ToolbarItem(placement: .cancellationAction) {
                        if showSheet.hasCancelButton {
                            Button(action:
                                showSheet.cancelAction ?? SheetViewController.defaultCancelAction,
                                label: {
                                    HStack {
                                        if showSheet.cancelActionImage != "" {
                                            Image(systemName: showSheet.cancelActionImage)
                                        }
                                        Text(showSheet.cancelActionText)
                                    }
                                    .font(.body)
                                    .foregroundColor(.accentColor)
                                })
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        if showSheet.hasOkButton {
                            Button(action:
                                showSheet.okAction ?? SheetViewController.defaultOkAction,
                                label: {
                                    HStack {
                                        if showSheet.okActionImage != "" {
                                            Image(systemName: showSheet.okActionImage)
                                        }
                                        Text(showSheet.okActionText)
                                    }
                                    .font(.body)
                                })
                            .foregroundColor(.accentColor)
                        }
                    }
                }
                .navigationTitle(showSheet.navigationTitle)
                .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct SheetViewHeader: View {
    init() {}

    var body: some View {
        RoundedRectangle(cornerRadius: defaultViewCornerRadius)
            .frame(width: 60, height: 5)
            .foregroundColor(.secondary)
    }
}

struct CenteredSheetViewHeader: View {
    init() {}
    
    var body: some View {
        HStack {
            Spacer()
            SheetViewHeader()
            Spacer()
        }
    }
}
