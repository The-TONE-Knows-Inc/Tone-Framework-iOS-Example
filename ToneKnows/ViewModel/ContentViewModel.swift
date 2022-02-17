//
//  ContentViewModel.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 1/02/22.
//

import Foundation
import Combine
import Firebase
import ToneListen
import RealmSwift


class ContentViewModel: ObservableObject {
    var notificationSub: AnyCancellable?
    var notificationClient: AnyCancellable?
    var notifications : String = ""  // Holds a list of notifications received from View2 via NotificationCenter
    var clientNotification = NSNotification.Name("get_clients")
    var notificationName = NotificationsHandler.notificationName
    var responseObjectNotificationName = NotificationsHandler.responseObjectNotificationName
    var responseSub: AnyCancellable?
    var tones: [Tone] = []
    // By publishing this property we can ensure that our subscriber (ContentView) will be
    // re-rendered when the property changes (i.e. whenever there's a new notification)
    @Published var newNotification: String? {
        didSet {
            guard newNotification != nil else { return }
            
            notifications = newNotification!
        }
    }
    @Published var thereClients: Bool? {
        didSet {
            guard thereClients != nil else { return }
        }
    }
    
    @Published var responseContent: [String : Any]? {
        didSet {
            guard responseContent != nil else { return }
        }
    }
    
    init() {
        // Open the default realm
        
        loadActions()
        
        notificationClient = NotificationCenter.default.publisher(for: clientNotification)
            .map { notification in notification.object as? Bool }   // Transform the notification into a simple string
            .assign(to: \ContentViewModel.thereClients, on: self)  // Assign the msg to a property using a keypath
        // Subscribe to "View2Msg" messages broadcast by NotificationCenter
        notificationSub = NotificationCenter.default.publisher(for: notificationName)
            .map { notification in notification.object as? String }   // Transform the notification into a simple string
            .assign(to: \ContentViewModel.newNotification, on: self)  // Assign the msg to a property using a keypath
        
        responseSub = NotificationCenter.default.publisher(for: responseObjectNotificationName)
            .map { notification in notification.object as? [String : Any] }   // Transform the notification into a simple string
            .assign(to: \ContentViewModel.responseContent, on: self)  // Assign the msg to a property using a keypath
        
    }
    
    func loadActions() {
        do {
            let realm = try Realm()
            if UserDefaults.standard.string(forKey: "clientID") ?? "0" != "0" {
                let listTones = realm.objects(Tone.self)
                let clientTones = listTones.where {
                    $0.clientId == UserDefaults.standard.string(forKey: "clientID")!
                }.sorted(byKeyPath: "timestamp", ascending: false)
                tones = clientTones.toArray(ofType: Tone.self)
            }
        } catch _ as NSError {
            // Handle error
        }
    }
    func saveResponse(content: [String : Any]) {
        do {
            let realm = try Realm()
            let tones = realm.objects(Tone.self)
            let tone = Tone(value: content)
            tone.timestamp = String(Date.currentTimeStamp)
            let clientTones = tones.where {
                ($0.toneSequence == tone.toneSequence) && ($0.actionDesc == tone.actionDesc)
                
            }
            
            if clientTones.isEmpty {
                try! realm.write {
                    // Add the instance to the realm.
                    realm.add(tone)
                }
            }
            loadActions()
        } catch _ as NSError {
            // Handle error
        }
    }
}


extension String: Identifiable {
    public var id: String {
        return UUID().uuidString
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }

        return array
    }
}

extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
