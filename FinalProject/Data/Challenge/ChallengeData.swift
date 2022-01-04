//
//  ChallengeData.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/22.
//

import Foundation

struct ChallengeData: Codable{
    
    var id : String
    var title : String
    var theme : String
    var content : String
    var level : String
    var imgUrl : String
    var badge : BadgeData
    var steps : [StepData]
    var step : [StepData]
}
