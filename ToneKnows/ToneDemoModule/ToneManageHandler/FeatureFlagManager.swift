//
//  FeatureFlagManager.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import FirebaseFirestore

class FeatureFlagManager {
    
    static let shared = FeatureFlagManager()
    var featureEnabled: Bool = false
    private var db = Firestore.firestore()
    
    init() {
        fetchFeatureFlag()
    }
    
    func fetchFeatureFlag() {
        let docRef = db.collection("settings").document("2mFXFqDjUCBlJnaTDP8z")

        docRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.featureEnabled = dataDescription?["featureEnabled"] as? Bool ?? false
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getClientId(completion: @escaping (Bool) -> Void) {
        let databaseAuth = Firestore.firestore()
        var result: Bool = false
        let documentReference = databaseAuth.collection("onlineClients").document("Z0bSkI7ywrXgSRJW5TrN")
        
        documentReference.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                DispatchQueue.main.async {
                    let dataDes = dataDescription?["client"] as? String ?? ""
                    let dataClient = dataDes.data(using: .utf8) ?? Data()
                    let dataJson = try? JSONSerialization.jsonObject(with: dataClient, options: []) as? [String: Any]
                    
                    if let onlineClientId = dataJson?["onlineClientId"] as? [String] {
                        let onlineClientIds: [String] = onlineClientId
                        let enteredClientId = UserDefaults.isSelectedClientID ?? ""
                        result = onlineClientIds.contains(enteredClientId)
                        print("The result for client id is ----------------------------------------------->", result)
                    }
                    completion(result)
                }
            } else {
                print("Document does not exist")
                completion(false)
            }
        }
    }
}
