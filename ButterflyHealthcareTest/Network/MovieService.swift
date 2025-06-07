//
//  MovieService.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 7/6/2025.
//

import Foundation

protocol MovieServiceProtocol {
    func searchMovie(searchString: String, page: Int) async throws -> [Movie]?
}

/// API client used for the The Movie DB server
final class MovieService: MovieServiceProtocol {
    
    private let apiKey = "3ac6f1402c71e666f4b2158b5f444c92"
    
    private let baseUrlComponents: URLComponents = {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = "/3/search/movie"
        
        return components
    }()
    
    /// search movies
    /// - Parameters:
    ///   - searchString: the search input
    ///   - page: current page
    /// - Returns: number of movies for the current page
    func searchMovie(searchString: String, page: Int) async throws -> [Movie]? {
        
        var components = baseUrlComponents
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: searchString),
            URLQueryItem(name: "page", value: String(page))
        ]
        guard let url =  components.url else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let result = try await NetworkManager.shared.execute(request: request, expecting: MovieSearchResult.self)
        
        return result.results
    }
}
