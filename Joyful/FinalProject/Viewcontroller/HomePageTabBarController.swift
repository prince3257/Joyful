//
//  TabBatViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/13.
//

import UIKit

class HomePageTabBarController: UITabBarController {
    
    static var identifier = "HomePageTabBarController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //調整TabBar文字大小
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -tabBar.bounds.height/3.5)
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25.0),
             NSAttributedString.Key.kern: 15], for: .normal)
        UITabBar.appearance().unselectedItemTintColor = UIColor.darkGray
        settingButton()
    }
    
    //新增中間的小按鈕
    func settingButton() {
        var configuration = UIButton.Configuration.filled()
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "plus", withConfiguration: imgConfig)
        configuration.image = image
        configuration.background.backgroundColor = UIColor(red: 255/255, green: 178/255, blue: 30/255, alpha: 1)
        configuration.baseForegroundColor = .black
        

        let button = UIButton()
        button.configuration = configuration
        let buttonHW = tabBar.bounds.height * 0.8
        button.frame.size = CGSize(width: buttonHW, height: buttonHW)
        button.layer.cornerRadius = buttonHW/2
        button.center = CGPoint(x: tabBar.bounds.midX, y: tabBar.bounds.midY)
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.borderWidth = 2
        button.clipsToBounds = true
        // 新增一個點擊事件
        button.addTarget(self, action: #selector(showViewController), for: .touchUpInside)
        tabBar.addSubview(button)
    }

    @objc func showViewController() {
        performSegue(withIdentifier: EditPostViewController.identifier, sender: self)
    }
    
}

