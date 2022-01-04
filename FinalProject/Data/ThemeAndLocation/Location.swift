//
//  LocationData.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/22.
//

import Foundation

class Location{
    
    var opened: Bool
    var title: String
    var sectionData: [String]
    
    init(opened: Bool, title: String, sectionData: [String]) {
        self.opened = opened
        self.title = title
        self.sectionData = sectionData
    }
}

class LocationData:Codable {
    var account: String
    var areID: String
}
