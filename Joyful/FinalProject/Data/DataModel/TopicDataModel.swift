//
//  TopiceDataModel.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/22.
//

import Foundation
import UIKit


protocol TopicDataModelDelegate: AnyObject{
    func updateTopicData()
}

class TopicDataModel {

    static var shared = TopicDataModel()
    
    private init() {}
    
    weak var delegate: TopicDataModelDelegate?

    var hotTopic: [TopicData] = []
    
    var allTopic: [TopicData] = []
    
    var postTopic: [TopicContent] = []
    
    var collectTopic: [TopicContent] = []
        
    var currentArticleMessage: [MessageData] = []
    
    var specificArticle: TopicData?
    
    // MARK: 取得資料區
    
    // 取得篩選文章資料
    func fetchAllTopicData(page: Int) {
        APIManager.shared.getTopicData(topicType: .PersonalTopic, page: page) { response in
            switch response {
            case .success(let data):
                if page == 1{
                    self.allTopic = data
                } else {
                    self.allTopic += self.consolidateTopic(topicType: .PersonalTopic, topics: data)
                }
                self.delegate?.updateTopicData()
            case .failure(_):
                break
            }
        }
    }
        
    // 取的篩選熱門文章資料
    func fetchHotTopicData(page: Int) {
        APIManager.shared.getTopicData(topicType: .HotTopic,page: page) { response in
            switch response {
            case .success(let data):
                if page == 1{
                    self.hotTopic = data
                } else {
                    self.hotTopic += self.consolidateTopic(topicType: .HotTopic, topics: data)
                }
                self.delegate?.updateTopicData()
            case .failure(_):
                break
            }
        }
    }
    
    //取得點選文章的留言
    func getArticleMessage(atricleID: Int, page: Int) {
        APIManager.shared.getTopicMessageData(articleID: atricleID, page: page) { response in
            switch response {
            case .success(let data):
                if page == 1{
                    self.currentArticleMessage = data
                } else {
                    self.currentArticleMessage += self.consolidateMessage(messages: data)
                }
                if self.currentArticleMessage.count > 0 {
                    self.delegate?.updateTopicData()
                }
            case .failure(_):
                break
            }
        }
    }
    
    //取得按發布、收藏的文章 - 版本一
    func getPersonalRelatedArticle(type: ArticleType,page:Int) {
        APIManager.shared.getPersonalRelatedArticle(page: page, articleType: type) { response in
            switch response {
            case .success(let data):
                if page == 1{
                    switch type {
                    case .Posted:
                        self.postTopic = data
                    case .Collected:
                        self.collectTopic = data
                    }
                } else {
                    switch type {
                    case .Posted:
                        self.postTopic += self.consolidatePersonalTopic(topicType:.Posted, topics: data)
                    case .Collected:
                        self.collectTopic += self.consolidatePersonalTopic(topicType: .Collected, topics: data)
                    }
                }
                self.delegate?.updateTopicData()
            case .failure(_):
                break
            }
        }
    }
    
    //取得按發布、收藏的文章 - 版本二
    func getSpecificArticle(topicID: Int) {
        APIManager.shared.getSpecificTopicData(topicID: topicID) { response in
            switch response {
            case .success(let data):
                self.specificArticle = data.first
                self.delegate?.updateTopicData()
            case .failure(_):
                break
            }
        }
    }
    
    //整理文章資料(熱門追蹤)
    private func consolidateTopic(topicType: TopicType ,topics: [TopicData]) -> [TopicData] {
        var newOne:[TopicData] = []
        for i in 0..<topics.count {
            let topic = topics[i]
            switch topicType {
            case .HotTopic:
                if hotTopic.contains(where: { hottopic in
                    hottopic.article.article.articleId != topic.article.article.articleId
                }) {
                    newOne.append(topic)
                }
            case .PersonalTopic:
                if allTopic.contains(where: { alltopic in
                    alltopic.article.article.articleId != topic.article.article.articleId
                }) {
                    newOne.append(topic)
                }
            }
            
        }
        return newOne
    }
    
    //整理文章資料(收藏發布)
    private func consolidatePersonalTopic(topicType: ArticleType ,topics: [TopicContent]) -> [TopicContent] {
        var newOne:[TopicContent] = []
        for i in 0..<topics.count {
            let topic = topics[i]
            switch topicType {
            case .Posted:
                if postTopic.contains(where: { posttopic in
                    posttopic.articleId != topic.articleId
                }) {
                    newOne.append(topic)
                }
            case .Collected:
                if collectTopic.contains(where: { collecttopic in
                    collecttopic.articleId != topic.articleId
                }) {
                    newOne.append(topic)
                }
            }
        }
        return newOne
    }
    
    
    //整理留言資料
    private func consolidateMessage(messages: [MessageData]) -> [MessageData] {
        var newOne:[MessageData] = []
        for i in 0..<messages.count {
            let message = messages[i]
            if currentArticleMessage.contains(where: { currentMessage in
                currentMessage.message.messageId != message.message.messageId
            }) {
                newOne.append(message)
            }
        }
        return newOne
    }
    
    
    // MARK: 查找資料區
    
    func hotTopicAmt() -> Int {
        return hotTopic.count
    }
    
    func allTopicAmt() -> Int {
        return allTopic.count
    }
    
    func messageAmt() -> Int {
        return currentArticleMessage.count
    }
    
    func postTopicAmt() -> Int {
        return postTopic.count
    }
    
    func collectTopicAmt() -> Int {
        return collectTopic.count
    }
    
    func getHotTopicDetail(index: IndexPath) -> TopicData? {
        if index.section < hotTopicAmt()  {
            return hotTopic[index.section]
        } else {
            return nil
        }
    }
    
    func getAllTopicDetail(index: IndexPath) -> TopicData? {
        if index.section < allTopicAmt()  {
            return allTopic[index.section]
        } else {
            return nil
        }
    }
    
    func getMessage(index: IndexPath) -> MessageData?{
        if currentArticleMessage.count > 0 {
            let data = currentArticleMessage[index.section-1]
            return data
        } else {
            return nil
        }
    }
    
    func getPostedTopicDetail(index: IndexPath) -> TopicContent? {
        if index.section < postTopicAmt()  {
            return postTopic[index.section]
        } else {
            return nil
        }
    }
    
    func getCollectedTopicDetail(index: IndexPath) -> TopicContent? {
        if index.section < collectTopicAmt()  {
            return collectTopic[index.section]
        } else {
            return nil
        }
    }
    
    func getTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        formatter.locale = Locale(identifier: "zh")
        return formatter.string(from: date)
    }
    
    func getImgUrl(image: UIImage, fileName: String,completion: @escaping ((Result<ImageData, Error>)->Void)){
        APIManager.shared.uploadImg(uploadImage: image, name: "") { response in
            switch response {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: 上傳資料區
    
    //發文
    func uploadArticle(article: TopicDataUpload, completion: @escaping ((Result<Bool, Error>)->Void)) {
        APIManager.shared.uploadArticle(article: article) { response in
            switch response {
            case .success(let object):
                completion(.success(object))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //留言
    func uploadMessage(message: MessageUpload, completion: @escaping ((Result<Bool, Error>)->Void)) {
        APIManager.shared.uploadMessage(message: message) { response in
            switch response {
            case .success(let object):
                completion(.success(object))
                self.delegate?.updateTopicData()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //按讚文章
    func uploadLikeArticle(articleID: Int, completion: @escaping ((Result<Bool, Error>)->Void)) {
        APIManager.shared.uploadLikeArticle(articleID: articleID) { response in
            switch response {
            case .success(let object):
                completion(.success(object))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //收藏文章
    func uploadSaveArticle(articleID: Int, completion: @escaping ((Result<Bool, Error>)->Void)) {
        APIManager.shared.uploadSaveArticle(articleID: articleID) { response in
            switch response {
            case .success(let object):
                completion(.success(object))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //按讚留言
    func uploadLikeMessage(messageID: Int, completion: @escaping ((Result<Bool, Error>)->Void)) {
        APIManager.shared.uploadLikedMessage(messageID: messageID) { response in
            switch response {
            case .success(let object):
                completion(.success(object))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

enum TopicType {
    case HotTopic
    case PersonalTopic
}
