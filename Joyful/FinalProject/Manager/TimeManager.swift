//
//  TimeManager.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/27.
//

import Foundation

class TimeManager {
    
    static var shared = TimeManager()
    
    private init() {}
    
    func dateFormatter(originString: String) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let convertFirst = df.date(from: originString) {
            df.dateFormat = "MM月dd日"
            let realDate = df.string(from: convertFirst)
            return realDate
        } else {
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let convertSec = df.date(from: originString)!
            df.dateFormat = "MM月dd日"
            let realDate = df.string(from: convertSec)
            return realDate
        }
    }
    
    func dateFormatterWithTime(originString: String) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let convertFirst = df.date(from: originString) {
            df.dateFormat = "MM月dd日HH:mm"
            let realDate = df.string(from: convertFirst)
            return realDate
        } else {
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let convertSec = df.date(from: originString)!
            df.dateFormat = "MM月dd日HH:mm"
            let realDate = df.string(from: convertSec)
            return realDate
        }
    }
    
    func dateFormatterToDate(startTime: String, endTime: String, currentTime: Date) -> Bool {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh")
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let start = df.date(from: startTime),
              let end = df.date(from: endTime) else
        {
            return false
        }
        return currentTime >= start && currentTime <= end
    }
    
    func dateFormatterToDate(endTime: String, currentTime: Date) -> Bool {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh")
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let end = df.date(from: endTime) else
        {
            return false
        }
        return currentTime <= end
    }
    
    func formatBirthDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 MM 月 dd 日"
        return formatter.string(from: date)
    }
    
    func formatEventDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 MM 月 dd 日 HH：mm"
        return formatter.string(from: date)
    }
    
    func formatForUpdate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.string(from: date)
    }
}
