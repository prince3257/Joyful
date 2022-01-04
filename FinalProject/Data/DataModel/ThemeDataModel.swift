//
//  ThemeData.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/16.
//

import Foundation

class ThemeDataModel {
    
    static var shared = ThemeDataModel()
    
    private init() {}
    
    var allThemes = [Theme(title: "釣魚", imageurl: "https://i.imgur.com/EJqE9ck.jpg"),
                     Theme(title: "烹飪", imageurl: "https://i.imgur.com/3CQXuls.jpg"),
                     Theme(title: "爬山", imageurl: "https://i.imgur.com/hVq6XLw.jpg"),
                     Theme(title: "下棋", imageurl: "https://i.imgur.com/8DRfwzp.jpg"),
                     Theme(title: "唱歌", imageurl: "https://i.imgur.com/OoiYLcj.jpg"),
                     Theme(title: "跳舞", imageurl: "https://i.imgur.com/ldrCGB0.png"),
                     Theme(title: "追劇", imageurl: "https://i.imgur.com/vTPocSt.jpg"),
                     Theme(title: "電玩", imageurl: "https://i.imgur.com/0hWujLq.jpg"),
                     Theme(title: "茶藝", imageurl: "https://i.imgur.com/R5l7jIO.jpg"),
                     Theme(title: "植栽", imageurl: "https://i.imgur.com/HHagXcl.jpg"),
                     Theme(title: "籃球", imageurl: "https://i.imgur.com/8zzD4v3.jpg"),
                     Theme(title: "羽球", imageurl: "https://i.imgur.com/cjA6y1y.jpg"),
                     Theme(title: "重訓", imageurl: "https://i.imgur.com/aeV4j9P.png"),
                     Theme(title: "畫畫", imageurl: "https://i.imgur.com/0DTponL.jpg"),
                     Theme(title: "旅遊", imageurl: "https://i.imgur.com/UWdY8lu.jpg"),
                     Theme(title: "寵物", imageurl: "https://i.imgur.com/M1H2KNL.jpg"),
                     Theme(title: "烘焙", imageurl: "https://i.imgur.com/TXPobdd.jpg"),
                     Theme(title: "織物", imageurl: "https://i.imgur.com/KyY5YLs.jpg"),
                     Theme(title: "閱讀", imageurl: "https://i.imgur.com/IOjgmQm.jpg"),
                     Theme(title: "電影", imageurl: "https://i.imgur.com/sVyxK6e.jpg")]
    
    let themes:[String:Int] = ["釣魚":1,"烹飪":2,"爬山":3,"下棋":4,"唱歌":5,"跳舞":6,"追劇":7,"電玩":8,"茶藝":9,"植栽":10,"籃球":11,"羽球":12,"重訓":13,"畫畫":14,"旅遊":15,"寵物":16,"烘焙":17,"織物":18,"閱讀":19,"電影":20]
    
    var presentTheme:[Theme] = []
    
    func getThemes() {
        presentTheme = allThemes
    }
    
    
    func getThemes(themeName: String) {
        presentTheme = []
        allThemes.map { theme in
            for i in themeName {
                if theme.title.contains(i) {
                    presentTheme.append(theme)
                }
            }
        }
    }
    
    
    func themeIndex(name: String) -> Int {
        guard let theme = themes[name] else {
            return 1
        }
        return theme
    }
    
    func themeName(index: Int) -> String? {
        let name = themes.filter { dic in
            return dic.value == index
        }
        return name.first?.key
    }
    
    func themesName(themes: [Int]) -> [String]? {
        var strArr:[String] = []
        themes.forEach { index in
            if let name = themeName(index: index) {
                strArr.append(name)
            }
        }
        return strArr
    }
    
    func themesIndex(themes: [String]) -> [Int]? {
        var strArr:[Int] = []
        themes.forEach { string in
            let index = themeIndex(name: string)
            strArr.append(index)
        }
        return strArr
    }
    
    func getDataDetail(index: Int) -> Theme {
        return presentTheme[index]
    }
}

