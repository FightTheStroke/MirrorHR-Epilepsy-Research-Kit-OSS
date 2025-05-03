//
//  AudioVideoNLPHelpers.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 06/11/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SharedPkg

enum AudioVideoMetadata: Codable, Equatable {
    case sentiment(value: Double)
    case symptomsDetected(symptoms: [HandledSymptomsEvents])
    
    public var jsonString: String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode jsonstring", .error, sourceModule: "AudioVideoMetadata catch")
            return ""
        }
    }
    
    public static func loadFromJson(jsonString: String) -> AudioVideoMetadata? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(AudioVideoMetadata.self, from: data)
    }
    
    private enum CodingKeys: String, CodingKey {
        case sentiment
        case symptomsDetected
    }

    enum CodingError: Error {
        case decoding(String)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .sentiment(let value):
            try container.encode(value, forKey: .sentiment)
        case .symptomsDetected(let symptoms):
            try container.encode(symptoms, forKey: .symptomsDetected)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(Double.self, forKey: .sentiment) {
            self = .sentiment(value: value)
            return
        }
        if let symptoms = try? container.decode([HandledSymptomsEvents].self, forKey: .symptomsDetected) {
            self = .symptomsDetected(symptoms: symptoms)
            return
        }
        throw CodingError.decoding("JSon Decoder error: \(dump(container))")
    }
}
