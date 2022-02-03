//
//  MenuViewModel.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 2/02/22.
//

import SwiftUI
import Firebase

class MenuViewModel: ObservableObject {
    @Published var selectedMenu = "test1"
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
                    self.clients.append(client!)
                }
                NotificationCenter.default.post(name: NSNotification.Name("get_clients"), object: true)
            }
        }
    }
    init(){
        
    }
}

struct Client {
    var clientID: String
    var icon: String
    var image: String
    var name: String

    init?(data: [String: Any]) {
        guard let clientID = data["clientID"] as? String,
            let icon = data["icon"] as? String,
            let image = data["image"] as? String,
            let name = data["name"] as? String else {
                return nil
        }
        self.clientID = clientID
        self.icon = icon
        self.image = image
        self.name = name
    }
}
