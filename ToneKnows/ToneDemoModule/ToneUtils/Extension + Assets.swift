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
