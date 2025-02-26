//
//  SheetPresenter.swift
//  ToneDemo
//
//  Created by Balan iOS on 21/02/25.
//

import UIKit

class SheetPresenter {
    
    func handleImageDataNotification(imageURL: String = "", imageData: Data? = nil) {
        DispatchQueue.main.async {
            
            guard let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                .first else {
                print("Failed to get root view controller")
                return
            }
            
            if let presentedVC = rootViewController.presentedViewController {
                print("Dismissing existing presented view controller: \(presentedVC)")
                presentedVC.dismiss(animated: true) { [weak self] in
                    self?.showSheet(on: rootViewController, imageURL: imageURL, imageData: imageData)
                }
            } else {
                self.showSheet(on: rootViewController, imageURL: imageURL, imageData: imageData)
            }
        }
    }
    
    private func showSheet(on rootViewController: UIViewController, imageURL: String, imageData: Data? = nil) {
        DispatchQueue.main.async {
            let toneSheet = ToneDetectedSheet(imageURL: imageURL, imageData: imageData)
            toneSheet.modalPresentationStyle = .automatic
            rootViewController.present(toneSheet, animated: true, completion: nil)
        }
    }
}
