//
//  CustomLabel.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/14.
//

import UIKit

class CustomLabel: UILabel {
    
    let padding = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
}
