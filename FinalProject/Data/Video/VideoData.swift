//
//  VideoData.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/30.
//

import Foundation

class VideoData:Codable {
    var items: [SingleVideo]
}

class SingleVideo: Codable {
    var snippet: VideoContent
    var contentDetails:ContentDetails
}

//需要channelID
class VideoContent: Codable {
    var channelId: String
    var title: String
    var description: String
    var thumbnails: Thumbnails
    var channelTitle: String
    var playlistId: String
    var position: Int
}

class Thumbnails: Codable {
    var medium: VideoImg
}

class VideoImg: Codable {
    var url: String
    var width: Int
    var height: Int
}

class ContentDetails: Codable {
    var videoId: String
}
