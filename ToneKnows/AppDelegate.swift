//
//  ToneKnowsApp.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 1/02/22.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navigationController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        setRootController(SplashViewController())
        UserDefaults.isFeatureFlagEnabled = FeatureFlagManager.shared.featureEnabled
        return true
    }
    
    func setRootController(_ viewController: UIViewController){
        window = UIWindow(frame: UIScreen.main.bounds)
        navigationController = UINavigationController(rootViewController: viewController)
        navigationController?.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
