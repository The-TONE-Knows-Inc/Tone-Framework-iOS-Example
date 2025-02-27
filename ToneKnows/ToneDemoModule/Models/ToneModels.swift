//
//  ToneModel.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import Foundation
import RealmSwift

struct ToneClientsResponse: Codable {
    let data : [Client]
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

struct Client: Codable {
    let id          : Int?
    let name        : String?
    let logo        : String?
    let description : String?
    let background  : String?
    let governor    : Int?
    let clientType  : String?
    let clientId    : String?
    let status      : Bool?
    
    enum CodingKeys: String, CodingKey {
        case id             = "id"
        case name           = "name"
        case logo           = "logo"
        case description    = "description"
        case background     = "background"
        case governor       = "governor"
        case clientType     = "clientType"
        case clientId       = "clientId"
        case status         = "status"
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
        self.clientID = client.clientId ?? ""
        self.icon = client.logo ?? ""
        self.image = client.background ?? ""
        self.name = client.name ?? ""
        self.isActive = client.status ?? false
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
