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
        db.collection("demo").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let client = Client(data: document.data())
                    if client?.isActive == true {
                        self.clients.append(client!)
                    }
                }
                if let firstClientID = self.clients.first?.clientID {
                    if UserDefaults.standard.string(forKey: "clientID") == nil || UserDefaults.standard.string(forKey: "clientID") == "" {
                        UserDefaults.standard.set(firstClientID, forKey: "clientID")
                        self.selectedMenu = self.clients.first?.name ?? ""
                    } else {
                        if let storedClientID = UserDefaults.standard.string(forKey: "clientID") {
                            self.selectedMenu = self.clients.first(where: { $0.clientID == storedClientID })?.name ?? ""
                        } else {
                            print(":::: UserDefaults: clientID is nil ::::")
                        }
                    }
                } else {
                    print(":::: No clients available. ::::")
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
