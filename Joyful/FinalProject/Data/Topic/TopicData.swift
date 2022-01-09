//
//  HotTopicData.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/19.
//

import Foundation

//找出誰收藏這篇文章
class TopicData: Codable{
    var article: TopicOutter
    var collectedAcount:String?
}

//找出誰喜歡這篇文章
class TopicOutter: Codable {
    var article: TopicContent
    var likedAcount: String?
}

//文章核心
class TopicContent:Codable {
    var account : String
    var articleId : Int?
    var date : String
    var subject : String
    var likeCount: Int
    var nickname: String
    var picture : String?
    var wordContent : String
    var theme : String
    var avatar: String?
}
