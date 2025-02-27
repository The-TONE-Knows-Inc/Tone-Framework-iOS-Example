//
//  TryItViewController.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit
import CoreData

class TryItViewController: BaseViewController {
    
    override func initView() {
        super.initView()
        view.backgroundColor = .containerBackground
    }
    
    override func initAppearView() {
        super.initAppearView()
        if !(UserDefaults.isFrameworkRunning ?? false) {
            toneFramework.start()
            enableToneFrameworkFeatures()
            UserDefaults.isFrameworkRunning = true
            configure(with: UserDefaults.isSelectedImageURL ?? "", clientID: UserDefaults.isSelectedClientID ?? "")
        }
    }
    
    override func setupLayout() {
        view.addSubview(backgroundImage)
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
    }
}

// MARK: - Delegate Methods -
extension TryItViewController: ClientsViewControllerDelegate {
    
    func didSelectClientImage(_ imageName: String, _ clientID: String) {
        print("Recived Image URL :::: \(imageName)")
        configure(with: imageName, clientID: clientID)
    }
    
    func configure(with client: String, clientID: String) {
        if let localImagePath = MenuViewModel.shared.loadLocalImagePath(clientID: clientID),
           let image = loadImageFromPath(localImagePath) {
            backgroundImage.image = image
        } else {
            backgroundImage.loadImage(from: .azureImageURL(basePath: .CLIENTS, fileName: client))
        }
    }
    
    private func loadImageFromPath(_ path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
}
