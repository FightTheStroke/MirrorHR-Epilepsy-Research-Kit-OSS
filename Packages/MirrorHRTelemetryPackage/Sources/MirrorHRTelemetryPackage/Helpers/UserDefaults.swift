import Foundation

extension UserDefaults {
    static func isTelemetryOn(for type: String) -> Bool? {
        guard self.standard.object(forKey: type) != nil else {
            return nil
        }
        return self.standard.bool(forKey: type)
    }
    
    static func turnTelemetry(on: Bool, for type: String) {
        self.standard.setValue(on, forKey: type)
    }
}

class UserDefaultsManager {
    private static let defaults = UserDefaults.standard
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()
    
    static func saveToUserDefaults<T: Codable>(key: String, data: T) {
        do {
            let encodedData = try encoder.encode(data)
            defaults.set(encodedData, forKey: key)
        } catch {
            CareGiversManager.logger.error("Failed to encode \(key): \(error.localizedDescription)")
        }
    }
    
    static func loadFromUserDefaults<T: Codable>(key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            CareGiversManager.logger.error("Failed to decode \(key): \(error.localizedDescription)")
            return nil
        }
    }
    
    static func removeFromUserDefaults(key: String) {
        defaults.removeObject(forKey: key)
    }
}
