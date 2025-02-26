//
//  ToneKnowsApp.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 1/02/22.
//

import UIKit
import Firebase
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navigationController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        setRootController(SpectrumViewController())
        UserDefaults.isFeatureFlagEnabled = FeatureFlagManager.shared.featureEnabled
        configureRealmMigration()
        return true
    }
    
    func setRootController(_ viewController: UIViewController){
        window = UIWindow(frame: UIScreen.main.bounds)
        navigationController = UINavigationController(rootViewController: viewController)
        navigationController?.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func configureRealmMigration() {
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // Realm will automatically detect and handle new primary keys.
                    // No explicit migration logic needed for adding primary keys.
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
        // Initialize Realm to apply the migration
        _ = try! Realm()
    }
}
