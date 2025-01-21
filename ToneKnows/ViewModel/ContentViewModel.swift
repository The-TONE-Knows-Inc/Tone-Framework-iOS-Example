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


class ContentViewModel: ObservableObject {
    var notificationSub: AnyCancellable?
    var notificationClient: AnyCancellable?
    var notifications : String = ""  // Holds a list of notifications received from View2 via NotificationCenter
    var clientNotification = NSNotification.Name("get_clients")
    var notificationName = NotificationsHandler.notificationName
    var notificationImageData = NotificationsHandler.notificationImageData
    @Published var dataResponse: [String] = []
    
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
            if responseContent != nil {
                dataResponse.append(responseContent?["toneSequence"]  as? String ?? "")
            }else{
                return
            }
        }
    }
    
    init() {
        // Open the default realm
        
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
}

extension String: Identifiable {
    public var id: String {
        return UUID().uuidString
    }
}

extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
