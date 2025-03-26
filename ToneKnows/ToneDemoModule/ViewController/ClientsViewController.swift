//
//  ClientsViewController.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit

class ClientsViewController: BaseViewController {
    
    lazy var refreshControlSegment: UIRefreshControl = {
        let controller = UIRefreshControl()
        controller.backgroundColor = .clear
        controller.tintColor = .secondary
        controller.addTarget(self, action: #selector(self.refreshViewModel), for: .valueChanged)
        return controller
    }()
    
    var clientList: [Client] = []
    
    weak var headerDelegate: HeaderViewDelegate?
    
    override func initView() {
        super.initView()
        clientsTableView.delegate           = self
        clientsTableView.dataSource         = self
        clientsTableView.refreshControl     = refreshControlSegment
        searchView.searchTextField.delegate = self
        fetchClientData()
    }
    
    func checkOfflineMode() {
        if let offlineMode = clientList.first(where: { $0.clientId == UserDefaults.isSelectedClientID })?.offlineMode {
            handleOfflineMode(offlineMode)
        } else {
            handleOfflineMode(false)
        }
    }
    
    override func initAppearView() {
        super.initAppearView()
        toneFramework.stop()
        UserDefaults.isFrameworkRunning = false
        toneFramework.setClientId(clientID: clientID)
    }
    
    func fetchClientData() {
        DispatchQueue.main.async {
            self.refreshControlSegment.endRefreshing()
            self.showLoadingIndicator()
            self.viewModel.fetchClients {
                self.dismissLoadingIndicator()
                self.clientList = self.viewModel.clients.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
                self.clientsTableView.reloadData()
                self.checkOfflineMode()
            }
        }
    }
    
    @objc func refreshViewModel() {
        DispatchQueue.main.async {
            self.refreshControlSegment.endRefreshing()
            self.showLoadingIndicator()
            self.viewModel.fetchClients {
                self.clientList = self.viewModel.clients.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending }
                self.dismissLoadingIndicator()
                self.clientsTableView.reloadData()
                self.checkOfflineMode()
            }
        }
    }
    
    func fetchClientDatas() {
        viewModel.loadClientsFromLocalDB()
        checkOfflineMode()
        clientsTableView.reloadData()
    }
}

extension ClientsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredClients.count : clientList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientsListCell", for: indexPath) as? ClientsListCell else {
            return UITableViewCell()
        }
        
        let client = isSearching ? filteredClients[indexPath.row] : clientList[indexPath.row]
        cell.selectionStyle = .none
        let isSelected = client.clientId == UserDefaults.isSelectedClientID
        cell.configure(with: client, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dispatchSelection(indexPath: indexPath)
    }
    
    func dispatchSelection(indexPath: IndexPath) {
        let selectedClient = isSearching ? filteredClients[indexPath.row] : clientList[indexPath.row]
        UserDefaults.isSelectedClientID = selectedClient.clientId
        UserDefaults.isSelectedImageURL = selectedClient.background
        toneFramework.setClientId(clientID: clientID)
        delegate?.didSelectClientImage(selectedClient.background ?? "", selectedClient.clientId ?? "")
        headerDelegate?.didSelectClient(selectedClient.name ?? "Tone Demo")
        checkOfflineMode()
        DispatchQueue.main.async {
            self.clientsTableView.reloadData()
        }
    }
}

extension ClientsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let searchText = updatedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if searchText.isEmpty {
            isSearching = false
            filteredClients.removeAll()
        } else {
            isSearching = true
            filteredClients = clientList.filter { client in
                let nameMatch = client.name?.lowercased().contains(searchText.lowercased())
                let idMatch = client.clientId?.lowercased().contains(searchText.lowercased())
                return nameMatch ?? false || idMatch ?? false
            }
        }
        emptyClientsLabel.isHidden = !isSearching || !filteredClients.isEmpty
        clientsTableView.reloadData()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        isSearching = false
        filteredClients.removeAll()
        emptyClientsLabel.isHidden = true
        clientsTableView.reloadData()
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
