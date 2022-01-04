//
//  EventPageDataModel.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/19.
//

import Foundation
import UIKit

protocol EventDataModelDelegate: AnyObject{
    func updateEventData()
}

class EventDataModel{
        
    static var shared = EventDataModel()
    
    private init() {}
    
    weak var delegate: EventDataModelDelegate?
    
    //Test
    weak var delegate2: EventDataModelDelegate?
    //
        
    var onsiteEvent:[EventData] = []
                
    var onlineEvent:[EventData] = []
            
    var hotEvent:[EventData] = []
    
    var joinEvent:[EventContent] = []
    
    // MARK: 取得資料區

    //取得線下活動資料
    func fetchOnsiteEvent(page:Int) {
        APIManager.shared.getEventData(eventType: .OnsiteEvent, page: page) { response in
            switch response {
            case .success(let data):
                if page == 1{
                    self.onsiteEvent = self.alocateByTime(data: data)
//                    self.onsiteEvent = data
                } else {
                    self.onsiteEvent += self.consolidateEvent(eventType: .OnsiteEvent, events: data)
                }
                self.consolidate(eventType: .OnsiteEvent)
                self.delegate?.updateEventData()
                //Test
                self.delegate2?.updateEventData()
                //
                break
            case .failure(_):
                break
            }
        }
    }

    //取得線上活動資料
    func fetchOnlineEvent(page:Int) {
        APIManager.shared.getEventData(eventType: .OnlineEvent, page: page) { response in
            switch response {
            case .success(let data):
                if page == 1{
//                    self.onlineEvent = data
                    self.onlineEvent = self.alocateByTime(data: data)
                } else {
                    self.onlineEvent += self.consolidateEvent(eventType: .OnlineEvent, events: data)
                }
                self.consolidate(eventType: .OnlineEvent)
//                self.delegate?.updateEventData()
                //Test
                self.delegate2?.updateEventData()
                //
                break
            case .failure(_):
                break
            }
        }
    }
    
    //取得熱門活動資料
    func fetchHotEvent(page:Int) {
        APIManager.shared.getEventData(eventType: .HotEvent, page: page) { response in
            switch response {
            case .success(let data):
                if page == 1{
//                    self.hotEvent = data
                    self.hotEvent = self.alocateByTime(data: data)
                } else {
                    self.hotEvent += self.consolidateEvent(eventType: .HotEvent, events: data)
                }
                self.consolidate(eventType: .HotEvent)
                self.delegate?.updateEventData()
                break
            case .failure(_):
                break
            }
        }
    }
    
    //取得熱門活動資料
    func fetchPersonalRelatedEvent(page:Int) {
        APIManager.shared.getPersonalRelatedEvent(page: page) { response in
            switch response {
            case .success(let data):
                if page == 1{
                    self.joinEvent = data
                } else {
                    self.joinEvent += self.consolidatePersonalEvent(events: data)
                }
                self.delegate?.updateEventData()
            case .failure(_):
                break
            }
        }
    }
    
    //整理活動資料(一般)
    private func consolidateEvent(eventType: EventType ,events: [EventData]) -> [EventData] {
        var newOne:[EventData] = []
        for i in 0..<events.count {
            let event = events[i]
            switch eventType {
            case .HotEvent:
                if hotEvent.contains(where: { hotevent in
                    hotevent.event.eventId != event.event.eventId
                }) {
                    if TimeManager.shared.dateFormatterToDate(startTime: event.event.holdTime, endTime: event.event.endTime, currentTime: Date()){
                        newOne.append(event)
                    }
                }
            case .OnsiteEvent:
                if onsiteEvent.contains(where: { onsiteevent in
                    onsiteevent.event.eventId != event.event.eventId
                }) {
                    if TimeManager.shared.dateFormatterToDate(startTime: event.event.holdTime, endTime: event.event.endTime, currentTime: Date()){
                        newOne.append(event)
                    }
                }
            case .OnlineEvent:
                if onlineEvent.contains(where: { onlineevent in
                    onlineevent.event.eventId != event.event.eventId
                }) {
                    if TimeManager.shared.dateFormatterToDate(startTime: event.event.holdTime, endTime: event.event.endTime, currentTime: Date()){
                        newOne.append(event)
                    }
                }
            }
        }
        return newOne
    }
    
    //整理活動資料(個人)
    private func consolidatePersonalEvent(events: [EventContent]) -> [EventContent] {
        var newOne:[EventContent] = []
        for i in 0..<events.count {
            let event = events[i]
            if joinEvent.contains(where: { joinedevent in
                joinedevent.eventId != event.eventId
            }) {
                newOne.append(event)
            }
        }
        return newOne
    }

    //整理時間
    private func alocateByTime(data: [EventData]) -> [EventData] {
        var arr:[EventData] = []
        for i in 0..<data.count {
            let event = data[i]
            if TimeManager.shared.dateFormatterToDate(endTime: event.event.endTime, currentTime: Date()){
                arr.append(event)
            }
        }
        return arr
    }
    
    //做排序
    private func consolidate(eventType: EventType) {
        switch eventType {
        case .HotEvent:
            let registerHot = hotEvent.filter { event in
                return event.attantAcount != nil
            }
            let restHot = hotEvent.filter { event in
                return event.attantAcount == nil
            }
            self.hotEvent = registerHot + restHot
            break
        case .OnsiteEvent:
            let registerOnsite = onsiteEvent.filter { event in
                return event.attantAcount != nil
            }
            let restOnsite = onsiteEvent.filter { event in
                return event.attantAcount == nil
            }
            self.onsiteEvent = registerOnsite + restOnsite
            break
        case .OnlineEvent:
            let registerOnline = onlineEvent.filter { event in
                return event.attantAcount != nil
            }
            let restOnline = onlineEvent.filter { event in
                return event.attantAcount == nil
            }
            self.onlineEvent = registerOnline + restOnline
            break
        }
    }
    
    // MARK: 上傳資料區
    
    //發起活動
    func uploadEvent(event: EventDataUpload, completion: @escaping ((Result<Bool, Error>)->Void)) {
        APIManager.shared.uploadEvent(event: event) { response in
            switch response {
            case .success(let object):
                completion(.success(object))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //參加活動
    func attendEvent(eventID: Int, completion: @escaping ((Result<Bool, Error>)->Void)) {
        APIManager.shared.attendEvent(eventID: eventID) { response in
            switch response {
            case .success(let object):
                completion(.success(object))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: 查找資料區
    
    func hotEventAmt() -> Int {
        return hotEvent.count
    }
    
    func onsiteEventAmt() -> Int {
        return onsiteEvent.count
    }
    
    func onlineEventAmt() -> Int {
        return onlineEvent.count
    }
    
    func joinedEventAmt() -> Int {
        return joinEvent.count
    }
    
    func getHotEventDetail(index: IndexPath) -> EventData? {
        if index.section < hotEventAmt()  {
            return hotEvent[index.item]
        } else {
            return nil
        }
    }
    
    func getOnsiteEventDetail(index: IndexPath) -> EventData? {
        if index.section < onsiteEventAmt()  {
            return onsiteEvent[index.section]
        } else {
            return nil
        }
    }
    
    func getOnlineEventDetail(index: IndexPath) -> EventData? {
        if index.section < onlineEventAmt() {
            return onlineEvent[index.section]
        } else {
            return nil
        }
    }
    
    func getPersonalEventDetail(index: IndexPath) -> EventContent? {
        if index.section < joinedEventAmt() {
            return joinEvent[index.section]
        } else {
            return nil
        }
    }
    
    func getLevelColor(level:String) -> UIColor {
        switch level {
        case "適合初學者":
            return UIColor(red: 223/255, green: 255/255, blue: 198/255, alpha: 1)
        case "適合有經驗":
            return UIColor(red: 137/255, green: 205/255, blue: 155/155, alpha: 1)
        case "專家達人 ":
            return UIColor(red: 231/255, green: 122/255, blue: 122/255, alpha: 1)
        default:
            return UIColor(red: 223/255, green: 255/255, blue: 198/255, alpha: 1)
        }
    }
    
    func getTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 aaa hh:mm"
        formatter.amSymbol = "上午"
        formatter.pmSymbol = "下午"
        formatter.locale = Locale(identifier: "zh")
        return formatter.string(from: date)
    }
    
}

enum EventType {
    case HotEvent
    case OnsiteEvent
    case OnlineEvent
}

enum Level:Int {
    case 適合新手 = 1
    case 適合有經驗 = 2
    case 適合專家達人 = 3
}
