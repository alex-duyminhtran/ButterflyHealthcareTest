//
//  SearchViewModel.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 7/6/2025.
//

import Foundation

protocol SearchViewModelDelegate:NSObject {
    func onMoviesUpdated()
}

final class SearchViewModel {
    
    private let movieService: MovieServiceProtocol
    
    weak var delegate: SearchViewModelDelegate?
    
    private(set) var movies:[Movie] = [] {
        didSet {
            self.delegate?.onMoviesUpdated()
        }
    }
    
    init(movieService: MovieServiceProtocol = MovieService()) {
        self.movieService = movieService
    }
    
    func resetData() {
        
        movies.removeAll()
    }
    
    func searchMovie(searchString: String) async {
        
        do {
            let movies = try await movieService.searchMovie(searchString: searchString, page: 1)
            print("count: \(String(describing: movies?.count))")
            if let movies = movies {
                await MainActor.run {
                    self.movies.append(contentsOf: movies)
                }
            }
        } catch {
            if error is APIError {
                print((error as! APIError).customDescription)
            } else {
                print(error.localizedDescription)
            }
        }
    }
}
