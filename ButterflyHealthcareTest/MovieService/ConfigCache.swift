//
//  ConfigCache.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 8/6/2025.
//

import Foundation

/// Cache the service config in memory
final class ConfigCache {
    
    static let shared = ConfigCache()
    private let configKey:NSString = "service_configuration"
    private let cache = NSCache<NSString, ServiceConfiguration>()
    
    private init() {}
    var config: ServiceConfiguration? {
        get {
            cache.object(forKey: configKey)
        }
        set {
            guard let config = newValue else {
                return
            }
            cache.setObject(config, forKey: configKey)
        }
    }
}
