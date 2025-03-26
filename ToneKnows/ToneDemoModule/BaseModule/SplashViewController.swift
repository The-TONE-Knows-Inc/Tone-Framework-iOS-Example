//
//  SplashViewController.swift
//  ToneKnows
//
//  Created by Balan iOS on 26/02/25.
//

import UIKit

class SplashViewController: UIViewController {
    
    lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = .headerLogo
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Know your frequencies"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var privacyButton: UIButton = {
        let button =  UIButton(type: .system)
        button.setTitle("Privacy Policy", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.navigateToSpect()
        }
    }
    
    func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(privacyButton)
        
        NSLayoutConstraint.activate([
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            privacyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            privacyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func openPrivacyPolicy() {
        if let url = URL(string: "https://thetoneknows.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    func navigateToSpect() {
        let mainVC = SpectrumViewController()
        navigationController?.pushViewController(mainVC, animated: true)
    }
}
