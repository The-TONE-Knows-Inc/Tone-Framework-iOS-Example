//
//  ToneModel.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import Foundation

struct ToneClientsResponse: Codable {
    let data : [Client]
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

struct Client: Codable {
    var id          : Int?
    var name        : String?
    var logo        : String?
    var description : String?
    var background  : String?
    var governor    : Int?
    var clientType  : String?
    var clientId    : String?
    var status      : Bool?
    var logoData    : String?
    var demoImage   : String?
    
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
        case logoData
        case demoImage
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
