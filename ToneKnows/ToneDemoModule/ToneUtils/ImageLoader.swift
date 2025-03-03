//
//  ImageHelper.swift
//  ToneKnows
//
//  Created by Balan iOS on 28/02/25.
//

import UIKit
import SDWebImageAVIFCoder

class ImageLoader: ImageLoaderProtocol {
    
    func getValidURL(from urlString: String) -> URL? {
        if let normalURL = URL(string: urlString) {
            return normalURL
        } else if let decodedURLString = decodeURL(urlString) {
            let finalEncodedURL = decodedURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            return finalEncodedURL.flatMap { URL(string: $0) }
        }
        print("Invalid URL: \(urlString)")
        return nil
    }
    
    func decodeURL(_ urlString: String) -> String? {
        return urlString.removingPercentEncoding
    }
    
    func fetchImage(url: URL, urlString: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let image = UIImage(data: data) {
                ImageCache.shared.saveImage(image, forKey: urlString)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                print("Failed to create image from data. Data size: \(data.count) bytes")
                self.getImageFromSDWebImage(from: url) { image in
                    DispatchQueue.main.async {
                        if let image {
                            completion(image)
                        } else {
                            print("Failed to create image from data.")
                            completion(nil)
                        }
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    func getImageFromSDWebImage(from url: URL?, completion: ((UIImage?) -> Void)?) {
        guard let validURL = url else {
            completion?(nil)
            return
        }
        
        SDWebImageDownloader.shared.downloadImage(with: validURL, options: [.continueInBackground, .highPriority], progress: nil) { image, data, error, _ in
            if let error = error {
                print("SDWebImage Error: \(error.localizedDescription)")
            }
            if let image = image {
                completion?(image)
            } else if let data = data {
                print("Attempting AVIF conversion")
                self.convertAVIFToPNGOrJPEG(from: data, completion: completion)
            } else {
                print("Image download failed for URL: \(validURL), Error: \(error?.localizedDescription ?? "Unknown error")")
                completion?(nil)
            }
        }
    }
    
    func convertAVIFToPNGOrJPEG(from data: Data, completion: ((UIImage?) -> Void)?) {
        guard let ciImage = CIImage(data: data) else {
            print("Failed to create CIImage from AVIF data")
            completion?(nil)
            return
        }
        
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let finalImage = UIImage(cgImage: cgImage)
            completion?(finalImage)
        } else {
            print("Failed to create CGImage from AVIF")
            completion?(nil)
        }
    }
    
    func fetchImageData(url: URL, completion: @escaping (UIImage?) -> Void) {
        self.getImageFromSDWebImage(from: url, completion: completion)
    }
}
