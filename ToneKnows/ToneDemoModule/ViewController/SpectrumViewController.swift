//
//  SpectrumViewController.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit
import CoreLocation
import FirebaseFirestore

class SpectrumViewController: UIViewController {
    
    lazy var gearButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "gear")
        config.baseForegroundColor = .black
        config.background.backgroundColor = .cyan
        config.background.cornerRadius = 25
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openSettings(_:)), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.isHidden = true
        return button
    }()
    
    lazy var backgroundImage: UIImageView = {
        let view                = UIImageView()
        view.backgroundColor    = .clear
        view.image              = .backgroundGraph
        view.contentMode        = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var latLabel: UILabel = {
        let label           = UILabel()
        label.textColor     = .white
        label.font          = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        label.text          = "Latitude: Fetching Latitude.."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var longLabel: UILabel = {
        let label           = UILabel()
        label.textColor     = .white
        label.font          = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        label.text          = "Longitude: Fetching Longitude.."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var frequencyLabel: UILabel = {
        let label           = UILabel()
        label.textColor     = .white
        label.font          = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.text          = "Frequency: Fetching Frequency.."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var spectrumView: SpectrumAnalyzerView = {
        let view = SpectrumAnalyzerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let permissionManager   = PermissionManager()
    let locationManager     = LocationManager()
    let audioProcessor      = AudioProcessor()
    let featureFlagManager  = FeatureFlagManager()
    let viewModel           = MenuViewModel()
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .black
        permissionManager.checkMicrophonePermission()
        viewModel.fetchClientsFromBackend()
        setupUI()
        locationManager.delegate = self
        gearButton.isHidden = UserDefaults.isFeatureFlagEnabled ?? true
        CheckFrequencyAndLocation()
    }
    
    fileprivate func CheckFrequencyAndLocation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateFrequency()
        }
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.locationManager.requestLocation()
        }
    }
    
    func setupUI() {
        view.addSubview(backgroundImage)
        view.addSubview(latLabel)
        view.addSubview(longLabel)
        view.addSubview(frequencyLabel)
        view.addSubview(spectrumView)
        view.addSubview(gearButton)
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            latLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            latLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            latLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            longLabel.topAnchor.constraint(equalTo: latLabel.bottomAnchor, constant: 10),
            longLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            longLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            frequencyLabel.topAnchor.constraint(equalTo: longLabel.bottomAnchor, constant: 20),
            frequencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            frequencyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            spectrumView.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor, constant: 10),
            spectrumView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            spectrumView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            spectrumView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            
            gearButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 180),
            gearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            gearButton.widthAnchor.constraint(equalToConstant: 44),
            gearButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func openSettings(_ sender: UIButton) {
        let vc = MainViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SpectrumViewController {
    
    private func updateFrequency() {
        let frequency = audioProcessor.maxFrequency
        DispatchQueue.main.async {
            let magnitudes = self.audioProcessor.frequencyMagnitudes
            self.spectrumView.updateMagnitudeData(magnitudes)
            self.frequencyLabel.text = "Frequency: \(String(format: "%.2f", frequency)) Hz"
        }
    }
}

// MARK: - LocationManagerDelegate
extension SpectrumViewController: LocationManagerDelegate {
    
    func didUpdateLocation(_ Latitude: String, _ Longitude: String) {
        UserDefaults.isLatitude = Latitude
        UserDefaults.isLongitude = Longitude
        setLatAndLong()
    }
    
    func setLatAndLong() {
        DispatchQueue.main.async {
            self.latLabel.text = "Latitude: \(UserDefaults.isLatitude ?? "Latitude: Fetching Latitude..")"
            self.longLabel.text = "Longitude: \(UserDefaults.isLongitude ?? "Longitude: Fetching Longitude..")"
        }
    }
    
    func didFailWithError(_ error: String) {
        DispatchQueue.main.async {
            self.latLabel.text = "Latitude: Fetching Latitude.."
            self.longLabel.text = "Longitude: Fetching Longitude.."
        }
    }
}
