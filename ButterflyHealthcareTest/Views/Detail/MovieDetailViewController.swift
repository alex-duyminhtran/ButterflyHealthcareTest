//
//  MovieDetailViewController.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 7/6/2025.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let releaseDateLabel = UILabel()
    private let overViewLabel = UILabel()
    
    private let movie: Movie
    private let service: MovieServiceProtocol
    init(movie: Movie, service: MovieServiceProtocol) {
        self.movie = movie
        self.service = service
        super.init(nibName: nil, bundle: nil)
        self.title = "Details"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureWithMovie()
        setupFavoriteButton()
    }
    
    private func setupUI() {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleToFill
        posterImageView.clipsToBounds = true
        contentView.addSubview(posterImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 25)
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.font = .systemFont(ofSize: 16)
        releaseDateLabel.textColor = .gray
        contentView.addSubview(releaseDateLabel)
        
        overViewLabel.translatesAutoresizingMaskIntoConstraints = false
        overViewLabel.font = .systemFont(ofSize: 16)
        overViewLabel.numberOfLines = 0
        contentView.addSubview(overViewLabel)
    
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            posterImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 350),
            posterImageView.widthAnchor.constraint(equalToConstant: 250),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            releaseDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseDateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            overViewLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 20),
            overViewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            overViewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            overViewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupFavoriteButton() {
        
        let isFavorite = false
        let heartImage = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        let heartButton = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(favoriteTapped))
        navigationItem.rightBarButtonItem = heartButton
    }
    
    @objc private func favoriteTapped() {
        
    }
    
    private func configureWithMovie() {
        
        titleLabel.text = movie.title
        releaseDateLabel.text = "Released: \(movie.releaseDate ?? "")"
        overViewLabel.text = movie.overview
        
        ImageLoader.loadPoster(for: movie, using: service, into: posterImageView)
    }
    
}
