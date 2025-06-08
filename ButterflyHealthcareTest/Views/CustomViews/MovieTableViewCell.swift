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
   
    private var currentImageLoadId = UUID()
    
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
        
        titleLabel.text = nil
        releaseDateLabel.text = nil

        // Invalidate current image load id to ignore old completions
        currentImageLoadId = UUID()
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
        
        let loadId = UUID()
        currentImageLoadId = loadId
        self.posterImageView.image = nil
        
        ImageLoader.loadPoster(for: movie, using: service) { [weak self] image in
            
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                if self.currentImageLoadId == loadId {
                    // Only update if this is the latest request
                    if image != nil {
                        self.posterImageView.image = image
                    } else {
                        self.posterImageView.image = UIImage(named: "NoImageAvailable")
                    }
                }
            }
        }
    }
}
