//
//  File.swift
//
//
//  Created by Roberto D’Angelo on 12/05/24.
//

import Foundation
import MirrorHRTelemetryPackage
import SwiftUI
import Combine
import SharedPkg
import RoberdanToolBox

struct DataSourcePickerView: View {
    @ObservedObject private var dataSourceManager: DataSourceManager = .shared
    @State private var expandedGroup: DataSourceGroup?
    
    var body: some View {
        VStack {
            ForEach(DataSourceGroup.allCases, id: \.self) { group in
                DataSourceGroupView(group: group, dataSourceManager: dataSourceManager, expandedGroup: $expandedGroup)
            }
        }
    }
}

private extension View {
    func selectionStyle(isSelected: Bool) -> some View {
        self
            .padding()
            .background(isSelected ? darkGradient.opacity(1) : darkGradient.opacity(0.2))
            .cornerRadius(defaultCornerRadius)
    }
    
    func fontWeightStyle(isSelected: Bool) -> some View {
        self
            .fontWeight(isSelected ? .bold : .regular)
    }
}
struct DataSourceItemView: View {
    let source: DataSource
    @ObservedObject var dataSourceManager: DataSourceManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(source.title)
                    .fontWeightStyle(isSelected: dataSourceManager.dataSource == source)
                
                Spacer()
                
                Image(systemName: dataSourceManager.dataSource == source ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(dataSourceManager.dataSource == source ? .green : .secondary)
                    .font(.title2)
            }
            .selectionStyle(isSelected: dataSourceManager.dataSource == source)
            .onTapGesture {
                dispatchDataSourceChange(source)
            }
            
            Text(source.helpMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let errorMsg = source.thereIsAnError {
                dataSourceManager.warningView(warningMessage: errorMsg, showImage: true)
                    .padding(.leading, 5)
            }
        }
    }
}

struct DataSourceGroupView: View {
    let group: DataSourceGroup
    @ObservedObject var dataSourceManager: DataSourceManager
    @Binding var expandedGroup: DataSourceGroup?
    
    var body: some View {
        VStack(alignment: .leading) {
            if group.dataSources.count == 1, let singleSource = group.dataSources.first {
                DataSourceItemView(source: singleSource, dataSourceManager: dataSourceManager)
            } else {
                let isGroupSelected = group.dataSources.contains { $0 == dataSourceManager.dataSource }
                
                HStack {
                    Text(group.title)
                        .fontWeightStyle(isSelected: isGroupSelected)
                    
                    Spacer()
                    
                    Image(systemName: expandedGroup == group ? "chevron.down" : "chevron.right")
                        .onTapGesture {
                            expandedGroup = (expandedGroup == group) ? nil : group
                        }
                }
                .selectionStyle(isSelected: isGroupSelected)
                .onTapGesture {
                    expandedGroup = (expandedGroup == group) ? nil : group
                }
                
                if expandedGroup == group {
                    ForEach(group.dataSources, id: \.self) { source in
                        DataSourceItemView(source: source, dataSourceManager: dataSourceManager)
                    }
                }
            }
        }
    }
}

enum DataSourceGroup: CaseIterable, Identifiable {
    case pairedWithAppleWatch
    case diaryOnly
    case streamingViaInternet
    case receivingFromInternet
    
    var id: String {
        switch self {
        case .diaryOnly: return "diaryOnly"
        case .pairedWithAppleWatch: return "pairedWithAppleWatch"
        case .receivingFromInternet: return "receivingFromInternet"
        case .streamingViaInternet: return "streamingViaInternet"
        }
    }
    
    var title: String {
        switch self {
        case .diaryOnly: return DataSource.diaryOnly.title
        case .pairedWithAppleWatch: return DataSource.appleWatchPairedOnly.title
        case .receivingFromInternet: return DataSource.internetStreamingAsClientForKeyEventsAndBPMs.title
        case .streamingViaInternet: return DataSource.appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer.title
        }
    }
    
    var dataSources: [DataSource] {
        switch self {
        case .diaryOnly: return [.diaryOnly]
        case .pairedWithAppleWatch: return [.appleWatchPairedOnly]
        case .receivingFromInternet: return [.internetStreamingAsClientForKeyEventsOnly, .internetStreamingAsClientForKeyEventsAndBPMs]
        case .streamingViaInternet: return [.appleWatchAndInternetKeyEventsStreamingAsServer, .appleWatchAndInternetKeyEventsAndBPMsStreamingAsServer]
        }
    }
    
    var warningMessage: String? {
        for dataSource in dataSources {
            if let errorMsg = dataSource.thereIsAnError {
                return errorMsg
            }
        }
        return nil
    }
}
