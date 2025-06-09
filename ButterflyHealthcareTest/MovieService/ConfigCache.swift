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
    private let configKey = "service_configuration"
    private let cache = NSCache<NSString, ServiceConfiguration>()
    
    private let defaults = UserDefaults.standard

        private init() {
            
            // Load from UserDefaults when initialized
            if let data = defaults.data(forKey: configKey),
               let savedConfig = try? JSONDecoder().decode(ServiceConfiguration.self, from: data) {
                // Save to memory for faster access
                cache.setObject(savedConfig, forKey: configKey as NSString)
            }
        }

        var config: ServiceConfiguration? {
            get {
                cache.object(forKey: configKey as NSString)
            }
            set {
                guard let config = newValue else { return }
                
                // Save to memory cache
                cache.setObject(config, forKey: configKey as NSString)
                
                // Save to UserDefaults
                if let data = try? JSONEncoder().encode(config) {
                    defaults.set(data, forKey: configKey)
                }
            }
        }

        func clear() {
            cache.removeObject(forKey: configKey as NSString)
            defaults.removeObject(forKey: configKey)
        }
}
