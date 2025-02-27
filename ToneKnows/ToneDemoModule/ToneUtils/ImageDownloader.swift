//
//  Extension + UIImageView.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func saveImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

extension UIImageView {
    private struct AssociatedKeys {
        static var taskKey = "imageTaskKey"
    }
    
    private var currentTask: URLSessionDataTask? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.taskKey) as? URLSessionDataTask }
        set { objc_setAssociatedObject(self, &AssociatedKeys.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func loadImage(from urlString: String, placeholder: UIImage? = UIImage(named: "placeholder")) {
        self.image = placeholder
        showLoader()
        
        // Cancel any ongoing task before starting a new one
        currentTask?.cancel()
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            hideLoader()
            return
        }
        
        // Check Cache
        if let cachedImage = ImageCache.shared.getImage(forKey: urlString) {
            self.image = cachedImage
            hideLoader()
            return 
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            guard let self = self, let data = data, error == nil,
                  let image = UIImage(data: data) else {
                print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async { self?.hideLoader() }
                return
            }
            
            // Cache the image
            ImageCache.shared.saveImage(image, forKey: urlString)
            
            DispatchQueue.main.async {
                self.image = image
                self.hideLoader()
            }
        }
        
        // Store and start the task
        currentTask = task
        task.resume()
    }
    
    // MARK: - Loader Methods
    private func showLoader() {
        let loader = UIActivityIndicatorView(style: .medium)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = .gray
        loader.tag = 999
        
        DispatchQueue.main.async {
            self.addSubview(loader)
            
            NSLayoutConstraint.activate([
                loader.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                loader.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
            
            loader.startAnimating()
        }
    }
    
    private func hideLoader() {
        DispatchQueue.main.async {
            self.viewWithTag(999)?.removeFromSuperview()
        }
    }
}
