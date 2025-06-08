//
//  NetworkMonitor.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 8/6/2025.
//

import Foundation
import Reachability

final class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    private var reachability: Reachability?
    
    var isConnected: Bool {
        return reachability?.connection != .unavailable
    }
    
    private init() {
        reachability = try? Reachability()
        try? reachability?.startNotifier()
    }
    
    deinit {
        reachability?.stopNotifier()
    }
    
}
