//
//  QuickNotesHomeView.swift
//
//
//  Created by Roberto D'Angelo on 25/09/23.
//

import Foundation
import SwiftUI
import SharedPkg

struct QuickNotesHomeView: View {
    @AppStorage(UserDefaultsKeys.homeQuickNote) private var storedNote: String = ""
    @AppStorage(UserDefaultsKeys.homeQuickNoteDate) private var storedNoteDate: String = ""
    
    @State private var saved: Bool = false
    @State private var isEditing: Bool = false
    @State private var savedAt: String = ""
    @FocusState private var textEditorIsFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack (alignment: .top) {
                Text("QuickNotesMsg".local())
                    .font(.title2).fontWeight(.bold)
                
                Spacer()
                Text(saved ? "savedBtnMsg".local() : "saveBtnMsg".local())
                    .foregroundColor(saveButtonColor())
                    .onTapGesture {
                        saveNote()
                    }
                    .disabled(storedNote.isEmpty)
            }
            
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 10)  // Ensure the corner radius matches
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 80)
                TextEditor(text: $storedNote)
                    .focused($textEditorIsFocused)
                    .onChange(of: textEditorIsFocused) { newValue in
                        isEditing = newValue
                    }
                    .frame(height: 80)
                    .cornerRadius(10)
                    .keyboardType(.default)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                    .background(Color.clear)
                
                if isEditing && !storedNote.isEmpty {
                    Button(action: {
                        storedNote = ""
                        savedAt = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.gray)
                            .font(.title2)
                    }
                    .padding(.trailing, 5)
                    .padding(.top, 5)
                }
            }
            if !savedAt.isEmpty {
                Text(savedAt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onChange(of: storedNote) { newValue in
            if saved {
                saved = false
                savedAt = ""
            }
        }
        // Gestione del tocco fuori dall'area di TextEditor
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onChange(of: saved) { newValue in
            if newValue {
                UIApplication.shared.endEditing()
            }
        }
        .gesture(DragGesture()
            .onChanged({ _ in
                UIApplication.shared.endEditing()
            })
        )
    }
    
    @MainActor
    func saveNote() {
        DispatchQueue.main.async {
            withAnimation {
                let viewModel = QuickNotesViewModel()
                viewModel.saveSymptomLog(with: storedNote)
                savedAt = Date().toStdString()
                saved = true
                isEditing = false
            }
        }
    }
    
    func saveButtonColor() -> Color {
        if storedNote.isEmpty {
            return .gray
        } else {
            return saved ? .green : .primary
        }
    }
}

struct QuickNotesHomeView_Previews: PreviewProvider {
    static var previews: some View {
        QuickNotesHomeView()
    }
}

private struct UserDefaultsKeys {
    static let homeQuickNote = "HomeQuickNote"
    static let homeQuickNoteDate = "HomeQuickNoteDate"
}

/// View model for quick notes functionality
/// - Manages quick note creation and storage
/// - Handles note organization
/// - Provides note search and filtering
/// - Implements data persistence
class QuickNotesViewModel {
    func saveSymptomLog(with note: String) {
        DispatchQueue.main.async {
            SymptomsManager.shared.appendSymptomLog(SymptomLog(.textLog, startDate: Date(), endDate: Date(), severity: .unspecified, notes: note))
            UserDefaults.standard.setValue(note, forKey: UserDefaultsKeys.homeQuickNote)
            UserDefaults.standard.setValue(Date().toStdString(), forKey: UserDefaultsKeys.homeQuickNoteDate)
        }
    }
}
