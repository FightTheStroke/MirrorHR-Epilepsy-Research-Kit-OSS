/// SwiftUI views for managing and displaying permission states.
///
/// This file contains the main views used to present permission status
/// and handle permission requests in a user-friendly way.

import Foundation
import SwiftUI

/// Main view for managing permissions in the application.
///
/// This view displays the current status of all permissions and provides
/// controls for requesting permissions that haven't been granted yet.
/// It can optionally allow users to skip permission requests if they're
/// not mandatory.
///
/// Example Usage:
/// ```swift
/// PermissionsManagerView(skippable: true)
///     .padding()
/// ```
public struct PermissionsManagerView: View {
    /// The shared permissions manager instance
    @ObservedObject private var permissionsManager: PermissionsManager
    
    /// Whether users can skip permission requests
    @State private var skippable: Bool
    
    /// Creates a new permissions manager view.
    ///
    /// - Parameter skippable: Whether users can skip permission requests
    public init(skippable: Bool) {
        permissionsManager = .shared
        self.skippable = skippable
    }
    
    public var body: some View {
        if permissionsManager.standBy {
            Text("Permissions Manager has not been personalized yet!")
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text("AuthCheckPointTitle".localized())
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        if skippable {
                            Button {
                                permissionsManager.skipped = true
                            } label: {
                                Text("SkipMsgText".localized())
                            }
                            .buttonStyle(.bordered)
                            .disabled(!permissionsManager.allMandatoryGranted)
                        }
                    }
                    
                    Text("SomeMissingAuthNeeded".localized() + " \(permissionsManager.supportEmail)")
                    
                    Divider()
                    ForEach(permissionsManager.permissionsStatus) { permissionStatus in
                        VStack(alignment: .leading) {
                            PermissionsManagerHeaderView(permissionStatus: permissionStatus)
                            PermissionsManagerBodyView(permissionStatus: permissionStatus)
                        }
                    }
                    .refreshable {
                        permissionsManager.refresh()
                    }
                }
                .multilineTextAlignment(.leading)
                .padding()
            }
        }
    }
}

struct PermissionsManagerView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsManagerView(skippable: true)
    }
}

/// Header view for displaying a single permission's status.
///
/// This view shows the permission name, icon, and current status.
/// For permissions that haven't been determined yet, it provides
/// a button to request authorization.
public struct PermissionsManagerHeaderView: View {
    /// The permission status to display
    private var permissionStatus: PermissionStatus
    
    /// The shared permissions manager instance
    @ObservedObject private var permissionsManager: PermissionsManager = .shared

    /// Creates a new permission header view.
    ///
    /// - Parameter permissionStatus: The permission status to display
    public init(permissionStatus: PermissionStatus) {
        self.permissionStatus = permissionStatus
    }
    
    public var body: some View {
        HStack {
            Label(permissionStatus.permission.identifier.name, systemImage: permissionStatus.permission.icons.mainIcon)
            Spacer()
            
            let status = permissionStatus.status

            HStack {
                switch status {
                case .notDetermined:
                    Button {
                        permissionStatus.permission.requestAuthorization { status in
                            // no action required as it's all handled via events
                        }
                    } label: {
                        Label("GrantItBtnLabel".localized(), systemImage: "hand.thumbsup")
                    }
                    .buttonStyle(.bordered)
                default:
                    Image(systemName: status.icon)
                }
            }
            .foregroundStyle(status.color)
        }
        .font(.headline)
    }
}

/// Body view for displaying additional permission information.
///
/// This view shows details about the permission, including whether
/// it's mandatory and any relevant messages based on its current status.
public struct PermissionsManagerBodyView: View {
    /// The permission status to display details for
    private var permissionStatus: PermissionStatus
    
    /// The shared permissions manager instance
    @ObservedObject private var permissionsManager: PermissionsManager = .shared

    /// Creates a new permission body view.
    ///
    /// - Parameter permissionStatus: The permission status to display details for
    public init(permissionStatus: PermissionStatus) {
        self.permissionStatus = permissionStatus
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if permissionStatus.permission.identifier.isMandatory {
                Text("MandatoryMsg".localized())
                    .fontWeight(.heavy)
            }
            switch permissionStatus.status {
            case .authorized:
                // Text(permissionStatus.permission.messages.okMessage)
                EmptyView()
            case .notDetermined:
                Text(permissionStatus.permission.messages.description)
            case .denied:
                Text(permissionStatus.permission.messages.noOkMessage + "\n" + permissionStatus.permission.messages.recoveryMsg)
            case .custom, .unknown, .notAvailable, .error:
                Text(permissionStatus.status.localizedDescription)
            }
        }
    }
}

/// View for checking a specific permission's status.
///
/// This view provides a compact way to display and manage a single
/// permission type, useful when you don't need the full permissions view.
///
/// Example Usage:
/// ```swift
/// PermissionsManagerCheckView(permissionType: .camera)
///     .padding()
/// ```
public struct PermissionsManagerCheckView: View {
    /// The shared permissions manager instance
    @ObservedObject private var permissionsManager: PermissionsManager = .shared

    /// The permission status to check
    private var permissionStatus: PermissionStatus?
    
    /// Creates a new permission check view.
    ///
    /// - Parameter permissionType: The type of permission to check
    public init(permissionType: PermissionsManager.PermissionType) {
        self.permissionStatus = permissionsManager.permissionType2PermissionStatus(permissionType)
    }
    
    public var body: some View {
        if let permissionStatus = permissionStatus {
            PermissionsManagerHeaderView(permissionStatus: permissionStatus)
        } else {
            Text("PermissionsManager error: this type does not exist")
                .foregroundColor(.red)
        }
    }
}
