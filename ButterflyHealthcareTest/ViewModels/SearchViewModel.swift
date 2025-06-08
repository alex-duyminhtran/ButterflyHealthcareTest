//
//  SearchViewModel.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 7/6/2025.
//

import Foundation

protocol SearchViewModelDelegate:NSObject {
    func onMoviesUpdated()
    func onLoadingStateChanged(isLoading: Bool)
}

final class SearchViewModel {
    
    private let movieService: MovieServiceProtocol
    
    weak var delegate: SearchViewModelDelegate?
    
    private(set) var movies:[Movie] = [] {
        didSet {
            self.delegate?.onMoviesUpdated()
        }
    }
    
    private var currentPage = 1
    private var isLoading = false
    private var totalPages = 1
    
    init(movieService: MovieServiceProtocol = MovieService()) {
        self.movieService = movieService
    }
    
    /// Reset data for fresh search
    func resetData() {
        
        movies.removeAll()
        currentPage = 1
        totalPages = 1
        isLoading = false
    }
    
    /// Search movies
    /// - Parameters:
    ///   - searchString: searching input from user
    ///   - isNewQuery: to indicate whether it is fresh search or loading more
    func searchMovie(searchString: String, isNewQuery: Bool) async {
        
        guard !isLoading else {
            return
        }
        guard currentPage <= totalPages else {
            return
        }
        
        isLoading = true
        await MainActor.run {
            delegate?.onLoadingStateChanged(isLoading: isLoading)
        }
        
        defer {
            /// when everything is done
            isLoading = false
            Task { @MainActor in
                delegate?.onLoadingStateChanged(isLoading: isLoading)
            }
        }
        
        do {
            let searchResult = try await movieService.searchMovie(searchString: searchString, page: currentPage)
            await MainActor.run {
                if isNewQuery {
                    movies = searchResult?.results ?? []
                } else {
                    movies.append(contentsOf: searchResult?.results ?? [])
                }
                totalPages = searchResult?.totalPages ?? 0
                currentPage += 1
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
