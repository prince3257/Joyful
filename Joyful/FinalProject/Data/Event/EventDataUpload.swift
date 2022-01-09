//
//  EventDataUpload.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/27.
//

import Foundation

struct EventDataUpload: Codable {
    var themeId: Int
    var areaId: Int
    var place: String
    var subject: String
    var account: String
    var wordContent: String
    var picture: String?
    var hardnessId: Int
    var isOnline: Bool
    var maxPeopleNumber: Int
    var currentPeopleNumber: Int
    var holdTime: String
    var price: Int
    var nickname: String
    var endTime: String
}
