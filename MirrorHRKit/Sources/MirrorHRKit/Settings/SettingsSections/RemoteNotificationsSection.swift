//
//  RemoteNotificationsSettingsSection.swift
//
//
//  Created by Roberto D’Angelo on 13/05/23.
//

import Foundation
import SwiftUI
import MirrorHRTelemetryPackage
import UIKit
import SharedPkg
import RoberdanToolBox

enum CardType {
    case caregiver
    case patient
    case empty(String)
}

extension SettingsView {

    var remoteNotificationsSettingsSection: SettingsSection {
        SettingsSection(
            id: "RemoteNotifications",
            header: "RemoteNotificationsHeaderMsg".local(),
            image: internetStreamingImageString,
            rows: [
                .custom(name: "RemoteNotificationsView", AnyView(RemoteNotificationsSettingsView()), isEnabled: true)
            ],
            footer: "remoteNotificationsCaregiversFooter".local(),
            isEnabled: true,
            foregroundColor: stefiBlue
        )
    }
}

// MARK: - CareGiversAndKidsView
struct RemoteNotificationsSettingsView: View {
    @ObservedObject private var careGiversManager = CareGiversManager.shared
    @State private var wizardOn: Bool = false
    
    var body: some View {
        VStack {
            HeaderView()
            
// TODO: sistemare queste navigation link
            NavigationLink(destination: RemoteNotificationsWizard(), isActive: $wizardOn) {
                //is hidden and handled by the button
            }
            .hidden()
            .frame(width: 0, height: 0)
            
            Button {
               wizardOn.toggle()
            } label: {
                Text("Configure Remote Motnitoring")
            }
            .buttonStyle(PrimaryButtonStyle())

            // CareGivers
            if careGiversManager.caregivers.isEmpty {
                EmptyCardView(message: "RemoteNoCaregiverAssociatedMsg".local())
            } else {
                Section(header: Text("remoteNotificationsSettingsTitleMsg".local()).font(.headline)) {
                    ForEach(careGiversManager.caregivers) { caregiver in
                        CardView(type: .caregiver, persona: caregiver, onRemove: {
                            careGiversManager.removePerson(uuid: caregiver.id, type: .caregiver)
                        }, onSelect: nil)
                    }
                }
            }
            
            // patients
            if careGiversManager.patients.isEmpty {
                EmptyCardView(message: "RemoteNoPatientAssociatedMsg".local())
            } else {
                Section(header: Text("RemoteActivePatientsHeaderMsg".local()).font(.headline)) {
                    ForEach(careGiversManager.patients) { patient in
                        CardView(type: .patient, persona: patient, onRemove: {
                            careGiversManager.removePerson(uuid: patient.id, type: .patient)
                        }, onSelect: {
                            careGiversManager.activatePatient(name: patient.name, uuid: patient.id, currentStatus: patient.isActive)
                        })
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .navigationBarItems(trailing: EditButton())
    }
}

// MARK: - HeaderView

struct HeaderView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("yourUniqueIDText".local())
                .font(.title2)
            Text(TelemetryHeader.shared.currentUserID)
                .font(.headline)
                .foregroundColor(.secondary)
            Text("shareYourIDCaregiverMsg".local())
                .font(.body)
                .padding(.top, 8)
        }
    }
}

// MARK: - CardView

struct CardView: View {
    @Environment(\.editMode) private var editMode
    
    let type: CardType
    let persona: Person?
    let onRemove: (() -> Void)?
    let onSelect: (() -> Void)?
    
    var body: some View {
        HStack {
            VStack {
                switch type {
                case .caregiver:
                    caregiverImage
                case .patient:
                    patientImage
                    if let worldLocation = persona?.worldLocation, let latitude = worldLocation.latitude, let longitude = worldLocation.longitude  {
                        Image(systemName: "location.circle")
                            .onTapGesture {
                                openInMaps(latitude: latitude, longitude: longitude)
                            }
                    }
                        
                case .empty:
                    EmptyView()
                }
            }
            .font(.title2)
            
            VStack(alignment: .leading) {
                Text(persona?.name ?? "unknown")
                    .font(.title2)
                Text(persona?.id.uuidString ?? "unknown")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            switch type {
            case .caregiver:
                EmptyView()
            case .patient:
                Image(systemName: persona?.isActive ?? false ? checkMarkFilledImageString : checkMarkEmptyImageString)
                    .foregroundColor( persona?.isActive ?? false ? .green : .secondary)
                    .font(.title2)
                    .onTapGesture {
                        onSelect?()
                    }
            case .empty:
                EmptyView()
            }
            
            Spacer()
            
            if editMode?.wrappedValue.isEditing == true {
                removeItemImage.foregroundColor(.red)
                    .onTapGesture {
                        onRemove?()
                    }
                    .padding()
            }
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(defaultCornerRadius)
        .contentShape(Rectangle())
    }
}

public struct EmptyCardView: View {
    let message: String
    
    public var body: some View {
        Text(message)
            .font(.headline)
            .foregroundColor(.secondary)
            .padding()
    }
}


struct YourUniqueIDView: View {
    @State private var isCopied = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("yourUniqueIDText".local())
                    .font(.headline)
                
                Text("\(TelemetryHeader.shared.currentUserID)")
                    .multilineTextAlignment(.center)
            }
            
            Spacer() // Pushes the button to the right
            
            Button(action: {
                copyToClipboard(text: TelemetryHeader.shared.currentUserID)
                isCopied = true
            }) {
                Image(systemName: "doc.on.doc")
                    .font(.headline)
                    .padding()
                    .foregroundColor(isCopied ? .green : .accentColor)
            }
        }
    }
    
    private func copyToClipboard(text: String) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = "MirrorHR://addCareGiver?ID=\(text)"
    }
}

public struct AddRemotePatientView: View {
    @ObservedObject private var showSheet: SheetViewController = .shared
    let careGiversManager: CareGiversManager
    @State private var newName = ""
    @State private var newUUIDString = ""
    @State private var isInputValid = false
    private let uuidFromURL: Bool
    @FocusState private var isNameFieldFocused: Bool
    
    public init(caregiversManager: CareGiversManager, uuid: String = "", uuidFromURL: Bool = false) {
        _newUUIDString = State(initialValue: uuid)
        self.careGiversManager = caregiversManager
        self.uuidFromURL = uuidFromURL
    }
    
    public var body: some View {
        Form {
            Text("Add a new kid").font(.headline)
            TextField("nameString".local(), text: $newName)
                .onChange(of: newName) { _ in
                    validateInput()
                }
                .focused($isNameFieldFocused)
            
            TextField("uUIDMsg".local(), text: $newUUIDString)
                .onChange(of: newUUIDString) { _ in
                    validateInput()
                }
                .disabled(uuidFromURL)
        }
        .disableAutocorrection(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    addRemotePatient()
                    showSheet.sheetVisible = false
                } label: {
                    Text("saveBtnMsg".local())
                }
                .disabled(!isInputValid)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showSheet.sheetVisible = false
                } label: {
                    Text("cancelActionMsg".local())
                }
                .foregroundColor(.accentColor)
            }
        }
        .onAppear {
            isNameFieldFocused = true
        }
    }
    
    private func validateInput() {
        isInputValid = careGiversManager.validateInput(name: newName, uuidString: newUUIDString)
    }
    
    private func addRemotePatient() {
        if isInputValid {
            careGiversManager.addPerson(name: newName, uuid: newUUIDString, type: .patient)
            newName = ""
            newUUIDString = ""
        } else {
            // Invalid input or UUID entered, show an error or validation message
        }
    }
}

public struct AddCareGiverView: View {
    @ObservedObject private var showSheet: SheetViewController = .shared
    let careGiversManager: CareGiversManager
    @State private var newName = ""
    @State private var newUUIDString = ""
    @State private var isInputValid = false
    private let uuidFromURL: Bool
    @FocusState private var isNameFieldFocused: Bool
    
    public init(caregiversManager: CareGiversManager, uuid: String = "", uuidFromURL: Bool = false) {
        _newUUIDString = State(initialValue: uuid)
        self.careGiversManager = caregiversManager
        self.uuidFromURL = uuidFromURL
    }
    
    public var body: some View {
        Form {
            Text("Add a new caregiver").font(.headline)
            TextField("nameString".local(), text: $newName)
                .onChange(of: newName) { _ in
                    validateInput()
                }
                .focused($isNameFieldFocused)
            
            TextField("uUIDMsg".local(), text: $newUUIDString)
                .onChange(of: newUUIDString) { _ in
                    validateInput()
                }
                .disabled(uuidFromURL)
        }
        .disableAutocorrection(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    addCareGiver()
                    showSheet.sheetVisible = false
                } label: {
                    Text("saveBtnMsg".local())
                }
                .disabled(!isInputValid)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showSheet.sheetVisible = false
                } label: {
                    Text("cancelActionMsg".local())
                }
                .foregroundColor(.accentColor)
            }
        }
        .onAppear {
            isNameFieldFocused = true
        }
    }
    
    private func validateInput() {
        isInputValid = careGiversManager.validateInput(name: newName, uuidString: newUUIDString)
    }
    
    private func addCareGiver() {
        if isInputValid, let newUUID = UUID(uuidString: newUUIDString) {
            careGiversManager.addPerson(name: newName, uuid: newUUID, type: .caregiver)
            newName = ""
            newUUIDString = ""
        } else {
            // Invalid input or UUID entered, show an error or validation message
        }
    }
}

func shareText(_ text: String) {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = window.rootViewController?.view
            popoverController.sourceRect = CGRect(x: window.frame.midX, y: window.frame.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        window.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

func generateDeepLinkURL(forAction action: String, parameters: [String: String]) -> URL? {
    guard let windowScene = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first(where: { $0.activationState == .foregroundActive }),
          let session = windowScene.session as UISceneSession?,
          let configuration = session.configuration as UISceneConfiguration?,
          let scheme = configuration
        .role.rawValue
        .components(separatedBy: ".")
        .first else {
        return nil
    }
    
    var components = URLComponents()
    components.scheme = scheme
    components.path = "/"
    
    var queryItems = [URLQueryItem(name: "action", value: action)]
    for (key, value) in parameters {
        let parameterItem = URLQueryItem(name: key, value: value)
        queryItems.append(parameterItem)
    }
    
    components.queryItems = queryItems
    
    return components.url
}

func shareCareGiverUrlID() {
    guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }),
          let windowScene = scene as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        return
    }
    
    let uuid = TelemetryHeader.getUserID()
    let urlString = addCaregiverURL + "\(uuid)"
    let url = URL(string: urlString)!
    let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    dispatchTelemetryEvent(event: .streaming(status: "Remote monitoring: shared CareGiverID (or at least button pressed)"))
    rootViewController.present(activityController, animated: true, completion: nil)
}

func shareKidUrlID() {
    guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }),
          let windowScene = scene as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        return
    }
    
    let uuid = TelemetryHeader.getUserID()
    let urlString = addPatientURL + "\(uuid)"
    let url = URL(string: urlString)!
    let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    dispatchTelemetryEvent(event: .streaming(status: "Remote monitoring: shared remoteKid (or at least button pressed)"))
    rootViewController.present(activityController, animated: true, completion: nil)
}
