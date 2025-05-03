/// Sample views demonstrating the PermissionsManager functionality.
///
/// This file contains a collection of views that showcase different aspects
/// of the PermissionsManager framework, useful for testing and demonstration
/// purposes.

import SwiftUI

/// Main sample view demonstrating various permission management features.
///
/// This view provides a comprehensive demonstration of the PermissionsManager's
/// capabilities, including permission status display, requesting permissions,
/// and handling different authorization states.
///
/// Example Usage:
/// ```swift
/// PermissionsManagerSampleView()
///     .padding()
/// ```
public struct PermissionsManagerSampleView: View {
    /// The shared permissions manager instance
    let permissionsManager: PermissionsManager = .shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Permissions Manager")
                    .font(.title2)
                    .fontWeight(.heavy)
                
                CheckAllGrantedView()
                
                ListNotCheckedPermissions()
                
                ListAllGrantedPermissions()
                
                ListAllDeniedPermissions()
                
                AskPermissionsView(permissionsManager: permissionsManager)
                
                CompletionPermissionsCheckView(permissionsManager: permissionsManager)
                
                AsyncPermissionsManagerView(permissionsManager: permissionsManager)
                
            }
            .padding()
            .multilineTextAlignment(.leading)
        }
    }
}

/// View that displays all permissions that have been granted.
///
/// This view provides a list of all permissions that the user has
/// explicitly granted, with appropriate icons and styling.
struct ListAllGrantedPermissions: View {
    /// The shared permissions manager instance
    @ObservedObject var permissionManager: PermissionsManager = .shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Granted Permissions")
                .font(.title2)
            ForEach(permissionManager.grantedPermissions, id: \.identifier.id) { permission in
                Label(permission.identifier.name, systemImage: permission.icons.mainIcon)
                    .foregroundColor(.green)
            }
            Divider()
        }
    }
}

/// View that displays all permissions that have been denied.
///
/// This view provides a list of all permissions that the user has
/// explicitly denied, with appropriate icons and styling.
struct ListAllDeniedPermissions: View {
    /// The shared permissions manager instance
    @ObservedObject var permissionManager: PermissionsManager = .shared

    var body: some View {
        VStack(alignment: .leading) {
            Text("Denied Permissions")
                .font(.title2)
            ForEach(permissionManager.deniedPermissions, id: \.identifier.id) { permission in
                Label(permission.identifier.name, systemImage: permission.icons.deniedIcon)
                    .foregroundColor(.red)
            }
            Divider()
        }
    }
}

/// View that displays permissions that haven't been checked yet.
///
/// This view provides a list of permissions that haven't been requested
/// from the user yet, with buttons to initiate the permission request.
struct ListNotCheckedPermissions: View {
    /// The shared permissions manager instance
    @ObservedObject var permissionManager: PermissionsManager = .shared

    var body: some View {
        VStack(alignment: .leading) {
            Text("Not checked yet permissions")
                .font(.title2)
            ForEach(permissionManager.notCheckedYetPermissions, id: \.identifier.id) { permission in
                Button {
                    permission.requestAuthorization { status in
                    }
                } label: {
                    Label(permission.identifier.name, systemImage: permission.icons.mainIcon)
                }
            }
            Divider()
        }
    }
}

/// View that shows whether all permissions have been granted.
///
/// This view provides a simple indicator of whether all required
/// permissions have been granted by the user.
struct CheckAllGrantedView: View {
    /// The shared permissions manager instance
    @ObservedObject var permissionManager: PermissionsManager = .shared

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(permissionManager.allGranted ? "all granted" : "NOT all granted")")
            }
            Divider()
        }
    }
}

/// View for testing permission requests.
///
/// This view provides buttons to request each type of permission
/// and displays the resulting authorization status.
struct AskPermissionsView: View {
    /// The permissions manager instance to use
    let permissionsManager: PermissionsManager
    
    /// Current status message to display
    @State var statusMsg: String = "Ready to Ask"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ask Permissions")
                .font(.title2)
            
            ForEach(
                permissionsManager.permissions,
                id: \.identifier.id,
                content: { permission in
                    Button {
                        permission.requestAuthorization { status in
                            statusMsg = "Status for \(permission.identifier.name) is: \(status.localizedDescription)"
                        }
                    } label: {
                        Label(permission.identifier.name, systemImage: permission.icons.mainIcon)
                    }
                })
            Text("")
            Text(statusMsg)
                .font(.headline)
            Divider()
        }
    }
}

/// View for testing permission status checks.
///
/// This view provides buttons to check the current status of each
/// permission type and displays the result.
struct CompletionPermissionsCheckView: View {
    /// The permissions manager instance to use
    let permissionsManager: PermissionsManager
    
    /// Current status message to display
    @State var statusMsg: String = "Completion Ready to check"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Check Status")
                .font(.title2)
            
            ForEach(
                permissionsManager.permissions,
                id: \.identifier.id,
                content: { permission in
                    Button {
                        permission.checkAuthorization { status in
                            statusMsg = "Status for \(permission.identifier.name) is: \(status.localizedDescription)"
                        }
                    } label: {
                        Label(permission.identifier.name, systemImage: permission.icons.mainIcon)
                    }
                })
            Text("")
            Text(statusMsg)
                .font(.headline)
            Divider()
        }
    }
}

/// View for testing asynchronous permission status checks.
///
/// This view provides buttons to check the current status of each
/// permission type using async/await and displays the result.
struct AsyncPermissionsManagerView: View {
    /// The permissions manager instance to use
    let permissionsManager: PermissionsManager
    
    /// Current status message to display
    @State var statusMsg: String = "Async Ready to check"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Async Status Check")
                .font(.title2)
            
            ForEach(
                permissionsManager.permissions,
                id: \.identifier.id,
                content: { permission in
                    Button {
                        Task {
                            do {
                                let status = await permission.returnAuthorizationStatus()
                                statusMsg = "Status for \(permission.identifier.name) is: \(status.localizedDescription)"
                            }
                        }
                    } label: {
                        Label(permission.identifier.name, systemImage: permission.icons.mainIcon)
                    }
                })
            Text("")
            Text(statusMsg)
                .font(.headline)
            Divider()
        }
    }
}

struct PermissionsManagerSampleView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsManagerSampleView()
    }
}
