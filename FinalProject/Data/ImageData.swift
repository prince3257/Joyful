//
//  ImageData.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/23.
//

import Foundation

struct ImageData: Codable {
    var data: ImgData
}

struct ImgData:Codable {
    var link: String
}
