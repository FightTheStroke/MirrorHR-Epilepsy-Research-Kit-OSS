//
//  StorageKeys.swift
//  
//
//  Created by Roberto D’Angelo on 12/05/24.
//

import Foundation
import SwiftUI

@propertyWrapper
public struct EnumAppStorage<T: RawRepresentable>: DynamicProperty where T.RawValue: Equatable {
    private var value: T
    private let key: String
    private let storage: UserDefaults
    private let defaultValue: T

    init(wrappedValue defaultValue: T, _ key: String, store: UserDefaults = .standard) {
        self.key = key
        self.storage = store
        self.defaultValue = defaultValue
        self.value = (T(rawValue: store.object(forKey: key) as? T.RawValue ?? defaultValue.rawValue) ?? defaultValue)
    }

    public var wrappedValue: T {
        get { value }
        set {
            value = newValue
            storage.set(newValue.rawValue, forKey: key)
        }
    }
}


