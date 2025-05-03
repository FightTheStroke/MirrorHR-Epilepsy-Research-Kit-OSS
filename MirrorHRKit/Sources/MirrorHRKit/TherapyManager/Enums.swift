//
//  Enum.swift
//  
//
//  Created by Roberto D’Angelo on 24/04/22.
//

import Foundation
import SharedPkg

public enum DrugUnit: Codable, MyGenericPicker {
    public typealias MyGenericType = DrugUnit
    case mg
    case ml
    case grams
    
    public var description: String {
        switch self {
        case .mg:
            return "mg"
        case .ml:
            return "ml"
        case .grams:
            return "gr"
        }
    }
    
    static func valueFrom(description: String) -> DrugUnit {
        DrugUnit.allCases.filter { unit in
            unit.description == description
        }.first ?? defaultValue
    }
    
    public static var allOptions: [String] {
        DrugUnit.allCases.map { unit in
            unit.description
        }
    }
    
    public static var defaultValue: DrugUnit {
        return .mg
    }
    
    public var image: String? {
        return nil
    }
}

public enum DrugShape: Codable, MyGenericPicker {
    case pill
    case spoon
    case other

    public var description: String {
        switch self {
        case .pill:
            return drugShapePillDescription
        case .spoon:
            return drugShapeSpoonDescription
        case .other:
            return drugOtherShapeDescription
        }
    }
    
    static func valueFrom(description: String) -> DrugShape? {
        DrugShape.allCases.filter { shape in
            shape.description == description
        }.first ?? nil
    }

    public static var allOptions: [String] {
        DrugShape.allCases.map { shape in
            shape.description
        }
    }

    public static var defaultValue: DrugShape {
        return .pill
    }

    public var image: String? {
        switch self {
        case .pill:
            return "pills"
        case .spoon:
            return "eyedropper"
        case .other:
            return "heart.text.square"
        }
    }
}
