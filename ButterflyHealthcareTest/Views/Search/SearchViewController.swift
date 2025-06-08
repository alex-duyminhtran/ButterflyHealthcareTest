//
//  SearchViewController.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 7/6/2025.
//

import UIKit

class SearchViewController: UIViewController {

    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let loadingFooter = UIActivityIndicatorView(style: .medium)
    private let emptyStateLabel =  UILabel()
    
    private let viewModel = SearchViewModel(movieService: MovieService())
    private var currentQuery = ""
    private var showOfflineData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    
    /// Setup UI, Delegation and Datasource
    private func setupUI() {
        
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        viewModel.delegate = self
        
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        loadingFooter.hidesWhenStopped = true
        tableView.tableFooterView = loadingFooter
        
        emptyStateLabel.text = "No movies found!"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    /// Loading more movies when scrolling down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if showOfflineData {
            return
        }
        
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if position > (contentHeight - scrollViewHeight - 100)
            && !viewModel.movies.isEmpty {
            // load next page
            Task {
                await viewModel.searchMovie(searchString: currentQuery, isNewQuery: false)
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let query = searchBar.text, !query.isEmpty else {
            return
        }
        currentQuery = query
        searchBar.resignFirstResponder()
        
        viewModel.resetData()
        emptyStateLabel.isHidden = true
        
        if NetworkMonitor.shared.isConnected {
            showOfflineData = false
            Task {
                await viewModel.searchMovie(searchString: currentQuery, isNewQuery: true)
            }
        } else {
            // no internet connection
            showOfflineData = true
            showErrorSnackbar(message: "No internet connection. Showing cached results!")
            viewModel.loadCachedMovies(for: currentQuery)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        currentQuery = ""
        searchBar.resignFirstResponder()
        
        viewModel.resetData()
        emptyStateLabel.isHidden = true
    }
}

extension SearchViewController: SearchViewModelDelegate {
    
    func onMoviesUpdated() {
        tableView.reloadData()
        emptyStateLabel.isHidden = !viewModel.movies.isEmpty
    }
    
    func onLoadingStateChanged(isLoading: Bool) {
        
        if isLoading {
            emptyStateLabel.isHidden = true
            loadingFooter.startAnimating()
        } else {
            loadingFooter.stopAnimating()
        }
    }
    
    func onError(message: String) {
        
        showErrorAlert(message: message)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let movie = viewModel.movies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier) as! MovieTableViewCell
        cell.configure(with: movie, service: MovieService())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedMovie = viewModel.movies[indexPath.row]
        let detailVC = MovieDetailViewController(movie: selectedMovie, service: MovieService())
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
