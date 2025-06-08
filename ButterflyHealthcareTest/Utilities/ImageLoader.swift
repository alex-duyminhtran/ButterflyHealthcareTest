//
//  ImageLoader.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 8/6/2025.
//

import Foundation
import UIKit

final class ImageLoader {
    
    /// Load image for Movie
    /// - Parameters:
    ///   - movie: movie object
    ///   - service: service to load image data
    ///   - imageView: UIImageView
    ///   - imagePlaceholder: placeholder for the UIImageView
    static func loadPoster(for movie: Movie,
                           using service: MovieServiceProtocol,
                           into imageView: UIImageView,
                           imagePlaceholder: UIImage? =  UIImage(named: "NoImageAvailable")) {
        
        
        guard let posterPath = movie.posterPath else {
            DispatchQueue.main.async {
                imageView.image = imagePlaceholder
            }
            return
        }
        
        Task {
            do {
                let config = try await service.loadConfigIfNeeded()
                guard let secureBaseUrl = config?.images.secureBaseUrl,
                      let size = config?.images.posterSizes.last else {
                    DispatchQueue.main.async {
                        imageView.image = imagePlaceholder
                    }
                    return
                }
                
                let urlString = "\(secureBaseUrl)\(size)\(posterPath)"
                ImageCache.shared.loadImage(from: urlString) { image in
                    DispatchQueue.main.async {
                        if image != nil {
                            imageView.image = image
                        } else {
                            imageView.image = imagePlaceholder
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    imageView.image = imagePlaceholder
                }
            }
        }
    }
}
