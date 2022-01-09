//
//  CustomTextField.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/14.
//

import UIKit

class CustomTextField: UITextField {

    var padding = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        self.layer.borderColor = UIColor(red: 255/255, green: 212/255, blue: 128/255, alpha: 1).cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        return rect.inset(by: padding)
        
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: padding)
    }
    
//    func settingTextField() {
//        self.layer.borderColor = UIColor(red: 255/255, green: 212/255, blue: 128/255, alpha: 1).cgColor
//        self.layer.borderWidth = 1
//        self.layer.cornerRadius = 10
//    }

}
