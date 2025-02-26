//
//  TryItViewController.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit
import RealmSwift

class TryItViewController: BaseViewController {
    
    override func initView() {
        super.initView()
        view.backgroundColor = .containerBackground
        configure(with: UserDefaults.isSelectedImageURL ?? "", clientID: UserDefaults.isSelectedClientID ?? "")
    }
    
    override func initAppearView() {
        super.initAppearView()
        if !(UserDefaults.isFrameworkRunning ?? false) {
            toneFramework.start()
            enableToneFrameworkFeatures()
            UserDefaults.isFrameworkRunning = true
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
        if let localImageData = loadLocalImage(clientID: clientID) {
            backgroundImage.image = UIImage(data: localImageData)
        } else {
            backgroundImage.kf.setImage(with: URL(string: client), placeholder: UIImage(named: "placeholder"))
        }
    }
    
    private func loadLocalImage(clientID: String) -> Data? {
        let realm = try? Realm()
        return realm?.object(ofType: ClientObject.self, forPrimaryKey: clientID)?.demoImage
    }
}
