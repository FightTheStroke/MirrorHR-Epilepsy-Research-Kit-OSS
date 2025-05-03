//
//  Protocols.swift
//  
//
//  Created by Roberto D’Angelo on 24/04/22.
//

import Foundation

public protocol MyGenericPicker: Codable, CaseIterable, Hashable {
    associatedtype MyGenericType
    var description: String {get}
    var image: String? {get}
    static var defaultValue: MyGenericType {get}
    static var allOptions: [String] {get}
}

public protocol TherapyEntities: Codable, Identifiable, Equatable {
    
}
