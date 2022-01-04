//
//  HotEventData.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/19.
//

import Foundation

class EventData: Codable {
    var event:EventContent
    var attantAcount: String?
}


class EventContent:Codable {
    var account: String
    var eventId: Int
    var subject: String
    var currentPeopleNumber: Int
    var nickname: String
    var picture: String?
    var wordContent: String
    var areaName: String
    var hardnessName: String
    var holdTime: String
    var endTime: String
    var isOnline: Bool
    var maxPeopleNumber: Int
    var place: String
    var price: Int?
    var theme: String
    var avatar: String?
}
