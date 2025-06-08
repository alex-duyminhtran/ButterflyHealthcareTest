//
//  ImageLoader.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 8/6/2025.
//

import Foundation
import UIKit

final class ImageLoader {
    
    /// Load poster image for a movie asynchronously using a completion handler.
    /// - Parameters:
    ///   - movie: The movie to load the poster for.
    ///   - service: The service used to fetch configuration data.
    ///   - completion: A closure returning the image or `nil` if loading failed.
    static func loadPoster(for movie: Movie,
                           using service: MovieServiceProtocol,
                           completion: @escaping (UIImage?) -> Void) {
        
        guard let posterPath = movie.posterPath else {
            completion(nil)
            return
        }

        Task {
            do {
                let config = try await service.loadConfigIfNeeded()
                
                guard let secureBaseUrl = config?.images.secureBaseUrl,
                      let size = config?.images.posterSizes.last else {
                        completion(nil)
                    return
                }
                
                let urlString = "\(secureBaseUrl)\(size)\(posterPath)"
                ImageCache.shared.loadImage(from: urlString) { image in
                    completion(image)
                }
                
            } catch {
                completion(nil)
            }
        }
    }
}
