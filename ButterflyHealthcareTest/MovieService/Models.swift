//
//  Models.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 8/6/2025.
//

//import ObjectiveC

final class ServiceConfiguration: Codable {
    let images: ImageConfig
}

struct ImageConfig: Codable {
    let baseUrl: String
    let secureBaseUrl: String
    let posterSizes: [String]
    
    enum CodingKeys: String, CodingKey {
        case baseUrl = "base_url"
        case secureBaseUrl = "secure_base_url"
        case posterSizes = "poster_sizes"
    }
}
