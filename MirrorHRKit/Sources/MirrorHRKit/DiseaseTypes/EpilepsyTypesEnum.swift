//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 22/05/22.
//

import Foundation
import SharedPkg

public enum EpilepsyType: String, MyGenericPicker {
    case absence = "AbsenceEpilepsyType"
    case tonicClonic = "TonicClonicEpilepsyType"
    case atonic = "AtonicEpilespyType"
    case clonic = "ClonicEpilepsyType"
    case tonic = "TonicEpilepsyType"
    case myoclonic = "MyoclonicEpilepsyType"
    case focalAware = "FocalAwarenessEpilepsyType"
    case focalNotWare = "FocalNotAwareEpilepsyType"
    case unknown = "UnknownEpilepyType"
    
    public var description: String {
        return self.rawValue.local()
    }

    static func valueFrom(description: String) -> EpilepsyType? {
        EpilepsyType.allCases.filter { type in
            type.description == description
        }.first ?? nil
    }

    public static var allOptions: [String] {
        EpilepsyType.allCases.map { type in
            type.description
        }.sorted()
    }

    public static var defaultValue: EpilepsyType {
        return .unknown
    }

    public var image: String? {
        return nil
    }
}
