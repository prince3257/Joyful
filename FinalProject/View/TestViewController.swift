//
//  TestViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/23.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("開始拉API")
        open()
        // Do any additional setup after loading the view.
    }
    
    func open() {
        APIManager.shared.uploadImg(uploadImage: UIImage(systemName: "xmark") ?? UIImage(), name: "test") { response in
            switch response {
            case .success(_):
                print("成功")
            case .failure(_):
                print("失敗")
            }
        }
    }

}
