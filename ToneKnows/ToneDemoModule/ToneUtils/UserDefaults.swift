//
//  UserDefaults.swift
//  ToneDemo
//
//  Created by Balan iOS on 24/02/25.
//

import Foundation

extension UserDefaults {

    @UserDefault(key: "is_client_id_key", defaultValue: nil)
    static var isSelectedClientID: String?
    
    @UserDefault(key: "is_selected_client_id_key", defaultValue: nil)
    static var isSelectedImageURL: String?
    
    @UserDefault(key: "is_feature_flag_enabled", defaultValue: nil)
    static var isFeatureFlagEnabled: Bool?
    
    @UserDefault(key: "is_framework_running", defaultValue: nil)
    static var isFrameworkRunning: Bool?
    
    static func removeAll(){
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard
    
    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                container.removeObject(forKey: key)
            } else {
                container.set(newValue, forKey: key)
                container.synchronize()
            }
        }
    }
}

protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

extension UserDefault where Value: ExpressibleByNilLiteral {
    init(key: String, _ container: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, container: container)
    }
}
