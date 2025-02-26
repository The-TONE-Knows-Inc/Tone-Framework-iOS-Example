//
//  MenuViewModel.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit
import FirebaseFirestore
import Kingfisher
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
        let db = Firestore.firestore()
        db.collection("demo").getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            
            if let err = err {
                print("Error fetching documents: \(err)")
                return
            }
            
            let fetchedClients = querySnapshot?.documents.compactMap { Client(data: $0.data()) } ?? []
            let activeClients = fetchedClients.filter { $0.isActive }
            
            DispatchQueue.main.async {
                self.saveClientsToLocalDB(clients: activeClients)
            }
            completion()
        }
    }
    
    private func saveClientsToLocalDB(clients: [Client]) {
        do {
            try realm.write {
                realm.delete(realm.objects(ClientObject.self))
                
                clients.forEach { client in
                    let clientObject = ClientObject(client: client)
                    realm.add(clientObject)
                    downloadAndSaveImages(for: clientObject)
                }
            }
            loadClientsFromLocalDB()
        } catch {
            print("Error saving clients to Realm: \(error)")
        }
    }
    
    private func downloadAndSaveImages(for client: ClientObject) {
        let imageURLs: [(String, (Data) -> Void)] = [
            (client.icon, { client.logoData = $0 }),
            (client.image, { client.demoImage = $0 })
        ]

        imageURLs.forEach { (urlString, dataHandler) in
            guard let url = URL(string: urlString) else { return }
            
            KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
                switch result {
                case .success(let value):
                    if let imageData = value.image.pngData() {
                        DispatchQueue.main.async {
                            do {
                                let realm = try Realm()
                                try realm.write {
                                    if let clientToUpdate = realm.object(ofType: ClientObject.self, forPrimaryKey: client.clientID) {
                                        dataHandler(imageData) // Update field safely
                                    }
                                }
                            } catch {
                                print("Error updating client image data: \(error)")
                            }
                        }
                    }
                case .failure(let error):
                    print("Failed to download image: \(error)")
                }
            }
        }
    }
}
