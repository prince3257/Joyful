//
//  PersonalData.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/19.
//

import Foundation

class PersonalData: Codable {
    
    var account : String
    var password: String
    var name: String
    var nickname : String
    var birthday: String?
    var avatar : String?
    var refreshToken: String?
}


