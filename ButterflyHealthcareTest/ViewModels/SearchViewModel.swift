//
//  SearchViewModel.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 7/6/2025.
//

import Foundation
import CoreData

protocol SearchViewModelDelegate:NSObject {
    func onMoviesUpdated()
    func onLoadingStateChanged(isLoading: Bool)
    func onError(message: String)
}

public final class SearchViewModel {
    
    private let movieService: MovieServiceProtocol
    
    weak var delegate: SearchViewModelDelegate?
    
    private(set) var movies:[Movie] = [] {
        didSet {
            self.delegate?.onMoviesUpdated()
        }
    }
    
    private(set) var currentPage = 1
    private(set) var isLoading = false
    private(set) var totalPages = 1
    
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
    ///   - searchString: searchi input from user
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
                cacheMovies(movies, for: searchString)
                totalPages = searchResult?.totalPages ?? 0
                currentPage += 1
            }
        } catch {
            let errorMessage: String
            if let apiErrpr = error as? APIError {
                errorMessage = apiErrpr.customDescription
            } else {
                errorMessage = error.localizedDescription
            }
            
            await MainActor.run {
                delegate?.onError(message: errorMessage)
            }
        }
    }
    
    /// Cache movies into CoreData
    /// - Parameters:
    ///   - movies: search results
    ///   - searchString: search input
    func cacheMovies(_ movies: [Movie], for searchString: String) {
        
        let context = CoreDataManager.shared.context
        
        // Remove old search results for this query
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@", searchString)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
        
        // Create new objects
        for movie in movies {
            let cdMovie = CDMovie(context: context)
            cdMovie.id = Int64(movie.id ?? 0)
            cdMovie.title = movie.title
            cdMovie.overview = movie.overview
            cdMovie.releaseDate = movie.releaseDate
            cdMovie.posterPath = movie.posterPath
            cdMovie.query = searchString
            cdMovie.timestamp = Date()
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    /// Load cached movies from CoreData
    /// - Parameter searchString: search input
    func loadCachedMovies(for searchString: String) {
        
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[c] %@", searchString)
        
        do {
            let results = try context.fetch(request)
            let movies = results.map { cdMovie in
                Movie(adult: nil, backdropPath: nil, genreIDS: nil, id: Int(cdMovie.id), originalLanguage: nil, originalTitle: nil, overview: cdMovie.overview, popularity: nil, posterPath: cdMovie.posterPath, releaseDate: cdMovie.releaseDate, title: cdMovie.title, video: nil, voteAverage: nil, voteCount: nil)
            }
            self.movies = movies
        } catch {
            print("Failed to load cached results: \(error)")
        }
    }
}
