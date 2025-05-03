//
//  LocationManager.swift
//  
//
//  Created by Roberto D’Angelo on 12/06/24.
//

import Foundation
import CoreLocation
import SwiftUI

public struct WorldLocation: Codable {
    public init(latitude: String, longitude: String) {
        self.latitude = LocationManager.stringToCoordinate(latitude)
        self.longitude = LocationManager.stringToCoordinate(longitude)
        self.timeStamp = Date()
    }
    
    public var latitude: Double?
    public var longitude: Double?
    public var timeStamp: Date
    
    public func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        
        if let latitude = latitude {
            dictionary["latitude"] = latitude
        }
        if let longitude = longitude {
            dictionary["longitude"] = longitude
        }
        
        // Converti la data in una stringa per poterla serializzare facilmente
        let dateFormatter = ISO8601DateFormatter()
        dictionary["timeStamp"] = dateFormatter.string(from: timeStamp)
        
        return dictionary
    }

}

public class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    public static let shared: LocationManager = LocationManager()
    
    private let locationManager = CLLocationManager()
    public var currentLocation: CLLocation?
    public var currentLatitude: String = ""
    public var currentLongitude: String = ""
    public var timeStamp: Date = Date()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location
        self.currentLatitude = LocationManager.coordinateToString(location.coordinate.latitude)
        self.currentLongitude = LocationManager.coordinateToString(location.coordinate.longitude)
        self.timeStamp = location.timestamp
    }
    
    public static func coordinateToString(_ value: Double?) -> String {
        guard let value = value else {
            return ""
        }
        return String(format: "%.6f", value)
    }
    
    public static func stringToCoordinate(_ value: String) -> Double? {
        return Double(value) 
    }
}


