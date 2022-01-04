//
//  LoginPageViewController.swift
//  FinalProject
//
//  Created by 丹尼爾 on 2021/12/14.
//

import UIKit
import Lottie
import SwiftKeychainWrapper
import JGProgressHUD

class LoginPageViewController: UIViewController {
    
    var cacheACPW: [String]?
    
    @IBOutlet weak var account: CustomTextField!{
        didSet {
            account.attributedPlaceholder = NSAttributedString(
                string: "您的信箱",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    @IBOutlet weak var password: CustomTextField!{
        didSet {
            password.attributedPlaceholder = NSAttributedString(
                string: "您的密碼",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBAction func login(_ sender: Any) {
        
        let hud = JGProgressHUD.init()
        hud.textLabel.text = "登入中"
        hud.show(in: self.view, animated: true)
        
        //要做登入驗證
        guard let ac = account.text, ac != "", let pw = password.text, pw != "" else {
            hud.dismiss(animated: true)
            AlertManager.shared.showAlert(title: "登入有誤", headLine: "請確認帳號密碼是否皆填寫", content: "返回確認", vc: self)
            return
        }
        APIManager.shared.login(with: ac, with: pw, completion: { response in
            switch response {
            case .success(_):
                DispatchQueue.main.async {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomePageTabBarController") as! HomePageTabBarController
                    vc.modalPresentationStyle = .fullScreen
                    hud.dismiss(animated: true)
                    self.present(vc, animated: true, completion: nil)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    hud.dismiss(animated: true)
                    AlertManager.shared.showAlert(title: "登入有誤", headLine: "請確認帳號密碼是否正確", content: "返回確認", vc: self)
                }
            }
        })
                
    }
    
    @IBAction func signup(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupPageViewController") as! SignupPageViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //設定頁面元件
        keyboardNotificationSetting()
        addGesture()
        AnimationManager.shared.normalAnimation(view: animationView, animationName: "loginPage")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnimationManager.shared.resume(view: animationView)

        //確認是否已登入
//        if let cacheACPW = cacheACPW {
//            account.text = cacheACPW[0]
//            password.text = cacheACPW[1]
//            self.cacheACPW = nil
//        } else {
//            if APIManager.shared.checkLogedIn() {
//                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: HomePageTabBarController.identifier) as! HomePageTabBarController
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true, completion: nil)
//            }
//        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //新增手勢：點擊空白處收回鍵盤
    func addGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
    }
    
    //註冊鍵盤監聽
    func keyboardNotificationSetting() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyborad), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func showKeyboard(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

    }
    @objc func hideKeyborad(_ notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
}

extension LoginPageViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            password.becomeFirstResponder()
        } else {
            password.resignFirstResponder()
        }
        return true
    }
    
}
