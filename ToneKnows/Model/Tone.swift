//
//  Tone.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 16/02/22.
//

import Foundation

// LocalOnlyQsTask is the Task model for this QuickStart
class Tone: Identifiable {
    var actionDesc: String
    var toneSequence: String
    var actionURL: String
    var actionType: String
    var clientId: String
    var timestamp: String
    
    init(actionDesc: String, toneSequence: String, actionURL: String, actionType: String, clientId: String, timestamp: String) {
        self.actionDesc = actionDesc
        self.toneSequence = toneSequence
        self.actionURL = actionURL
        self.actionType = actionType
        self.clientId = clientId
        self.timestamp = timestamp
    }
}
