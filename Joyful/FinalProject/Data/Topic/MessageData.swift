//
//  MessageData.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/22.
//

import Foundation

struct MessageData: Codable {
    var message: MessageContent
    var likedAcount: String?
    
}

class MessageContent: Codable {
    var account : String
    var articleId : Int
    var likeCount : Int
    var messageId : Int
    var nickname : String
    var wordContent : String
    var avatar: String?
}
