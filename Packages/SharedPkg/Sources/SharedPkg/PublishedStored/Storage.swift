//
//  Storage.swift
//  
//
//  Created by Riccardo Cipolleschi on 17/11/21.
//

import Foundation

// MARK: - Protocol
public protocol StorageKey {
    var value: String { get }
}

public protocol Storage {
    func codable<T: Codable>(type: T.Type, forKey key: StorageKey) -> T?
    func codable<T: Codable>(type: T.Type, forKey key: StorageKey, default: T) -> T
    func set<T: Codable>(codable: T, forKey key: StorageKey)
}

// MARK: - UserDefault implementation
extension UserDefaults: Storage {
    public func codable<T: Codable>(type: T.Type, forKey key: StorageKey) -> T? {
        guard
            let data = self.data(forKey: key.value),
            let decodedType = try? JSONDecoder().decode(type, from: data)
        else {
            return nil
        }
        return decodedType
    }
    public func codable<T: Codable>(type: T.Type, forKey key: StorageKey, default: T) -> T {
        return codable(type: type, forKey: key) ?? `default`
    }
    
    public func set<T: Codable>(codable: T, forKey key: StorageKey) {
        guard let data = try? JSONEncoder().encode(codable) else {
            return
        }
        self.set(data, forKey: key.value)
    }
}
