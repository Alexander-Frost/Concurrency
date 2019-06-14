//
//  Cache.swift
//  Random Users
//
//  Created by Alex on 6/14/19.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cache = [Key : Value]()
    private let queue = DispatchQueue(label: "SerialQueue", qos: .background)

    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }

    func value(for key: Key) -> Value? {
        return queue.sync {cache[key]}
    }
    
    func clear() {
        queue.async {
            self.cache.removeAll()
        }
    }
}
