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
    private let viewModel = SearchViewModel(movieService: MovieService())
    private var currentQuery = ""
    
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
        Task {
            await viewModel.searchMovie(searchString: currentQuery)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        currentQuery = ""
        searchBar.resignFirstResponder()
        
        viewModel.resetData()
    }
}

extension SearchViewController: SearchViewModelDelegate {
    func onMoviesUpdated() {
        tableView.reloadData()
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
