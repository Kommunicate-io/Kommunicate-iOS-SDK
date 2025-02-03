//
//  KMCacheMemory.swift
//  Kommunicate
//
//  Created by Abhijeet Ranjan on 07/01/25.
//

import Foundation

class KMCacheMemory<T> {
    // A dictionary to hold cached items and their expiry times.
    private var cache: [String: (value: T, expiry: Date)] = [:]
    private let queue = DispatchQueue(label: "com.kommunincate.cache.memory.queue", attributes: .concurrent)

    /// This function is used to set cache data with a specified key and expiration time.
    func setItem(forKey key: String, value: T, expiry: TimeInterval) {
        let expiryDate = Date().addingTimeInterval(expiry)
        queue.async(flags: .barrier) {
            self.cache[key] = (value: value, expiry: expiryDate)
        }
    }

    /// This function is used to retrieve data using the specified key.
    func getItem(forKey key: String) -> T? {
        queue.sync {
            guard let cachedItem = cache[key] else { return nil }
            if Date() > cachedItem.expiry {
                // Remove the expired item
                cache.removeValue(forKey: key)
                return nil
            }
            return cachedItem.value
        }
    }

    /// This function is used to remove a value using the specified key.
    func removeItem(forKey key: String) {
        queue.async(flags: .barrier) {
            self.cache.removeValue(forKey: key)
        }
    }

    /// This function clears all values stored in the cache memory.
    func clear() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}

