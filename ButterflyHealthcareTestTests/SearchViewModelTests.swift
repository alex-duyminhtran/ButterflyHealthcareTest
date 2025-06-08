//
//  SearchViewModelTests.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 8/6/2025.
//

import XCTest
@testable import ButterflyHealthcareTest

class MockMovieService: MovieServiceProtocol {
    
    var searchMovieResult: MovieSearchResult? = nil
    var shouldThrowError = false
    var errorToThrow: Error = APIError.requestFailed(description: "Request failed")
    
    func searchMovie(searchString: String, page: Int) async throws -> MovieSearchResult? {
        if shouldThrowError {
            throw errorToThrow
        }
        return searchMovieResult
    }
    
    func loadConfigIfNeeded() async throws -> ServiceConfiguration? {
        return nil
    }
}

final class SearchViewModelTests: XCTestCase, SearchViewModelDelegate {
    
    var viewModel: SearchViewModel!
    var mockService: MockMovieService!
    
    // Delegate expectation flags
    var didUpdateMoviesCalled = false
    var loadingStateChanges: [Bool] = []
    var errorMessages: [String] = []

    var loadingExpectation: XCTestExpectation?
    var moviesUpdateExpectation: XCTestExpectation?

    override func setUp() {
        super.setUp()
        mockService = MockMovieService()
        viewModel = SearchViewModel(movieService: mockService)
        viewModel.delegate = self
        
        didUpdateMoviesCalled = false
        loadingStateChanges = []
        errorMessages = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Delegate Methods
    
    func onMoviesUpdated() {
        didUpdateMoviesCalled = true
        moviesUpdateExpectation?.fulfill()
    }
    
    func onLoadingStateChanged(isLoading: Bool) {
        loadingStateChanges.append(isLoading)
        loadingExpectation?.fulfill()
    }
    
    func onError(message: String) {
        errorMessages.append(message)
    }
    
    // MARK: - Tests
    
    func testSearchMovieSuccess_NewQuery() {
        
        let movie = Movie(adult: nil, backdropPath: nil, genreIDS: nil, id: 1, originalLanguage: nil, originalTitle: nil, overview: "It is a good movie", popularity: nil, posterPath: "/123.png", releaseDate: "2025-12-13", title: "New Movie", video: nil, voteAverage: nil, voteCount: nil)
        let searchResult = MovieSearchResult(page: 1, results: [movie], totalPages: 12, totalResults: 20)
        mockService.searchMovieResult = searchResult
        
        // Set expectations
        loadingExpectation = expectation(description: "Loading state changed twice")
        loadingExpectation?.expectedFulfillmentCount = 2
        
        moviesUpdateExpectation = expectation(description: "Movies updated")
        
        // Perform search
        Task {
            await viewModel.searchMovie(searchString: "Test", isNewQuery: true)
        }

        // Wait for expectations
        wait(for: [loadingExpectation!, moviesUpdateExpectation!], timeout: 2.0)

        // Assert results
        XCTAssertTrue(didUpdateMoviesCalled, "Delegate onMoviesUpdated should be called")
        XCTAssertEqual(viewModel.movies.count, 1)
        XCTAssertEqual(viewModel.movies.first?.title, "New Movie")
        XCTAssertEqual(loadingStateChanges, [true, false])
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertEqual(viewModel.totalPages, 12)
    }
    
    func testSearchMovieSuccess_LoadMore() {
        
        let movie1 = Movie(adult: nil, backdropPath: nil, genreIDS: nil, id: 1, originalLanguage: nil, originalTitle: nil, overview: "First", popularity: nil, posterPath: "/1.png", releaseDate: "2025-01-01", title: "First Movie", video: nil, voteAverage: nil, voteCount: nil)
        let movie2 = Movie(adult: nil, backdropPath: nil, genreIDS: nil, id: 2, originalLanguage: nil, originalTitle: nil, overview: "Second", popularity: nil, posterPath: "/2.png", releaseDate: "2025-02-01", title: "Second Movie", video: nil, voteAverage: nil, voteCount: nil)

        // Initial load
        mockService.searchMovieResult = MovieSearchResult(page: 1, results: [movie1], totalPages: 2, totalResults: 2)

        loadingExpectation = expectation(description: "Loading for page 1")
        loadingExpectation?.expectedFulfillmentCount = 2
        moviesUpdateExpectation = expectation(description: "Update after first load")

        Task {
            await viewModel.searchMovie(searchString: "Test", isNewQuery: true)
        }

        wait(for: [loadingExpectation!, moviesUpdateExpectation!], timeout: 2.0)

        // Load more
        mockService.searchMovieResult = MovieSearchResult(page: 2, results: [movie2], totalPages: 2, totalResults: 2)

        loadingExpectation = expectation(description: "Loading for page 2")
        loadingExpectation?.expectedFulfillmentCount = 2
        moviesUpdateExpectation = expectation(description: "Update after second load")

        Task {
            await viewModel.searchMovie(searchString: "Test", isNewQuery: false)
        }

        wait(for: [loadingExpectation!, moviesUpdateExpectation!], timeout: 2.0)

        XCTAssertEqual(viewModel.movies.count, 2)
        XCTAssertEqual(viewModel.movies[0].title, "First Movie")
        XCTAssertEqual(viewModel.movies[1].title, "Second Movie")
        XCTAssertEqual(viewModel.currentPage, 3)
        XCTAssertEqual(viewModel.totalPages, 2)
    }

    func testSearchMovieFailure_ShowsError() {
        mockService.shouldThrowError = true
        mockService.errorToThrow = APIError.invalidStatusCode(statusCode: 401)

        loadingExpectation = expectation(description: "Loading starts and ends")
        loadingExpectation?.expectedFulfillmentCount = 2
        let errorExpectation = expectation(description: "Error should be reported")

        Task {
            await viewModel.searchMovie(searchString: "Test", isNewQuery: true)
        }

        // add delay to ensure delegate is called
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !self.errorMessages.isEmpty {
                errorExpectation.fulfill()
            }
        }

        wait(for: [loadingExpectation!, errorExpectation], timeout: 2.0)

        XCTAssertFalse(didUpdateMoviesCalled, "Movies should not be updated on error")
        XCTAssertEqual(errorMessages.count, 1)
        XCTAssertTrue(errorMessages[0].contains("Invalid status code: 401"))
    }
}
