//
//  MovieTableViewCell.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 7/6/2025.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    static let identifier = "MovieTableViewCell"

    let posterImageView = UIImageView()
    let titleLabel = UILabel()
    let releaseDateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .systemBackground
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        posterImageView.image = nil
        titleLabel.text = nil
        releaseDateLabel.text = nil
    }

    private func setupUI() {
        
        [posterImageView, titleLabel, releaseDateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        posterImageView.contentMode = .scaleAspectFit
        titleLabel.numberOfLines = 2
        releaseDateLabel.textColor = .gray
        
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            posterImageView.widthAnchor.constraint(equalToConstant: 60),
            posterImageView.heightAnchor.constraint(equalToConstant: 90),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            releaseDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
        ])
    }
    
    func configure(with movie: Movie, service: MovieServiceProtocol) {
        
        titleLabel.text = movie.title
        releaseDateLabel.text = "Released: \(movie.releaseDate ?? "")"
        
        ImageLoader.loadPoster(for: movie, using: service, into: posterImageView)
    }
}
