//
//  Extension.swift
//  Raja
//
//  Created by apple on 17/06/22.
//

import Foundation
import UIKit

extension UIView {
    public var cornerRadius:CGFloat{
        
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
    }
    
    //MARK: Rounded Corner Radius
    func RoundedCornerRadius(){
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}
