//
//  ToneModel.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import Foundation
import RealmSwift

struct Client {
    var clientID: String
    var icon: String
    var image: String
    var name: String
    var isActive: Bool
    
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

class ClientObject: Object {
    @Persisted(primaryKey: true) var clientID: String = ""  // Set as primary key
    @Persisted var icon: String = ""
    @Persisted var image: String = ""
    @Persisted var name: String = ""
    @Persisted var isActive: Bool = false
    @Persisted var logoData: Data?
    @Persisted var demoImage: Data?

    convenience init(client: Client) {
        self.init()
        self.clientID = client.clientID
        self.icon = client.icon
        self.image = client.image
        self.name = client.name
        self.isActive = client.isActive
    }
}

enum ViewControllers {
    case clientsVC
    case tryItVC
    case frequencyVC
    
    var title: String {
        switch self {
            case .clientsVC:
                return "Client Names"
            case .tryItVC:
                return "Tone Demo"
            case .frequencyVC:
                return "Frequency List"
        }
    }
}
