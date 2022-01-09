//
//  LocationData.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/22.
//

import Foundation

class LocationDataModel {
    
    static var shared = LocationDataModel()
    
    private init() {}
    
    var location = [ Location(opened: false, title: "北部", sectionData: ["台北市","新北市","基隆市","桃園市","宜蘭縣"]),
                     Location(opened: false, title: "中部", sectionData: ["新竹市","新竹縣","苗栗縣","台中市","彰化縣","雲林縣","南投縣"]),
                    Location(opened: false, title: "南部", sectionData: ["嘉義縣","嘉義市","台南市","高雄市","屏東縣"]),
                     Location(opened: false, title: "東部", sectionData: ["花蓮縣","台東縣"]),
                     Location(opened: false, title: "離島", sectionData: ["澎湖縣","金門縣","連江縣"])]
    
    let regions:[String:Int] = ["台北市":1,"基隆市":2,"新北市":3,"桃園市":4,"台中市":5,"台南市":6,"高雄市":7,"宜蘭縣":8,"新竹縣":9,"苗栗縣":10,"彰化縣":11,"南投縣":12,"雲林縣":13,"嘉義縣":14,"屏東縣":15,"花蓮縣":16,"台東縣":17,"澎湖縣":18,"金門縣":19,"連江縣":20,"新竹市":21,"嘉義市":22]
    
    func getLocationSectionAmt() -> Int {
        return location.count
    }
    
    func getLocationRegionAmt(index: IndexPath) -> Int {
        return location[index.section].sectionData.count
    }
    
    func getLocationSection(section: Int) -> Location {
        return location[section]
    }
    
    func locationIndex(name: String) -> Int {
        guard let location = regions[name] else {
            return 1
        }
        return location
    }
    
    func locationName(index: Int) -> String? {
        let name = regions.filter { dic in
            return dic.value == index
        }
        return name.first?.key
    }
    
}


