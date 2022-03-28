//
//  Tone.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 16/02/22.
//
import RealmSwift
import Foundation
// LocalOnlyQsTask is the Task model for this QuickStart
class Tone: Object, Identifiable {
 
    @Persisted var actionDesc: String = ""
    @Persisted var toneSequence: String = ""
    @Persisted var actionURL: String = ""
    @Persisted var actionType: String = ""
    @Persisted var clientId: String = ""
    
    
    @Persisted var timestamp: String = ""
    
    convenience init(actionDesc: String, toneSequence: String, actionURL: String, actionType: String, clientId: String, timestamp: String) {
        self.init()
        self.actionType = actionType
        self.actionURL = actionURL
        self.clientId = clientId
        self.actionDesc = actionDesc
        self.toneSequence = toneSequence
        self.timestamp = timestamp
    }
}
