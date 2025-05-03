//
//  PublishedStored.swift
//  
//
//  Created by Riccardo Cipolleschi on 17/11/21.
//

import Foundation
import Combine

// MARK: - Type Erasure for the stored property
public protocol AnyPublishedStored {
    var storage: Storage! { get set }
}

// MARK: - Generic Property Wrapper
@propertyWrapper
public final class PublishedStored<Value: Codable>: AnyPublishedStored {
    
    let key: StorageKey
    let defaultValue: Value
    public var storage: Storage!
    let publisher = PassthroughSubject<Value?, Never>()
    
    public var wrappedValue: Value {
        get {
            storage.codable(type: Value.self, forKey: key, default: defaultValue)
        }
        set {
            storage.set(codable: newValue, forKey: key)
            publisher.send(newValue)
        }
    }
    
    public var projectedValue: AnyPublisher<Value?, Never> {
        return self.publisher.eraseToAnyPublisher()
    }
    
    public init(key: StorageKey, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

// MARK: - Free function to improve scalability
public func setStorage(_ storage: Storage, into instance: Any) {
    let mirror = Mirror(reflecting: instance)
    
    mirror.children.forEach { property in
        guard var publishedStored = property.value as? AnyPublishedStored else {
            return
        }
        publishedStored.storage = storage
    }
}
