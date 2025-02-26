//
//  ToneBaseViewController.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit

class MainViewController: UIViewController {
    
    lazy var customTabBar: CustomTabBarView = {
        let tabBarView = CustomTabBarView()
        tabBarView.delegate = self
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        return tabBarView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .containerBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var headerView: HeaderView = {
        let view = HeaderView()
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let latLabel: UILabel = {
        let label           = UILabel()
        label.textColor     = .secondary
        label.font          = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .left
        label.text          = "Latitude: --"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let longLabel: UILabel = {
        let label           = UILabel()
        label.textColor     = .secondary
        label.font          = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .left
        label.text          = "Latitude: --"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let clientsTab      = UITabBarItem(title: "Clients", image: UIImage(systemName: "person.3"), tag: 0)
    private let tryItTab        = UITabBarItem(title: "Try It", image: UIImage(systemName: "play.circle"), tag: 1)
    private let frequencyTab    = UITabBarItem(title: "Frequency", image: UIImage(systemName: "waveform"), tag: 2)
    
    let clientsVC       = ClientsViewController()
    let tryItVC         = TryItViewController()
    let frequencyVC     = FrequencyViewController()
    let viewModel       = NotificationViewModel()
    let locationManager = LocationManager()
    let sheetPresenter  = SheetPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .containerBackground
        initialSetup()
    }
    
    func initialSetup() {
        setupLayout()
        setupViewControllers()
        setDelegates()
        switchToViewController(.clientsVC)
        locationManager.requestLocation()
    }
    
    func setDelegates() {
        clientsVC.delegate = tryItVC
        viewModel.delegate = self
        headerView.delegate = self
        locationManager.delegate = self
    }
    
    private func setupLayout() {
        view.addSubview(headerView)
        view.addSubview(latLabel)
        view.addSubview(longLabel)
        view.addSubview(containerView)
        view.addSubview(customTabBar)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            latLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            latLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            latLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            longLabel.topAnchor.constraint(equalTo: latLabel.bottomAnchor, constant: 10),
            longLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            longLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            containerView.topAnchor.constraint(equalTo: longLabel.bottomAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: customTabBar.topAnchor),
            
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setupViewControllers() {
        addChild(clientsVC)
        addChild(tryItVC)
        addChild(frequencyVC)
        
        clientsVC.didMove(toParent: self)
        tryItVC.didMove(toParent: self)
        frequencyVC.didMove(toParent: self)
    }
    
    func switchToViewController(_ viewControllerType: ViewControllers) {
        
        let viewController: UIViewController
        
        switch viewControllerType {
            case .clientsVC   : viewController = clientsVC
            case .tryItVC     : viewController = tryItVC
            case .frequencyVC : viewController = frequencyVC
        }
        
        headerView.setTitle(viewControllerType.title)
        
        for subview in containerView.subviews {
            subview.removeFromSuperview()
        }
        
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        addChild(viewController)
        viewController.didMove(toParent: self)
        
        customTabBar.updateSelectedTab(viewControllerType)
    }
    
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - CustomTabBarDelegate -
extension MainViewController: CustomTabBarDelegate {
    func didSelectTab(_ tab: ViewControllers) {
        switchToViewController(tab)
    }
}

// MARK: - BackButtonDelegate -
extension MainViewController: BackButtonDelegate {
    func backButtonAction() {
        backButtonTapped()
    }
}

// MARK: - NotificationViewModelDelegate -
extension MainViewController: NotificationViewModelDelegate {
    
    func didReceiveNewNotification(_ notification: String) {
        sheetPresenter.handleImageDataNotification(imageURL: notification)
    }
    
    func didUpdateClients(_ hasClients: Bool) {
        print("Clients Available: \(hasClients)")
    }
    
    func didUpdateResponseContent(_ content: [String: Any]) {
        print("Updated Response Content: \(content)")
    }
    
    func didUpdateToneSequences(_ toneSequences: [String]) {
        frequencyVC.didUpdateToneSequences(toneSequences)
    }
    
    func didReceiveOfflineNotification(_ notification: Data) {
        sheetPresenter.handleImageDataNotification(imageData: notification)
    }
}

// MARK: - LocationManagerDelegate -
extension MainViewController: LocationManagerDelegate {
    
    func didUpdateLocation(_ Latitude: String, _ Longitude: String) {
        self.latLabel.text = "Latitude: \(Latitude)"
        self.longLabel.text = "Longitude: \(Longitude)"
    }
    
    func didFailWithError(_ error: String) {
        DispatchQueue.main.async {
            self.latLabel.text = "Latitude: --"
            self.longLabel.text = "Longitude: --"
        }
    }
}
