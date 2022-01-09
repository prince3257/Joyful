//
//  TopicDataUpload.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/27.
//

import Foundation
struct TopicDataUpload: Codable{
    var themeId : Int
    var subject : String
    var account : String
    var wordContent : String
    var picture : String?
    var nickname: String
    var likeCount: Int
}
