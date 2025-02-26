//
//  ClientsViewController.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit

class ClientsViewController: BaseViewController {
    
    override func initView() {
        super.initView()
        clientsTableView.delegate           = self
        clientsTableView.dataSource         = self
        searchView.searchTextField.delegate = self
        fetchClientData()
        FeatureFlagManager.shared.getClientId { result in
            self.handleOfflineMode(result)
        }
    }
    
    override func initAppearView() {
        super.initAppearView()
        toneFramework.stop()
        UserDefaults.isFrameworkRunning = false
        toneFramework.setClientId(clientID: clientID)
    }
    
    func fetchClientData() {
        self.viewModel.loadClientsFromLocalDB()
        self.clientsTableView.reloadData()
        
        // Fetch new data from Firestore and update local storage
        self.viewModel.fetchClients {
            DispatchQueue.main.async {
                self.clientsTableView.reloadData()
            }
        }
    }
}

extension ClientsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredClients.count : viewModel.clients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientsListCell", for: indexPath) as? ClientsListCell else {
            return UITableViewCell()
        }
        
        let client = isSearching ? filteredClients[indexPath.row] : viewModel.clients[indexPath.row]
        cell.selectionStyle = .none
        let isSelected = client.clientID == UserDefaults.isSelectedClientID
        cell.configure(with: client, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dispatchSelection(indexPath: indexPath)
        tableView.reloadData()
    }
    
    func dispatchSelection(indexPath: IndexPath) {
        let selectedClient = isSearching ? filteredClients[indexPath.row] : viewModel.clients[indexPath.row]
        UserDefaults.isSelectedClientID = selectedClient.clientID
        UserDefaults.isSelectedImageURL = selectedClient.image
        toneFramework.setClientId(clientID: clientID)
        delegate?.didSelectClientImage(selectedClient.image, selectedClient.clientID)
        FeatureFlagManager.shared.getClientId { result in
            self.handleOfflineMode(result)
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
            filteredClients = viewModel.clients.filter { client in
                let nameMatch = client.name.lowercased().contains(searchText.lowercased())
                let idMatch = client.clientID.lowercased().contains(searchText.lowercased())
                return nameMatch || idMatch
            }
        }
        
        clientsTableView.reloadData()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        isSearching = false
        filteredClients.removeAll()
        clientsTableView.reloadData()
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
