//
//  AzureNotificationHub.swift
//  
//
//  Created by Roberto D’Angelo on 13/05/23.
//

/* Payload Sample
{
    "aps": {
        "alert": {
            "title": "MirrorHR Alarm",
            "body": "Un allarme è scattato sul MirrorHR di Mario"
        },
        "sound": {
            "critical": 1,
            "name": "default",
            "volume": 1.0
        },
        "category": "CRITICAL_ALERT"
    },
    "customKey": "customValue",
    "timeStamp": "dd-MM-yyyy HH:mm:ss",
    "symptom": "sympt_seizure"
}
*/

import Foundation
import WindowsAzureMessaging
import UIKit
import SharedPkg
import SwiftUI
import MirrorHRTelemetryPackage

class ObservableMessagesList: ObservableObject {
    static var shared: ObservableMessagesList = ObservableMessagesList(items: [])
    @Published var items = [MSNotificationHubMessage]()
    
    init(items: [MSNotificationHubMessage]) {
        self.items = items
    }
}

class ObservableInstallation: ObservableObject {
    @Published var installationId: String
    @Published var pushChannel: String
    
    init(installationId: String, pushChannel: String) {
        self.installationId = installationId
        self.pushChannel = pushChannel
    }
}

struct PushNotificationsContentView: View {
    @State private var selection = 0
    @ObservedObject var notifications: ObservableMessagesList = ObservableMessagesList.shared
    @ObservedObject var installation: ObservableInstallation = ObservableInstallation(installationId: MSNotificationHub.getInstallationId(), pushChannel: MSNotificationHub.getPushChannel())
    
    var body: some View {
        TabView(selection: $selection) {
            SetupView(installation: installation)
                .tabItem {
                    VStack {
                        Image(systemName: "wrench.fill")
                        Text("Setup")
                    }
                }
                .tag(0)
            NotificationsList(notifications: notifications)
                .tabItem {
                    VStack {
                        Image(systemName: "tray.fill")
                        Text("Notifications")
                    }
                }
                .tag(1)
        }
    }
}

struct SetupView: View {
    @State var tag: String = ""
    @State var tags: [String] = MSNotificationHub.getTags()
    @ObservedObject var installation: ObservableInstallation
    @State var userId: String = MSNotificationHub.getUserId()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Device Token:")
                .font(.headline)
                .padding(.leading)
            Text(installation.pushChannel)
                .font(.caption)
                .foregroundColor(Color.gray)
                .padding([.leading, .bottom, .trailing])
            
            Text("Installation ID:")
                .font(.headline)
                .padding(.leading)
            Text(installation.installationId)
                .font(.caption)
                .foregroundColor(Color.gray)
                .padding([.leading, .bottom, .trailing])
            
            Text("User ID:")
                .font(.headline)
                .padding(.leading)
            TextField("Set User ID", text: $userId, onEditingChanged: {focus in
                if(!focus) {
                    MSNotificationHub.setUserId(self.userId)
                }
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .bottom, .trailing])
            
            Text("Tags:")
                .font(.headline)
                .padding(.leading)
            TextField("Add new tag", text: $tag, onCommit: {
                if(self.tag != "") {
                    MSNotificationHub.addTag(self.tag)
                    self.tags.append(self.tag)
                    self.tag = ""
                }
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .bottom, .trailing])
            
            TagsList(tags: tags, onDelete: {
                $0.forEach({
                    MSNotificationHub.removeTag(self.tags.remove(at: $0))
                })
            })
            
            Spacer()
        }
    }
}

struct NotificationsList: View {
    @ObservedObject var notifications: ObservableMessagesList
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notifications.items, id: \.self) { notification in
                    NavigationLink(destination: NotificationView(notification: notification)) {
                        Row(title: notification.title ?? notification.body ?? "row")
                            .modifier(MyRadialViewModifier(isList: true))

                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitle(Text("Notifications"))
        }
    }
}

struct TagsList: View {
    var tags: [String]
    var onDelete: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(tags, id: \.self) {
                Row(title: $0)
            }
            .onDelete(perform: {
                self.onDelete($0)
            })
        }
    }
}

struct NotificationView: View {
    var notification: MSNotificationHubMessage
    
    var body: some View {
        VStack {
            HStack {
                Text(notification.body ?? "<Body is missing>")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                    .padding([.leading, .bottom, .trailing])
                Spacer()
            }
            
            Spacer()
        }
        .navigationBarTitle(Text(notification.title ?? "<Title is missing>").font(.headline))
    }
}

struct Row: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
            .foregroundColor(Color.gray)
            Spacer()
        }
    }
}
