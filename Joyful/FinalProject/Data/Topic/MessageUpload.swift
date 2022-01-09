//
//  MessageUpload.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/28.
//

import Foundation

struct MessageUpload: Codable {
    var articleId : Int
    var account : String
    var nickname : String
    var wordContent : String
}
