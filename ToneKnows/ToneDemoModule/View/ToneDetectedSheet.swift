//
//  ToneDetectedSheet.swift
//  ToneDemo
//
//  Created by Balan iOS on 21/02/25.
//

import UIKit

class ToneDetectedSheet: UIViewController {
    
    var imageURL: String?
    var imageData : Data? = Data()
    
    init(imageURL: String? = nil, imageData: Data? = nil) {
        self.imageURL = imageURL
        self.imageData = imageData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var imageView: CustomImageView = {
        let view            = CustomImageView()
        view.contentMode    = .scaleToFill
//        view.clipsToBounds  = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label           = UILabel()
        label.text          = "TAG Content"
        label.textAlignment = .center
        label.font          = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor     = .secondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.tabtint, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .containerBackground
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let imageURL = imageURL, !imageURL.isEmpty {
            imageView.setImage(from: imageURL)
        } else {
            if let imageData = imageData {
                imageView.image = UIImage(data: imageData)
            }
        }
    }
    
    func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(backButton)
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            backButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func dismissSheet() {
        dismiss(animated: true, completion: nil)
    }
}
