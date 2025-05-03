//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 24/01/22.
//

import Foundation

extension Array {
    public func unique<T: Hashable>(map: ((Element) -> (T))) -> [Element] {
        var set = Set<T>() // the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() // keeping the unique list of elements but ordered
        for value in self where !set.contains(map(value)) {
            set.insert(map(value))
            arrayOrdered.append(value)
        }
        return arrayOrdered
    }
}
