//
//  ImageCache.swift
//  ButterflyHealthcareTest
//
//  Created by Minh on 7/6/2025.
//

import Foundation
import UIKit

final class ImageCache {
    
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private let defaults = UserDefaults.standard
    private let keyPrefix = "image_cache_"
    
    private init() {}
    
    // MARK: - Public methods
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        let key = storageKey(for: urlString)
        /// check cached image
        if let cachedImage = getImage(for: key) {
            completion(cachedImage)
            return
        }
        
        /// check valid url
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) {[weak self] data, repsones, error in
            guard let data = data , let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            self?.save(image: image, for: key)
            completion(image)
        }
        .resume()
    }
    
    /// Remove a cached image
    /// - Parameter urlString: url string
    func removeCahedImage(for urlString: String) {
        
        let key = storageKey(for: urlString)
        defaults.removeObject(forKey: key)
        cache.removeObject(forKey: key as NSString)
    }
    
    /// Clear all cached images
    func clearAllCachedImages(){
        
        cache.removeAllObjects()
        
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(keyPrefix) {
            defaults.removeObject(forKey: key)
        }
    }
    
    // MARK: - Private methods
    
    /// Create a desired key for cache
    /// - Parameter urlString: url string
    /// - Returns: key
    private func storageKey(for urlString: String) -> String {
            keyPrefix + urlString
    }
    
    /// Get image from cache
    /// - Parameter key: key
    /// - Returns: UIImage
    private func getImage(for key: String) -> UIImage? {
        
        /// try to get image from memory first
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        
        /// get image from UserDefaults
        if let imageData = defaults.data(forKey: key),
           let image = UIImage(data: imageData) {
            /// store the image to the memory for faster access
            cache.setObject(image, forKey: key as NSString)
            
            return image
        }
        
        return nil
    }
    
    /// Save an UIImage into cache
    /// - Parameters:
    ///   - image: UIImage
    ///   - key: key
    private func save(image: UIImage, for key: String) {
        
        if let data = image.pngData() {
            defaults.set(data, forKey: key)
            cache.setObject(image, forKey: key as NSString)
        }
    }
}
