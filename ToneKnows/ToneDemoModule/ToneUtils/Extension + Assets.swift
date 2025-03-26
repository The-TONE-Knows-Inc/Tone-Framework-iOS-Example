//
//  Extension + UIImage.swift
//  ToneKnows
//
//  Created by Balan iOS on 26/02/25.
//

import UIKit

extension UIImage {
    
    static var backgroundGraph : UIImage {
        return #imageLiteral(resourceName: "BackgroundGraph")
    }
    
    static var backIconBlack : UIImage {
        return #imageLiteral(resourceName: "BackIconBlack")
    }
    
    static var backIcon : UIImage {
        return #imageLiteral(resourceName: "BackIcon")
    }
    
    static var headerLogo : UIImage {
        return #imageLiteral(resourceName: "HeaderLogo")
    }
}

extension UIColor {
    
    static var containerBackground : UIColor {
        return UIColor(named: "containerBackground") ?? .black
    }
    
    static var clientDarkBack : UIColor {
        return UIColor(named: "clientDarkBack") ?? .black
    }
    
    static var clientWhiteBack : UIColor {
        return UIColor(named: "clientWhiteBack") ?? .white
    }
    
    static var primary : UIColor {
        return UIColor(named: "PrimaryColor") ?? .black
    }
    
    static var secondary : UIColor {
        return UIColor(named: "SecondaryColor") ?? .white
    }
    
    static var tabtint : UIColor {
        return UIColor(named: "tabtint") ?? .cyan
    }
}

extension String {
    static let AZURE_STORAGE_BASE_URL = "https://tonedashboardsa.blob.core.windows.net/production-tone/"
    static let AZURE_STORAGE_URL_STRING = "?sp=racwl&st=2025-02-22T07:54:53Z&se=2027-12-31T15:54:53Z&spr=https&sv=2022-11-02&sr=c&sig=5DK9YiV6lXnWK855jJshUAjLGQEvPBUe3W8t1%2BCabc0%3D"
    static let LOGO = "logo/"
    static let CLIENTS = "clients/"
    
    static func azureImageURL(basePath: String, fileName: String) -> String {
        return String.AZURE_STORAGE_BASE_URL + basePath + fileName + String.AZURE_STORAGE_URL_STRING
    }
}

extension UIViewController{
    
    private func getLoaderController() -> UIViewController {
        
        var privateSharedInstance: ProgressIndicator?
        
        if privateSharedInstance == nil {
            privateSharedInstance = ProgressIndicator()
            return privateSharedInstance!
        }
        return privateSharedInstance!
    }
    
    func showLoadingIndicator(_ completion: (() -> Void)? = nil) {
        let vc = getLoaderController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false) {
            completion?()
        }
    }
    
    func dismissLoadingIndicator(_ completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            guard let presentController = self.presentedViewController as? ProgressIndicator else{
                completion?()
                return
            }
            self.dismissPresentedController(presentController, completion: completion)
        }
    }
    
    func dismissPresentedController(_ controller: ProgressIndicator, completion: (() -> Void)?) {
        self.dismiss(animated: false) {
            controller.dismiss(animated: false) {
                completion?()
            }
        }
    }
}
