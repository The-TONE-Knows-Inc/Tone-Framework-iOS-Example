//
//  MenuViewModel.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit
import ToneListen
import RealmSwift

class MenuViewModel {
    var selectedMenu: String = ""
    var clients: [ClientObject] = []
    let realm = try! Realm()
    
    init() {
        loadClientsFromLocalDB()
    }
    
    func loadClientsFromLocalDB() {
        let savedClients = realm.objects(ClientObject.self)
        clients = savedClients.map { ClientObject(value: $0) }
    }
    
    func fetchClients(completion: @escaping () -> Void) {
        NetworkRequests.fetchClientData { result in
            
            switch result {
                case .success(let data):
                    
                    if let firstClientID = data.first?.clientId {
                        if UserDefaults.isSelectedClientID == nil || UserDefaults.isSelectedClientID == "" {
                            UserDefaults.isSelectedClientID = firstClientID
                            UserDefaults.isSelectedImageURL = data.first?.background ?? ""
                        } else {
                            if let storedClientID = UserDefaults.isSelectedClientID {
                                UserDefaults.isSelectedImageURL = data.first(where: { $0.clientId == storedClientID })?.background ?? ""
                            } else {
                                print(":::: UserDefaults: clientID is nil ::::")
                            }
                        }
                    }
                    
                    self.downloadAndPrepareClients(clients: data) {
                        completion()
                    }
                case .failure(let error):
                    print("\n======================== FAILURE =======================")
                    print("\n===========================================================================\n")
                    print(error.localizedDescription)
                    print("\n===========================================================================\n")
                    completion()
            }
        }
    }
    
    private func downloadAndPrepareClients(clients: [Client], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        var processedClients: [ClientObject] = []
        
        for client in clients {
            let clientObject = ClientObject(client: client)
            
            // Track download of images
            dispatchGroup.enter()
            downloadImages(for: clientObject) { updatedClient in
                processedClients.append(updatedClient)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.saveClientsToLocalDB(clients: processedClients)
            completion()
        }
    }
    
    private func downloadImages(for client: ClientObject, completion: @escaping (ClientObject) -> Void) {
        let imageURLs: [(String, (Data) -> Void)] = [
            (String.AZURE_STORAGE_BASE_URL + String.LOGO + client.icon + String.AZURE_STORAGE_URL_STRING, { client.logoData = $0 }),
            (String.AZURE_STORAGE_BASE_URL + String.CLIENTS + client.image + String.AZURE_STORAGE_URL_STRING, { client.demoImage = $0 })
        ]
        
        let dispatchGroup = DispatchGroup()
        
        for (urlString, dataHandler) in imageURLs {
            guard let url = URL(string: urlString) else {
                print("Invalid URL: \(urlString)")
                continue
            }
            
            dispatchGroup.enter()
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                defer { dispatchGroup.leave() }
                
                if let error = error {
                    print("Failed to download image from \(urlString): \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, !data.isEmpty else {
                    print("Received empty data from \(urlString)")
                    return
                }
                
                DispatchQueue.main.async {
                    dataHandler(data)
                }
            }
            task.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(client)
        }
    }
    
    private func saveClientsToLocalDB(clients: [ClientObject]) {
        do {
            try realm.write {
                realm.delete(realm.objects(ClientObject.self))
                clients.forEach { realm.add($0) }
            }
            loadClientsFromLocalDB()
        } catch {
            print("Error saving clients to Realm: \(error)")
        }
    }
    
    func fetchClientsFromBackend() {
        
    }
}
