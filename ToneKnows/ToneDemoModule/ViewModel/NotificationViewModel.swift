//
//  NotificationViewModel.swift
//  ToneDemo
//
//  Created by Balan iOS on 21/02/25.
//

import UIKit
import ToneListen

class NotificationViewModel {
    
    var notifications   : String    = ""
    var imageData       : Data      = Data()
    var toneSequences   : [String]  = []
    var thereClients    : Bool?
    var responseContent : [String: Any]?
    
    var clientNotification  = NSNotification.Name("get_clients")
    var notificationName    = NotificationsHandler.notificationName
    var offlineToneNotification = NotificationsHandler.notificationImageData
    var responseObjectNotificationName = NotificationsHandler.responseObjectNotificationName
    
    weak var delegate   : NotificationViewModelDelegate?
    
    init() {
        observeNotifications()
    }
    
    func observeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleClientNotification(_:)), name: clientNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewNotification(_:)), name: notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleResponseContent(_:)), name: responseObjectNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOfflineNotification(_:)), name: offlineToneNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: clientNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
        NotificationCenter.default.removeObserver(self, name: responseObjectNotificationName, object: nil)
        NotificationCenter.default.removeObserver(self, name: offlineToneNotification, object: nil)
    }
    
    // MARK: - Notification Handlers
    @objc func handleClientNotification(_ notification: Notification) {
        if let value = notification.object as? Bool {
            thereClients = value
            delegate?.didUpdateClients(value)
        }
    }
    
    @objc func handleNewNotification(_ notification: Notification) {
        if let value = notification.object as? String {
            notifications = value
            delegate?.didReceiveNewNotification(value)
        }
    }
    
    @objc func handleOfflineNotification(_ notification: Notification) {
        if let value = notification.object as? Data {
            imageData = value
            delegate?.didReceiveOfflineNotification(imageData)
        }
    }
    
    @objc func handleResponseContent(_ notification: Notification) {
        if let value = notification.object as? [String: Any] {
            responseContent = value
            delegate?.didUpdateResponseContent(value)
            
            if let toneSequence = value["toneSequence"] as? String {
                toneSequences.append(toneSequence)
                delegate?.didUpdateToneSequences(toneSequences)
            }
        }
    }
}
