//
//  NetworkManager.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 7/6/2025.
//

import Foundation

enum APIError: Error {
    case invalidData
    case dataParsingFailed(description: String)
    case requestFailed(description: String)
    case invalidStatusCode(statusCode: Int)
    case unknownError(error: Error)
    
    var customDescription: String {
        switch self {
        case .invalidData:
            return "Invalid Data"
        case .dataParsingFailed(let description):
            return "Failed to parse data: \(description)"
        case .requestFailed(let description):
            return "Request failed: \(description)"
        case .invalidStatusCode(let statusCode):
            return "Invalid status code: \(statusCode)"
        case .unknownError(let error):
            return "An unknown error occurred \(error.localizedDescription)"
        }
    }
}

/// Network manager to send requests to get data
final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    /// Execute API request
    /// - Parameters:
    ///   - request: API request
    ///   - type: type of the object to be decoded from data
    /// - Returns: return the decoded object
    func execute<T: Decodable> (request: URLRequest, expecting type: T.Type) async throws -> T {
        
        guard let url = request.url else {
            throw APIError.requestFailed(description: "Invalid URL")
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.invalidStatusCode(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw APIError.dataParsingFailed(description: error.localizedDescription)
        }
    }
}
