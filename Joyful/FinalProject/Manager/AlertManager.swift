//
//  AlertManager.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/18.
//

import UIKit

class AlertManager: UIViewController {
    
    static var shared = AlertManager()
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showAlert(title: String, headLine: String, content: String, vc: UIViewController) {
        let alertController = UIAlertController(title: title, message: headLine, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: content, style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        vc.present(alertController, animated: true, completion: nil)
    }


}
