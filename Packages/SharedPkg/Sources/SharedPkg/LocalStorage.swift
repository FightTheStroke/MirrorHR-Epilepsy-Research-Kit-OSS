//
//  LocalStorage.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 26/09/2020.
//

import Combine
import Foundation

open class LocalStorage: LocalStorageProtocol {
    // takes only strings/json
    public var storageFileName: String

    private let userDefaults = UserDefaults.standard
    public var eraseCommandSubscriber: AnyCancellable

    public required init(_ storageFileName: String) {
        self.storageFileName = storageFileName
        eraseCommandSubscriber = eraseCommandCombinePublisher
            .sink {
                mainDebugger.append("eraseCommandSubscriber received for \(storageFileName)", .event)
                UserDefaults.standard.removeObject(forKey: storageFileName)
            }
    }

    private func isKeyPresentInUserDefaults(key: String) -> Bool {
        userDefaults.object(forKey: key) != nil
    }

    public func save(_ jsonString: String) {
        userDefaults.set(jsonString, forKey: storageFileName)
    }

    public func load() -> String {
        if isKeyPresentInUserDefaults(key: storageFileName) {
            return (userDefaults.string(forKey: storageFileName) ?? "")
        } else {
            return ""
        }
    }

    public func remove() {
        userDefaults.removeObject(forKey: storageFileName)
    }
}
