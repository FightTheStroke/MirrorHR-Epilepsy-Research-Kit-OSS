//
//  SubViews.swift
//
//
//  Created by Roberto D’Angelo on 22/10/23.
//
import Foundation
import SwiftUI
import UIKit
import SharedPkg

// MyGenericPickerView<Drug.DrugShape>(labelText: "Drug Shape".local(), binding: $viewModel.drug.shape)

public struct MyCoder<T: Codable> {
    public static func loadFromJsonString(_ jsonString: String) -> T? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    public static func jsonString(_ value: T) -> String {
        do {
            let jsonData = try JSONEncoder().encode(value)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode \(value)", .error, sourceModule: "MyCoder jsonString")
            return ""
        }
    }
}


public struct MyGenericPickerView<T: MyGenericPicker>: View {
    @Binding var binding: T
    //    @State var localValue: T? = (T.defaultValue as? T)
    let labelText: String
    
    public init(labelText: String, binding: Binding<T>) {
        self.labelText = labelText
        _binding = binding
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(labelText)
                Spacer()
                Menu {
                    buildMenu()
                } label: {
                    Text("\(binding.description)")
                        .font(.body.bold())
                    if let image = binding.image {
                        Image(systemName: image)
                    }
                }
            }
        }
    }
    
    public func buildMenu() -> some View {
        ForEach(Array(T.allCases), id: \.self) { option in
            Button(action: {
                self.binding = option
            }, label: {
                HStack {
                    Text(option.description)
                    if let image = option.image {
                        Image(systemName: image)
                    }
                }
            })
        }
    }
}

public struct MyTextField: View {
    let fieldName: String
    @Binding var bindingString: String
    let isMandatory: Bool
    @State private var isEmpty: Bool
    private let split2Rows: Bool
    private let showFieldName: Bool
    private let frameWidth: CGFloat?
    private let textAlignment: TextAlignment
    private let keyboardType: UIKeyboardType
    
    public init(fieldName: String, bindingString: Binding<String>, isMandatory: Bool, split2Rows: Bool = false, showFieldName: Bool = true, textAlignment: TextAlignment = .trailing, keyboardType: UIKeyboardType = .default, frameWidth: CGFloat? = 200) {
        self.fieldName = fieldName
        self.isMandatory = isMandatory
        _bindingString = bindingString
        isEmpty = bindingString.wrappedValue.isEmpty ? true : false
        self.split2Rows = split2Rows
        self.frameWidth = frameWidth
        self.showFieldName = showFieldName
        self.textAlignment = textAlignment
        self.keyboardType = keyboardType
    }
    
    public var body: some View {
        if split2Rows {
            VStack(alignment: .leading) {
                if showFieldName {
                    Text(fieldName)
                        .font(.body)
                }
                TextField(fieldName, text: $bindingString)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(textAlignment)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(keyboardType)
                    .onChange(of: bindingString) { newValue in
                        DispatchQueue.main.async {
                            if newValue.isEmpty {
                                isEmpty = true
                            } else {
                                isEmpty = false
                            }
                        }
                    }
            }
            .foregroundColor((isMandatory && isEmpty) ? .red : .primary)
            .font(isMandatory ? .body.bold() : .body)
        } else {
            HStack {
                if showFieldName {
                    Text(fieldName)
                        .font(.body)
                    Spacer()
                }
                TextField(fieldName, text: $bindingString)
                    .font(.body)
                    .multilineTextAlignment(textAlignment)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(keyboardType)
                    .frame(width: frameWidth)
                    .onChange(of: bindingString) { newValue in
                        DispatchQueue.main.async {
                            if newValue.isEmpty {
                                isEmpty = true
                            } else {
                                isEmpty = false
                            }
                        }
                    }
            }
            .foregroundColor((isMandatory && isEmpty) ? .red : .primary)
            .font(isMandatory ? .body.bold() : .body)
        }
    }
}

import SwiftUI

public struct MyDoubleFieldPicker: View {
    let fieldName: String
    @Binding var bindingDouble: Double
    let isMandatory: Bool
    
    @State private var integerPart: Int = 0
    @State private var decimalPart: Int = 0

    public init(fieldName: String, bindingDouble: Binding<Double>, isMandatory: Bool) {
        self.fieldName = fieldName
        self._bindingDouble = bindingDouble
        self.isMandatory = isMandatory
        _integerPart = State(initialValue: Int(bindingDouble.wrappedValue))
        _decimalPart = State(initialValue: Int((bindingDouble.wrappedValue - Double(Int(bindingDouble.wrappedValue))) * 100))
    }
    
    public var body: some View {
        HStack {
            Text(fieldName)
            Spacer()
            HStack(spacing: 0) { // Riduzione dello spazio tra i picker
                Picker("", selection: $integerPart) {
                    ForEach(0..<300) { i in
                        Text("\(i)")
                            .fontWeight(integerPart == i ? .bold : .regular)
                    }
                }
                .pickerStyle(.wheel) // Specifica lo stile del picker se necessario
                .clipped()
                
                Text(",")
                    .fontWeight(.bold)
                
                Picker("", selection: $decimalPart) {
                    ForEach(0..<100) { i in
                        Text(String(format: "%02d", i))
                            .fontWeight(decimalPart == i ? .bold : .regular)
                    }
                }
                .pickerStyle(.wheel) // Specifica lo stile del picker se necessario
                .clipped()
            }
            .onChange(of: integerPart) { _ in updateDouble() }
            .onChange(of: decimalPart) { _ in updateDouble() }
        }
        .foregroundColor((isMandatory && bindingDouble == 0) ? .red : .primary)
        .font(isMandatory ? .body.bold() : .body)
    }
    
    private func updateDouble() {
        bindingDouble = Double(integerPart) + Double(decimalPart) / 100.0
    }
}


public struct MyDoubleField: View {
    let fieldName: String
    @Binding var bindingDouble: Double
    let isMandatory: Bool
    @State private var isEmpty: Bool = true
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    public init(fieldName: String, bindingDouble: Binding<Double>, isMandatory: Bool) {
        self.fieldName = fieldName
        self._bindingDouble = bindingDouble
        self.isMandatory = isMandatory
    }
    
    
    public var body: some View {
        HStack {
            Text(fieldName)
            Spacer()
            TextField(fieldName, value: $bindingDouble, formatter: formatter)
                .font(.body.bold())
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
                .onChange(of: bindingDouble) { newValue in
                    DispatchQueue.main.async {
                        if newValue == 0 {
                            isEmpty = true
                        } else {
                            isEmpty = false
                        }
                    }
                }
        }
        .foregroundColor((isMandatory && isEmpty) ? .red : .primary)
        .font(isMandatory ? .body.bold() : .body)
    }
}

public struct MyTitleText: View {
    let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .font(.title2)
            .padding()
    }
}
