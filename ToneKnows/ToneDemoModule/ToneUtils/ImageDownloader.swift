//
//  Extension + UIImageView.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit
import Alamofire
import SDWebImageAVIFCoder

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
    
    func setImage(from urlString: String, placeholder: UIImage? = UIImage(named: "placeholder")) {
        setImage(from: urlString, placeholder: placeholder, completion: nil)
    }
    
    func setImage(from urlString: String, placeholder: UIImage? = UIImage(named: "placeholder"), completion: ((Bool?) -> Void)?) {
        self.image = placeholder
        showLoader()
        
        currentTask?.cancel()
        
        guard let validURL = ImageHelper.shared.getValidURL(from: urlString) else {
            hideLoader()
            completion?(false)
            return
        }
        // Check Cache
        if let cachedImage = ImageCache.shared.getImage(forKey: urlString) {
            self.image = cachedImage
            hideLoader()
            completion?(true)
            return
        }
        
        currentTask = ImageHelper.shared.fetchImage(url: validURL, urlString: urlString) { image in
            DispatchQueue.main.async {
                self.image = image
                self.hideLoader()
                completion?(image != nil)
            }
        }
        
        currentTask?.resume()
    }
    
    private func showLoader() {
        DispatchQueue.main.async {
            let loader = UIActivityIndicatorView(style: .medium)
            loader.translatesAutoresizingMaskIntoConstraints = false
            loader.color = .gray
            loader.tag = 999
            
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
