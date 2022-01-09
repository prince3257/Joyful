//
//  ThemeData.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/22.
//

import Foundation

class Theme {
    
    var title: String
    var imageurl: String
    
    init(title: String, imageurl: String) {
        self.title = title
        self.imageurl = imageurl
    }
    
}

class ThemeData: Codable{
    var account: String
    var interestArr: [String]
}

