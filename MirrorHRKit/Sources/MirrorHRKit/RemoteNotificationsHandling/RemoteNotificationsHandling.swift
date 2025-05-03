//
//  RemoteNotificationsHandling.swift
//
//
//  Created by Roberto D’Angelo on 20/05/24.
//

import Foundation
import SwiftUI
import SharedPkg
import MirrorHRTelemetryPackage

struct RemoteMessageView: View {
    let notificationSupportStruct: NotificationSupportStruct
    let showSheet: SheetViewController
    let symptomEvent: HandledSymptomsEvents
    let symptomsManager: SymptomsManager
    
    init(notificationSupportStruct: NotificationSupportStruct, symptomEvent: HandledSymptomsEvents, dataSourceManager: DataSourceManager = .shared, symptomsManager: SymptomsManager = .shared, showSheet: SheetViewController = .shared) {
        self.notificationSupportStruct = notificationSupportStruct
        self.symptomEvent = symptomEvent
        self.symptomsManager = symptomsManager
        self.showSheet = showSheet
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(notificationSupportStruct.title)
                .font(.title2)
                .padding(.bottom)
            Text(symptomEvent.localizedString())
                .font(.headline)
            Text(notificationSupportStruct.startDate)
            Text(notificationSupportStruct.endDate)
                .padding(.bottom)
            Text(notificationSupportStruct.notes)
                .font(.body)
            if let latitude = notificationSupportStruct.latitude, 
                let longitude = notificationSupportStruct.longitude,
                let latitudeCoord = LocationManager.stringToCoordinate(latitude),
                let longCoord = LocationManager.stringToCoordinate(longitude) {
                HStack {
                    Image(systemName: "location.circle")
                    Text("\(latitude):\(longitude)")
                }
                .foregroundColor(.accentColor)
                .onTapGesture {
                    openInMaps(latitude: latitudeCoord, longitude: longCoord)
                }
            }
            Spacer()
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

