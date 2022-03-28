//
//  MenuViewModel.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 2/02/22.
//

import SwiftUI
import Firebase

class MenuViewModel: ObservableObject {
    @Published var selectedMenu = ""
    @Published var showDrawer = false    
    @Published var clients = [Client]()
    
    func loadImageFromStorage() {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        db.collection("demos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let client = Client(data: document.data())
                    if client?.isActive == true {
                        self.clients.append(client!)
                    }                        
                }                
                if UserDefaults.standard.string(forKey: "clientID") ?? "0" == "0"{
                    UserDefaults.standard.set(self.clients.first?.clientID ?? "0", forKey: "clientID")
                    self.selectedMenu = self.clients.first?.name ?? ""
                } else {
                    self.selectedMenu = self.clients.filter({ client in
                        return client.clientID == UserDefaults.standard.string(forKey: "clientID")
                    }).first?.name ?? ""
                }
                NotificationCenter.default.post(name: NSNotification.Name("get_clients"), object: true)
            }
        }
    }
    init(){
        self.loadImageFromStorage()
    }
}

struct Client {
    var clientID: String
    var icon: String
    var image: String
    var name: String
    var isActive: Bool = false

    init?(data: [String: Any]) {
        guard let clientID = data["clientId"] as? String,
            let icon = data["icon"] as? String,
            let image = data["image"] as? String,
            let isActive = data["isActive"] as? Bool,
            let name = data["name"] as? String else {
                return nil
        }
        self.clientID = clientID
        self.icon = icon
        self.image = image
        self.name = name
        self.isActive = isActive
    }
}
