//
//  BaseViewController.swift
//  ToneDemo
//
//  Created by Balan iOS on 25/02/25.
//

import UIKit
import ToneListen

class BaseViewController: UIViewController {
    
    lazy var frequencyTableView: UITableView = {
        let tableView               = UITableView()
        tableView.backgroundColor   = .containerBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(FrequencyListCell.self, forCellReuseIdentifier: "FrequencyListCell")
        return tableView
    }()
    
    lazy var clientsTableView: UITableView = {
        let tableView               = UITableView()
        tableView.backgroundColor   = .containerBackground
        tableView.separatorStyle    = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ClientsListCell.self, forCellReuseIdentifier: "ClientsListCell")
        return tableView
    }()
    
    lazy var backgroundImage: UIImageView = {
        let view                = UIImageView()
        view.contentMode        = .scaleAspectFit
        view.clipsToBounds      = true
        view.backgroundColor    = .containerBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var emptyLabel: UILabel = {
        let label               = UILabel()
        label.text              = "No frequencies available"
        label.textColor         = .secondary
        label.textAlignment     = .center
        label.font              = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.isHidden          = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var emptyClientsLabel: UILabel = {
        let label               = UILabel()
        label.text              = "No clients available"
        label.textColor         = .secondary
        label.textAlignment     = .center
        label.font              = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.isHidden          = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var searchView: SearchTextFieldView = {
        let view = SearchTextFieldView()
        view.clearButton.addTarget(self, action: #selector(clearSearch), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    weak var delegate           : ClientsViewControllerDelegate?
    
    let viewModel           = MenuViewModel()
    let toneFramework       = ToneFramework.shared
    var isSearching         = false
    
    var clientID            : String { return UserDefaults.isSelectedClientID ?? "" }
    var filteredClients     : [ClientObject] = []
    var selectedIndexPath   : IndexPath?
    
    var toneDemoImage       : String    = ""
    var toneSequences       : [String]  = []
    
    override func loadView() {
        super.loadView()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initAppearView()
    }
    
    func initView() {
        view.backgroundColor = .containerBackground
        setupLayout()
    }
    
    func initAppearView() {
        
    }
    
    func setupLayout() {
        view.addSubview(searchView)
        view.addSubview(clientsTableView)
        view.addSubview(emptyClientsLabel)
        
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            clientsTableView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 10),
            clientsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            clientsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            clientsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            emptyClientsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyClientsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc private func handleTraitChange() {
        DispatchQueue.main.async {
            self.clientsTableView.reloadData()
        }
    }
    
    func handleOfflineMode(_ isEnable: Bool) {
        if isEnable {
            self.toneFramework.enableOfflineMode()
        } else {
            self.toneFramework.disableOfflineMode()
            self.toneFramework.deleteOfflineData()
        }
    }
    
    func enableToneFrameworkFeatures() {
        toneFramework.enableWifiDetection()
        toneFramework.enableBluetoothDetection()
        toneFramework.enableCarrierDetection()
    }
    
    @objc func clearSearch() {
        DispatchQueue.main.async {
            self.searchView.searchTextField.text = ""
            self.searchView.clearButton.isHidden = true
            self.searchView.searchTextField.resignFirstResponder()
            self.isSearching = false
            self.emptyClientsLabel.isHidden = true
            self.filteredClients.removeAll()
            self.clientsTableView.reloadData()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.handleTraitChange()
        }
    }
}
