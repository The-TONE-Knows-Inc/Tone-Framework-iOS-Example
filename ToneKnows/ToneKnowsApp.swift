//
//  ToneKnowsApp.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 1/02/22.
//

import SwiftUI
import Firebase

@main
struct ToneKnowsApp: App {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
